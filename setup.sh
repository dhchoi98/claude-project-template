#!/bin/bash
# setup.sh — 템플릿 초기화 스크립트
# 사용법: ./setup.sh <project-name> <github-username> [옵션]
#
# 옵션:
#   --type   web|cli|security|ml|scada|quant|general  프로젝트 유형 (기본: general)
#   --rigor  mvp|production|enterprise                엔지니어링 깊이 (기본: mvp)
#   --mode   solo|team                                워크플로우 모드 (기본: solo)
#   --desc   "설명"                                    프로젝트 설명
#
# 예시:
#   ./setup.sh hackathon dhchoi98 --type web --rigor mvp
#   ./setup.sh scada-hmi dhchoi98 --type scada --rigor enterprise --mode team
#   ./setup.sh quant-bot dhchoi98 --type quant --rigor production
#   ./setup.sh ctf-2026 dhchoi98 --type security --rigor mvp

set -e

# ─── 인자 파싱 ────────────────────────────────────────────

PROJECT_NAME=""
GITHUB_USER=""
PROJECT_TYPE="general"
PROJECT_RIGOR="mvp"
PROJECT_MODE="solo"
PROJECT_DESC=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --type)     PROJECT_TYPE="$2"; shift 2 ;;
        --rigor)    PROJECT_RIGOR="$2"; shift 2 ;;
        --mode)     PROJECT_MODE="$2"; shift 2 ;;
        --desc)     PROJECT_DESC="$2"; shift 2 ;;
        --help|-h)
            head -14 "$0" | tail -12
            echo ""
            echo "프로젝트 유형:"
            echo "  general  — src/ tests/ docs/"
            echo "  web      — backend/ frontend/ shared/ docs/"
            echo "  cli      — cmd/ internal/ docs/ tests/"
            echo "  security — tools/ exploits/ notes/ reports/"
            echo "  ml       — notebooks/ data/ models/ src/"
            echo "  scada    — backend/ hmi/ plc/ drivers/ docs/ tests/"
            echo "  quant    — backend/ core/ strategies/ data/ dashboard/ tests/"
            echo ""
            echo "엔지니어링 깊이:"
            echo "  mvp        — 속도 우선. 타입/테스트 선택적. 해커톤, 대회, PoC"
            echo "  production — Contract-First. 함수 시그니처 타입 필수. 핵심 모듈 테스트"
            echo "  enterprise — Full strict. 변수 타입까지. TDD 강제. 네이버/카카오급"
            exit 0
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            elif [ -z "$GITHUB_USER" ]; then
                GITHUB_USER="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ] || [ -z "$GITHUB_USER" ]; then
    echo "Usage: ./setup.sh <project-name> <github-username> [옵션]"
    echo "  --help 로 전체 옵션 확인"
    exit 1
fi

[ -z "$PROJECT_DESC" ] && PROJECT_DESC="$PROJECT_NAME"

# 유효성 검사
VALID_TYPES="general web cli security ml scada quant"
if ! echo "$VALID_TYPES" | grep -qw "$PROJECT_TYPE"; then
    echo "ERROR: --type 은 $VALID_TYPES 중 하나여야 합니다."
    exit 1
fi
VALID_RIGORS="mvp production enterprise"
if ! echo "$VALID_RIGORS" | grep -qw "$PROJECT_RIGOR"; then
    echo "ERROR: --rigor 는 mvp|production|enterprise 중 하나여야 합니다."
    exit 1
fi
if [[ "$PROJECT_MODE" != "solo" && "$PROJECT_MODE" != "team" ]]; then
    echo "ERROR: --mode 는 solo|team 중 하나여야 합니다."
    exit 1
fi

echo "=== Claude Project Template Setup ==="
echo "  Project:  $PROJECT_NAME"
echo "  User:     $GITHUB_USER"
echo "  Type:     $PROJECT_TYPE"
echo "  Rigor:    $PROJECT_RIGOR"
echo "  Mode:     $PROJECT_MODE"
echo "  Desc:     $PROJECT_DESC"
echo ""

# ─── 1. 프로젝트 설정 파일 생성 ──────────────────────────

echo "[1/8] 프로젝트 설정 파일 생성..."
cat > .project-config << EOF
PROJECT_NAME=$PROJECT_NAME
PROJECT_TYPE=$PROJECT_TYPE
PROJECT_RIGOR=$PROJECT_RIGOR
PROJECT_MODE=$PROJECT_MODE
EOF

# ─── 2. 플레이스홀더 치환 ─────────────────────────────────

echo "[2/8] 플레이스홀더 치환..."

safe_replace() {
    local placeholder="$1"
    local value="$2"
    local escaped_value
    escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')

    find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.sh" \) \
        ! -path "./.git/*" \
        ! -path "./setup.sh" \
        -print0 | xargs -0 perl -pi -e "s/\Q${placeholder}\E/${escaped_value}/g" 2>/dev/null || true
}

safe_replace "{{PROJECT_NAME}}" "$PROJECT_NAME"
safe_replace "{{GITHUB_USER}}" "$GITHUB_USER"
safe_replace "{{PROJECT_DESCRIPTION}}" "$PROJECT_DESC"
safe_replace "{{PROJECT_TYPE}}" "$PROJECT_TYPE"
safe_replace "{{PROJECT_MODE}}" "$PROJECT_MODE"
safe_replace "{{PROJECT_RIGOR}}" "$PROJECT_RIGOR"

# ─── 3. ISSUE_TEMPLATE config ────────────────────────────

echo "[3/8] 이슈 템플릿 설정..."
cat > .github/ISSUE_TEMPLATE/config.yml << EOF
blank_issues_enabled: false
contact_links:
  - name: PLAN.md
    url: https://github.com/$GITHUB_USER/$PROJECT_NAME/blob/main/PLAN.md
    about: 전체 개발 계획 확인
EOF

# ─── 4. 프로젝트 유형별 디렉토리 + .gitignore ─────────────

echo "[4/8] 프로젝트 디렉토리 생성 ($PROJECT_TYPE)..."
case "$PROJECT_TYPE" in
    web)
        mkdir -p backend frontend shared docs tests
        ;;
    cli)
        mkdir -p cmd internal docs tests
        ;;
    security)
        mkdir -p tools exploits notes reports
        cat >> .gitignore << 'SECIGNORE'

# Security tools output
*.pcap
*.cap
*.dump
*.raw
*.bin
loot/
*.msf4/
*.hashes
*.pot
wordlists/
*.ovpn
SECIGNORE
        ;;
    ml)
        mkdir -p notebooks data models src tests
        cat >> .gitignore << 'MLIGNORE'

# ML / Data
*.h5
*.hdf5
*.pkl
*.pickle
*.parquet
*.feather
*.csv
*.tsv
data/raw/
data/processed/
models/checkpoints/
wandb/
mlruns/
*.onnx
*.pt
*.pth
*.safetensors
MLIGNORE
        ;;
    scada)
        mkdir -p backend hmi plc drivers docs tests
        mkdir -p backend/core backend/protocols backend/services
        mkdir -p hmi/components hmi/screens
        mkdir -p plc/simulators plc/configs
        mkdir -p drivers/modbus drivers/opcua
        mkdir -p tests/core tests/protocols tests/drivers tests/integration
        cat >> .gitignore << 'SCADAIGNORE'

# SCADA specific
*.db
*.sqlite3
plc/configs/production/
*.lic
logs/
SCADAIGNORE
        ;;
    quant)
        mkdir -p backend core strategies data dashboard tests
        mkdir -p core/engine core/models core/signals
        mkdir -p strategies/implementations
        mkdir -p data/adapters data/cache
        mkdir -p dashboard/api dashboard/frontend
        mkdir -p tests/core tests/strategies tests/adapters tests/integration
        cat >> .gitignore << 'QUANTIGNORE'

# Quant specific
data/cache/
data/raw/
*.csv
*.parquet
*.feather
backtest_results/
logs/
*.db
*.sqlite3
QUANTIGNORE
        ;;
    general)
        mkdir -p src tests docs
        ;;
esac

# ─── 5. 모드별 CLAUDE.md 조정 ────────────────────────────

echo "[5/8] 워크플로우 모드 적용 ($PROJECT_MODE)..."
if [[ "$PROJECT_MODE" == "solo" ]]; then
    perl -0777 -pi -e '
s/## 세션 프로토콜 \(Multi-Session Orchestration\).*?(?=## 용어)/## 워크플로우 (Solo Mode)

> 1인 개발 모드. 티켓 시스템 없이 직접 작업한다.

### 작업 흐름

1. PLAN.md에서 다음 할 일 확인
2. 필요하면 Plan 모드로 계획 수립 (선택적)
3. 구현
4. 자가 검증 (테스트\/빌드\/린트)
5. 완료 시 PLAN.md 상태 업데이트

### 규칙
- PLAN.md가 단일 진실 공급원
- 복잡한 변경은 Plan 모드 사용 권장 (필수 아님)
- Git 작업은 사용자가 명시적으로 지시할 때만

---

/s' CLAUDE.md

    perl -0777 -pi -e '
s/\| 세션\(S\{N\}\).*?\n\| 핸드오프.*?\n//g' CLAUDE.md

    perl -pi -e 's/코드를 바로 작성하지 않는다\. \*\*항상 Plan 모드에서 계획을 먼저 제시\*\*하고 승인을 받는다\./복잡한 변경은 Plan 모드 권장. 간단한 수정은 바로 진행 가능./' CLAUDE.md
fi

# ─── 6. Rigor별 CLAUDE.md 섹션 추가 ─────────────────────

echo "[6/8] 엔지니어링 깊이 적용 ($PROJECT_RIGOR)..."

case "$PROJECT_RIGOR" in
    mvp)
        cat >> CLAUDE.md << 'RIGOR_MVP'

---

## 엔지니어링 규칙 (MVP)

> 속도 우선. 동작하는 코드를 빠르게 만든다.

### 타입
- Python: 함수 시그니처 타입힌트 **권장** (필수 아님)
- TypeScript: strict 모드 사용
- 복잡한 제네릭이나 오버엔지니어링 금지

### 테스트
- 테스트 **선택적**. 핵심 비즈니스 로직에만 작성
- 버그 발견 시 회귀 테스트 추가
- E2E 테스트 불필요

### 아키텍처
- 단순 구조 유지. 패턴 강제 없음
- 동작하면 OK. 나중에 리팩토링
RIGOR_MVP
        ;;

    production)
        cat >> CLAUDE.md << 'RIGOR_PROD'

---

## 엔지니어링 규칙 (Production)

> Contract-First Development. 인터페이스 → 테스트 → 구현 순서.

### Contract-First 워크플로우 (CC → Cursor 분업)

```
1단계: CC — 계약 정의
  → ABC/Protocol 인터페이스, 타입, 데이터 모델 정의

2단계: CC — 계약 테스트 작성
  → "이 인터페이스에 대한 계약 테스트를 작성해줘"
  → 인터페이스를 정의한 CC가 "어떻게 써야 하는지"를 가장 잘 안다

3단계: Cursor Auto — 구현체 작성 (무제한)
  → "이 테스트를 통과시켜줘"
  → 테스트가 정답지 → Auto가 방향 안 잃음, 통과 = 완료
```

### 타입 규칙
- **함수 시그니처 타입 필수**: 모든 함수에 파라미터 타입 + 리턴 타입 명시
- `dataclass(frozen=True)`를 기본 데이터 모델로 사용
- `Literal`, `TypeAlias`, `Generic` 적극 활용
- `Any` 사용 최소화 — 불가피할 때 `# type: ignore` 주석과 사유
- TypeScript: strict 모드 + no-any 린트 규칙

### 테스트 규칙
- **핵심 모듈(core/) 테스트 필수**, 나머지 선택적
- 인터페이스 계약 테스트: "이 메서드가 이 타입을 리턴하는가?"
- 비즈니스 로직 테스트: 엣지 케이스 포함
- 어댑터/외부 연동: 파싱/변환 로직만 테스트
- API 라우트: 스모크 테스트 수준
- UI: 테스트 불필요

### 테스트 디렉토리 구조
```
tests/
├── core/            ← 필수: 인터페이스 계약 + 비즈니스 로직
├── adapters/        ← 중요: 외부 API 파싱, 데이터 변환
├── api/             ← 선택: 엔드포인트 스모크 테스트
└── conftest.py      ← 공용 fixture
```

### 아키텍처
- 레이어 분리: core (순수 로직) / adapters (외부 연동) / api (진입점)
- core는 외부 의존성 없이 순수 Python/TS로 작성
- 의존성 역전: core가 인터페이스를 정의, adapters가 구현
RIGOR_PROD
        ;;

    enterprise)
        cat >> CLAUDE.md << 'RIGOR_ENT'

---

## 엔지니어링 규칙 (Enterprise)

> Full strict. Contract-First + TDD. 장기 유지보수를 위한 엔지니어링.

### Contract-First + TDD 워크플로우 (CC → Cursor 분업)

```
1단계: CC — 계약 정의
  → ABC/Protocol 인터페이스, 타입, 데이터 모델 정의
  → ADR(Architecture Decision Record) 작성

2단계: CC — TDD 테스트 작성 (구현 전에 먼저)
  → 인터페이스 계약 테스트
  → 비즈니스 로직 엣지 케이스 테스트
  → 통합 테스트 시나리오

3단계: Cursor Auto — 구현체 작성 (테스트를 통과시키며)
  → Red → Green → Refactor 사이클
  → Auto 무제한이라 반복 부담 없음
```

### 타입 규칙 (Full Strict)
- **모든 변수, 파라미터, 리턴 타입을 명시적으로 선언**
- `dataclass(frozen=True)`를 기본 데이터 모델로 사용
- `Literal`, `TypeAlias`, `Generic`, `Protocol` 적극 활용
- `Any` 사용 **금지** — 반드시 구체적 타입 또는 `TypeVar`로 대체
- `cast()` 사용 시 사유 주석 필수
- TypeScript: strict 모드 + noImplicitAny + noUncheckedIndexedAccess
- pyproject.toml에 `mypy strict = true` 설정

### 테스트 규칙 (TDD)
- **구현 전에 테스트를 먼저 작성** (Red → Green → Refactor)
- 커버리지 목표: core/ 90%+, adapters/ 70%+, 전체 60%+
- 인터페이스 계약 테스트: 타입, 리턴값 범위, 불변 조건 검증
- 비즈니스 로직 테스트: 정상/엣지/에러 케이스 모두 포함
- 통합 테스트: 주요 시나리오 흐름
- 버그 수정 시 회귀 테스트 **필수** (먼저 실패하는 테스트 작성)

### 테스트 디렉토리 구조
```
tests/
├── core/            ← 필수: 인터페이스 계약 + 비즈니스 로직 (90%+)
├── adapters/        ← 필수: 외부 API 파싱, 데이터 변환 (70%+)
├── api/             ← 필수: 엔드포인트 + 에러 핸들링
├── integration/     ← 필수: 주요 시나리오 E2E
├── fixtures/        ← 테스트 데이터 (JSON, mock 등)
└── conftest.py      ← 공용 fixture
```

### 아키텍처 (Clean Architecture)
- **엄격한 레이어 분리**:
  - `core/` — 순수 도메인 로직. 외부 의존성 zero.
  - `adapters/` — 외부 시스템 연동 (DB, API, 파일 등)
  - `api/` — HTTP/gRPC/CLI 진입점
  - `services/` — 유스케이스 오케스트레이션
- 의존성 방향: api → services → core ← adapters
- core에 정의된 Protocol/ABC를 adapters가 구현 (DIP)
- 모든 외부 의존성은 DI로 주입

### 코드 품질
- PR 체크리스트: 타입 체크 통과, 테스트 통과, 린트 통과, 리뷰 완료
- 새 모듈 추가 시 ADR 작성 (.work/decisions/)
- 성능 민감 코드: 벤치마크 테스트 포함
- 에러 핸들링: 커스텀 예외 클래스 사용, 빈 except 금지
RIGOR_ENT
        ;;
esac

# ─── 7. 프로젝트 유형별 CLAUDE.md 도메인 가이드 추가 ──────

echo "[7/8] 도메인 가이드 추가 ($PROJECT_TYPE)..."
case "$PROJECT_TYPE" in
    scada)
        cat >> CLAUDE.md << 'DOMAIN_SCADA'

---

## 도메인 가이드 (SCADA)

### 안전 규칙 (Safety-Critical)
- **모든 PLC 통신은 타임아웃을 설정**한다. 기본 3초.
- 센서값 범위 검증(validation)을 반드시 수행한다
- 제어 명령 전 **이중 확인** (값 범위 + 상태 확인)
- 모든 상태 변경은 로그에 기록한다 (audit trail)
- 통신 실패 시 **안전한 기본값(fail-safe)**으로 폴백
- 프로덕션 PLC 설정 파일은 `.gitignore`에 포함 (소스에 커밋 금지)

### 프로토콜
- Modbus TCP/RTU: `pymodbus` 또는 직접 드라이버
- OPC UA: `asyncua` 라이브러리
- 프로토콜별 드라이버는 `drivers/` 디렉토리에 격리

### 구조
```
backend/
├── core/           ← 도메인 모델, 알람 로직, 상태 머신
├── protocols/      ← Modbus, OPC UA 통신 계층
├── services/       ← 데이터 수집, 알람 관리, 히스토리 저장
hmi/                ← 사람-기계 인터페이스 (화면, 대시보드)
plc/                ← PLC 시뮬레이터, 설정 파일
drivers/            ← 프로토콜 드라이버 (modbus, opcua)
tests/
├── core/           ← 상태 머신, 알람 로직 테스트
├── protocols/      ← 프로토콜 파싱 테스트
├── drivers/        ← 드라이버 단위 테스트
└── integration/    ← PLC 시뮬레이터 연동 테스트
```
DOMAIN_SCADA
        ;;
    quant)
        cat >> CLAUDE.md << 'DOMAIN_QUANT'

---

## 도메인 가이드 (Quant Trading)

### 핵심 원칙
- **백테스트와 라이브 코드 경로를 동일하게** 유지 (look-ahead bias 방지)
- 모든 시그널의 `confidence`는 0.0~1.0 범위
- 금융 데이터는 `Decimal` 또는 고정 소수점 사용 (float 연산 오차 주의)
- 주문 로직은 반드시 dry-run 모드를 지원
- API 키, 브로커 인증 정보는 절대 소스에 포함하지 않음

### Contract-First 인터페이스 예시
```python
class MarketDataAdapter(ABC):
    @abstractmethod
    async def fetch_ohlcv(self, symbol: str, timeframe: Timeframe) -> list[OHLCV]: ...

class SignalEngine(ABC):
    @abstractmethod
    def generate(self, data: list[OHLCV]) -> Signal: ...

class BrokerAdapter(ABC):
    @abstractmethod
    async def submit_order(self, order: Order) -> OrderResult: ...
```

### 구조
```
core/
├── engine/         ← 시그널 엔진, 전략 실행기
├── models/         ← OHLCV, Signal, Order, Position 등 데이터 모델
├── signals/        ← 시그널 생성 로직
strategies/
├── implementations/ ← 구체적 전략 구현체
data/
├── adapters/       ← 거래소 API, 데이터 소스 연동
├── cache/          ← 로컬 캐시 (gitignore)
dashboard/
├── api/            ← 대시보드 백엔드
├── frontend/       ← 대시보드 UI
tests/
├── core/           ← 엔진, 시그널 계약 테스트 (필수)
├── strategies/     ← 전략 백테스트
├── adapters/       ← API 파싱 테스트
└── integration/    ← 전체 파이프라인 테스트
```
DOMAIN_QUANT
        ;;
esac

# ─── 8. 마무리 ───────────────────────────────────────────

echo "[8/8] 마무리..."
chmod +x .claude/hooks/*.sh

# DB 규칙 조건부 적용
if [[ "$PROJECT_TYPE" == "cli" || "$PROJECT_TYPE" == "security" ]]; then
    perl -pi -e 's/- \*\*DB\*\*:.*$//' CLAUDE.md
fi

echo ""
echo "=== Setup 완료! ==="
echo ""
echo "  프로젝트:  $PROJECT_NAME"
echo "  유형:      $PROJECT_TYPE"
echo "  깊이:      $PROJECT_RIGOR"
echo "  모드:      $PROJECT_MODE"
echo ""
echo "다음 단계:"
echo "  1. CLAUDE.md를 프로젝트에 맞게 수정 (기술스택 등)"
echo "  2. PLAN.md에 개발 계획 작성"
echo "  3. ./init-labels.sh 실행하여 GitHub 라벨 생성"
echo "  4. setup.sh와 init-labels.sh 삭제 후 첫 커밋"
echo ""
echo "  rm setup.sh init-labels.sh"
echo "  git add -A && git commit -m 'chore: 프로젝트 초기 설정'"
