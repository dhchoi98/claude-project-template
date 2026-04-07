# The H Labs — Coding Methodology

> **"혼자 10년 뛸 수 있는 코드를 짜는 법"**
> 1인 체제 + 바이브 코딩 + 멀티 프로젝트 환경에 최적화된 코딩 방법론

---

## 이 문서의 목적

이 문서는 **사람이 읽는 학습 자료**다. AI가 읽는 규칙은 `CLAUDE.md`에 있다.

- 바이브 코딩을 **왜** 이렇게 하는지 이해한다
- 코드 예시를 보면서 패턴을 익힌다
- 프로젝트가 커져도 무너지지 않는 기반을 만든다

**전제:**
- 1인 개발자가 장기(5~10년) 운영
- AI 보조 코딩(Claude Code 메인 + Codex 보조)이 주력
- 프로젝트가 여러 개 — 코드의 "예쁨"보다 **"6개월 뒤의 내가 이해할 수 있는가"**가 기준

---

## 1. 개발 환경

### 에디터 + AI

```
Primary:   Claude Code (설계 + 구현 + 리뷰 전반)
Secondary: Codex (단순 보일러플레이트 위임용)
Editor:    취향대로 (VS Code, Neovim 등 — Claude Code가 메인 작업 공간)
```

**Claude Code:** `CLAUDE.md`를 자동으로 읽고 따른다. 이 템플릿이 이미 설정해준다.
**Codex:** `.codex/AGENTS.md`와 `.codex/config.toml`로 동작을 제어한다. CC 세션 안에서 `codex "..."` 셸 호출로 위임한다.

### 필수 CLI 도구

```bash
# Python
pyenv              # Python 버전 관리
uv                 # pip 대체 — 10~100배 빠른 패키지 설치
ruff               # linter + formatter (black + isort + flake8 통합)
mypy               # 정적 타입 체크
pytest             # 테스트

# JavaScript/TypeScript
fnm                # Node.js 버전 관리 (nvm보다 빠름)
pnpm               # npm 대체 — 디스크 효율 + 속도
biome              # linter + formatter (eslint + prettier 대체, 빠름)

# 공통
git                # 버전 관리
docker             # 컨테이너
lazygit            # 터미널 Git UI — 커밋/브랜치 관리가 극적으로 편해짐
```

---

## 2. 타입 시스템 — AI의 언어를 맞춰주는 것

### 왜 타입이 바이브 코딩에서 핵심인가

AI는 타입을 보고 "이 함수가 뭘 하는지"를 이해한다.
타입이 없으면 AI가 추측하고, 추측은 버그가 된다.
타입이 있으면 AI가 정확한 코드를 생성한다.

**투자 대비 효과가 가장 높은 코딩 습관이 타입 명시다.**

### Python 타입 규칙

```python
# ──────────────────────────────────
# Rule 1: 모든 함수에 타입 힌트
# ──────────────────────────────────

# Bad
def calculate_signal(data, phases):
    ...

# Good
def calculate_signal(data: MarketData, phases: FractalPhases) -> Signal:
    ...


# ──────────────────────────────────
# Rule 2: dataclass(frozen=True) 기본
# ──────────────────────────────────

# Bad — mutable, 어디서든 값이 바뀔 수 있음
class Signal:
    def __init__(self, action, confidence):
        self.action = action
        self.confidence = confidence

# Good — immutable, 예측 가능
@dataclass(frozen=True)
class Signal:
    action: Literal["buy", "sell", "hold"]
    confidence: float
    phase: Phase
    timestamp: datetime = field(default_factory=datetime.now)

# 주의: frozen=True는 값 객체(Value Object)에 사용.
# ORM 모델이나 상태 변경이 필요한 엔티티에는 일반 dataclass를 쓴다.


# ──────────────────────────────────
# Rule 3: Literal로 문자열 범위 제한
# ──────────────────────────────────

# Bad — typo 가능 ("Buy", "BUY", "buying" 등)
action: str

# Good — 3개 값만 허용, AI도 이해함
action: Literal["buy", "sell", "hold"]


# ──────────────────────────────────
# Rule 4: Optional 대신 | None
# ──────────────────────────────────

# Old style
from typing import Optional
detailed_phase: Optional[DetailedPhase]

# Modern (Python 3.10+)
detailed_phase: DetailedPhase | None = None


# ──────────────────────────────────
# Rule 5: TypeAlias로 복잡한 타입에 이름 붙이기
# ──────────────────────────────────

from typing import TypeAlias

PhaseMap: TypeAlias = dict[Timeframe, Phase]
PriceHistory: TypeAlias = list[float]

def analyze_markets(symbols: list[str], history: PriceHistory) -> PhaseMap:
    ...
```

### TypeScript 타입 규칙

```typescript
// Rule 1: interface로 API 응답 타입 정의
interface Signal {
  action: "buy" | "sell" | "hold"
  confidence: number
  phase: "gold" | "water" | "wood" | "fire"
  reason: string
}

// Rule 2: Props에 항상 타입 정의
interface PhaseIndicatorProps {
  phase: Signal["phase"]
  size?: "sm" | "md" | "lg"
  showDetail?: boolean
}

function PhaseIndicator({ phase, size = "md", showDetail = false }: PhaseIndicatorProps) {
  ...
}

// Rule 3: as 캐스팅 금지, type guard 사용
// Bad
const data = response as PhaseResponse

// Good
function isPhaseResponse(data: unknown): data is PhaseResponse {
  return typeof data === "object" && data !== null && "phase" in data
}
```

### 타입 체크 설정

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
disallow_untyped_defs = true
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true
  }
}
```

---

## 3. Contract-First Development

> 바이브 코딩의 핵심 패턴. 이 템플릿의 `--rigor production|enterprise`가 이 방식을 강제한다.

### 개요

```
사람이 하는 것:     계약 정의 (ABC, 인터페이스, 타입)
AI가 하는 것:       구현 + 테스트 생성
사람이 확인하는 것:  AI 결과물이 계약을 지키는가
```

### 워크플로우 (5단계)

```
Step 1: 계약 정의          — 사람 (도메인 지식 필요)
Step 2: 테스트 생성 요청    — AI에게 시킴
Step 3: 테스트 리뷰         — 사람이 빠뜨린 케이스 확인
Step 4: 구현 요청           — AI에게 시킴
Step 5: 테스트 통과 확인    — 자동화 (pytest / vitest)
```

### 실전 예시: 새 어댑터 추가

**Step 1 (사람):** contracts.py에 인터페이스 추가

```python
class MarketDataProvider(ABC):
    """시세 데이터 수집기"""

    @abstractmethod
    async def fetch(self, symbol: str, timeframe: Timeframe) -> MarketData: ...

    @abstractmethod
    async def fetch_multi(self, symbols: list[str], timeframe: Timeframe) -> list[MarketData]: ...

    @abstractmethod
    async def health_check(self) -> bool: ...
```

**Step 2 (AI에게):** Claude Code 프롬프트

```
"backend/core/contracts.py의 MarketDataProvider 인터페이스에 대한
계약 테스트를 tests/adapters/test_market_data_contract.py에 작성해줘.

검증할 것:
1. fetch()는 MarketData를 리턴
2. fetch()의 리턴값에 prices, volumes가 비어있지 않음
3. fetch_multi()는 요청한 symbol 수만큼 결과를 리턴
4. health_check()는 bool을 리턴
5. 존재하지 않는 symbol에 대해 적절한 예외 발생

conftest.py에 mock fixture 만들어줘."
```

**Step 3 (사람):** 생성된 테스트 리뷰 — "타임프레임 변환 테스트가 빠졌네" 추가 요청

**Step 4 (AI에게):**

```
"MarketDataProvider 인터페이스를 구현하는 한국투자증권 API 어댑터를
backend/adapters/market_data/kis.py에 만들어줘.
httpx async client 사용하고, 모든 테스트를 통과하게 해줘."
```

**Step 5:** `pytest tests/adapters/` 실행 — 전부 통과 확인

### contracts.py 관리 규칙

- **이 파일은 사람만 수정한다.** AI에게 contracts.py 수정을 시키지 않는다.
- contracts.py는 시스템의 "헌법" — 모든 구현체가 이 계약을 따른다.
- 계약은 "최소한"만 정의. 구현 디테일을 계약에 넣지 않는다.

---

## 4. 테스트 전략

### 테스트 피라미드 — 바이브 코딩 버전

```
         /  E2E  \           <- 3~5개만 (핵심 플로우)
        / 통합 테스트 \        <- API 라우터 + DB
       / 계약 테스트    \       <- 인터페이스 준수 검증 (핵심)
      / 단위 테스트       \      <- 순수 함수, 모델 validation
     ──────────────────────
      타입 체크 (mypy/tsc)     <- 무료로 얻는 안전망
```

**바이브 코딩에서 가장 ROI 높은 테스트 = 계약 테스트 + 타입 체크**

### 무엇을 테스트하고, 무엇을 안 하는가

**반드시 테스트 (돈/데이터에 직결):**
- 인터페이스 계약 — 리턴 타입, 값 범위
- Signal 생성 — action이 유효한가, confidence 범위
- 주문 실행 어댑터 — 실수로 잘못된 주문이 나가면 돈을 잃음
- 데이터 파싱 — API 응답이 바뀌면 전체가 깨짐

**하면 좋음:**
- API 라우터 응답 형태
- 프론트 핵심 컴포넌트 렌더링
- 데이터 훅

**안 해도 됨 (1인 체제에서):**
- 스타일/레이아웃 테스트
- E2E 전체 커버리지
- 뻔한 CRUD 로직
- getter/setter

### conftest.py 예시

```python
# tests/conftest.py
import pytest
from datetime import datetime

@pytest.fixture
def mock_market_data() -> MarketData:
    return MarketData(
        symbol="005930",
        timeframe=Timeframe.MID,
        prices=[70000.0, 71000.0, 69500.0, 72000.0, 71500.0],
        volumes=[1000000, 1200000, 800000, 1500000, 1100000],
        timestamp=datetime(2025, 3, 11, 9, 0, 0),
    )
```

### AI에게 테스트 시키는 프롬프트 패턴

```
"{contracts.py 경로}를 읽고,
{ClassName} 인터페이스의 계약 테스트를 {테스트 경로}에 작성해줘.

검증할 것:
1. (구체적 조건)
2. (구체적 조건)
3. (구체적 조건)

conftest.py의 기존 fixture를 활용하고,
새 fixture가 필요하면 conftest.py에 추가해줘."
```

---

## 5. 에러 핸들링

### 커스텀 예외 계층

```python
# core/exceptions.py

class AppError(Exception):
    """모든 앱 예외의 베이스"""
    pass

class DomainError(AppError):
    """도메인 로직 실패"""
    pass

class AdapterError(AppError):
    """외부 시스템 연결 실패"""
    pass

class ConfigError(AppError):
    """설정/환경변수 문제"""
    pass
```

### 규칙

- 외부 라이브러리 예외를 그대로 올리지 않는다 — 커스텀 예외로 감싼다
- 치명적 에러(주문 실패 등)는 발생 즉시 알림 + 로그
- `try: ... except: pass` 절대 금지 — 에러를 삼키면 원인 추적 불가

---

## 6. 로깅

### 표준 설정

```python
import logging
import sys

def setup_logging(debug: bool = False) -> None:
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler("logs/app.log", encoding="utf-8"),
        ],
    )
```

### 규칙

- `print()` 대신 `logging` 모듈 사용
- 모듈별 logger: `logger = logging.getLogger(__name__)`
- 외부 API 호출은 요청/응답 시간을 로깅

---

## 7. Docker

### docker-compose.yml 표준

```yaml
# 원커맨드 실행: docker compose up
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: ${DB_PASSWORD:-dev_password}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  api:
    build:
      context: .
      dockerfile: backend/Dockerfile
    ports:
      - "8000:8000"
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  web:
    build:
      context: .
      dockerfile: frontend/Dockerfile
    ports:
      - "3000:3000"
    depends_on:
      - api

volumes:
  pgdata:
```

### 규칙

- `docker compose up` 한 방으로 전체 시스템이 떠야 한다
- 시크릿 데이터는 볼륨 마운트 — 이미지에 포함시키지 않는다
- `.env`로 환경별 설정 전환 (dev/staging/prod)

---

## 8. CI/CD

### GitHub Actions 최소 구성

```yaml
# .github/workflows/ci.yml
name: CI
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e ".[dev]"
      - run: mypy backend/          # 타입 체크
      - run: ruff check backend/    # 린트
      - run: pytest tests/ -v       # 테스트

  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: cd frontend && pnpm install
      - run: cd frontend && pnpm tsc --noEmit   # 타입 체크
      - run: cd frontend && pnpm biome check .   # 린트
      - run: cd frontend && pnpm test            # 테스트
```

**이 세 가지(타입 체크 + 린트 + 테스트)만 돌려도 바이브 코딩의 안전망으로 충분하다.**

---

## 9. AI에게 잘 시키는 법

### Bad vs Good 프롬프트

```
# Bad — AI가 추측해야 함
"국면 판정 기능 만들어줘"

# Good — 추측할 게 없음
"backend/core/contracts.py의 PhaseEngine.detect_phase()를 구현하는
DefaultPhaseEngine을 backend/core/default_engine.py에 만들어줘.

입력: MarketData (prices, volumes 리스트)
로직: 20일 이동평균 대비 현재가 위치로 4국면 판정
  - 현재가 > MA20 * 1.05 -> FIRE
  - 현재가 > MA20 -> WOOD
  - 현재가 > MA20 * 0.95 -> GOLD
  - 현재가 <= MA20 * 0.95 -> WATER
리턴: Phase enum

타입 힌트 필수, docstring 영어로."
```

**차이점:** 입력/출력 타입, 구체적 로직, 파일 위치, 코딩 규칙을 전부 명시.

### AI 코드 리뷰 체크리스트

AI가 코드를 생성하면, 이것만 확인:

```
[] 타입 힌트가 빠진 곳 없는가?
[] .env나 secrets가 하드코딩되지 않았는가?
[] 기존 core/ 코드를 수정하지 않았는가? (확장만 했는가?)
[] import 경로가 맞는가?
[] 에러 핸들링이 있는가? (특히 외부 API 호출)
[] 로깅이 적절한가?
```

### 대규모 변경 시 프롬프트 패턴

```
"이 작업을 하기 전에 먼저:
1. 영향받는 파일 목록을 보여줘
2. 각 파일에서 뭘 바꿀지 계획을 설명해줘
3. 내가 확인한 후에 실행해

절대 하지 말 것:
- core/contracts.py 수정
- .gitignore 항목 제거
- 기존 테스트 삭제"
```

---

## 10. 보안 코딩

```python
# 1. 환경변수로 시크릿 관리
api_key = os.getenv("API_KEY")       # Good
api_key = "abc123"                    # 절대 금지

# 2. SQL Injection 방지
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))    # Good
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")         # 절대 금지

# 3. Input Validation
from pydantic import BaseModel, Field

class UserRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: str = Field(pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
```

---

## 11. 의존성 방향 (아키텍처)

```
core/ <- adapters/ <- api/
  ^
 pro/
```

- `core/`는 아무것도 import하지 않는다 (외부 의존성 ZERO)
- `adapters/`는 `core/`의 인터페이스를 구현한다
- `api/`는 `adapters/`와 `core/`를 조합한다

**이 규칙을 지키면:** core/를 건드리지 않고 어댑터를 교체할 수 있고, API 레이어를 바꿔도 엔진은 영향 없다.

### 의존성 주입 (DI) 패턴

```python
# dependencies.py
from functools import lru_cache

def get_engine() -> PhaseEngine:
    """전략 엔진 로드. 로컬 전략이 있으면 우선 사용."""
    try:
        from strategies_local.v1 import CustomEngine
        return CustomEngine()
    except ImportError:
        from core.default_engine import DefaultEngine
        return DefaultEngine()
```

> **주의:** `lru_cache`를 DI에 쓸 경우 테스트에서 mock 교체가 어렵다.
> FastAPI라면 `app.dependency_overrides`로 교체하거나,
> 테스트 시 `get_engine.cache_clear()`를 호출해야 한다.

---

## 12. 핵심 문구

```
"타입이 곧 명세서다."
"contracts.py는 사람만 수정한다."
"core/는 수정하지 말고 확장만 한다."
"AI에게 추측하게 하지 마라 — 전부 명시해라."
"3번 복붙되면 추출한다."
"먼저 동작하게, 그다음 올바르게, 마지막에 빠르게."
"6개월 뒤의 내가 이해 못 하면 잘못 짠 코드다."
"테스트는 계약을 검증한다 — 구현을 검증하지 않는다."
"Done is better than perfect."
```
