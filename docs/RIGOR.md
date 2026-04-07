# 엔지니어링 깊이 (Rigor)

`.project-config`의 `PROJECT_RIGOR` 값에 따라 Claude가 적용할 규칙이 달라진다.
`.claude/hooks/pre-commit.sh`도 이 값을 읽어서 검사 강도를 조절한다.

| 값 | 상황 | 핵심 |
|----|------|------|
| `mvp` | 해커톤, PoC, 개인 실험 | 속도 우선. 타입/테스트 선택적 |
| `production` | 실제 서비스, 봇, 장기 유지 | Contract-First. 함수 시그니처 타입 + 핵심 모듈 테스트 |
| `enterprise` | 납품, 장기 유지보수 | Full strict. 변수 타입까지. TDD + 커버리지 |

rigor 변경 방법: `.project-config` 파일의 한 줄을 수정하면 끝.

---

## MVP — 속도 우선

> 동작하는 코드를 빠르게 만든다.

### 타입
- Python: 함수 시그니처 타입힌트 **권장** (필수 아님)
- TypeScript: strict 모드 사용
- 복잡한 제네릭/오버엔지니어링 금지

### 테스트
- 테스트 **선택적**. 핵심 비즈니스 로직에만 작성
- 버그 발견 시 회귀 테스트 추가
- E2E 테스트 불필요

### 아키텍처
- 단순 구조 유지. 패턴 강제 없음
- 동작하면 OK. 나중에 리팩토링

---

## Production — Contract-First

> 인터페이스 → 테스트 → 구현 순서.

### Contract-First 워크플로우

```
1단계: 인터페이스 정의
  ABC/Protocol, 타입, 데이터 모델

2단계: 계약 테스트 작성
  "이 인터페이스에 대한 계약 테스트를 작성해줘"

3단계: 구현체 작성
  테스트를 통과시키며 Red→Green 반복
```

> 보일러플레이트 구현은 Codex에 위임할 수 있다. 단, CC가 반드시 결과를 읽고 자가 검증.

### 타입 규칙
- **함수 시그니처 타입 필수**: 모든 함수에 파라미터 + 리턴 타입 명시
- `dataclass(frozen=True)`를 기본 데이터 모델로 사용
- `Literal`, `TypeAlias`, `Generic` 적극 활용
- `Any` 최소화 — 불가피할 때 `# type: ignore` + 사유 주석
- TypeScript: strict 모드 + no-any 린트 규칙

### 테스트 규칙
- **핵심 모듈(`core/`) 테스트 필수**, 나머지 선택적
- 인터페이스 계약 테스트: "이 메서드가 이 타입을 리턴하는가?"
- 비즈니스 로직 테스트: 엣지 케이스 포함
- 어댑터/외부 연동: 파싱/변환 로직만 테스트
- API 라우트: 스모크 테스트 수준
- UI: 테스트 불필요

### 테스트 디렉토리 구조
```
tests/
├── core/         ← 필수: 인터페이스 계약 + 비즈니스 로직
├── adapters/     ← 중요: 외부 API 파싱, 데이터 변환
├── api/          ← 선택: 엔드포인트 스모크 테스트
└── conftest.py   ← 공용 fixture
```

### 아키텍처
- 레이어 분리: `core/` (순수 로직) / `adapters/` (외부 연동) / `api/` (진입점)
- `core`는 외부 의존성 없이 순수 Python/TS로 작성
- 의존성 역전: core가 인터페이스를 정의, adapters가 구현

---

## Enterprise — Full Strict + TDD

> 장기 유지보수를 위한 엔지니어링. 타입/테스트/아키텍처를 엄격하게.

### Contract-First + TDD 워크플로우

```
1단계: 인터페이스 + ADR
  Protocol/ABC, 데이터 모델, 아키텍처 결정 기록(.work/decisions/)

2단계: TDD 테스트 작성 (구현 전에 먼저)
  인터페이스 계약 / 엣지 케이스 / 통합 테스트

3단계: 구현체 작성
  Red → Green → Refactor 사이클
```

### 타입 규칙 (Full Strict)
- **모든 변수, 파라미터, 리턴 타입을 명시적으로 선언**
- `dataclass(frozen=True)`를 기본 데이터 모델로 사용
- `Literal`, `TypeAlias`, `Generic`, `Protocol` 적극 활용
- `Any` **금지** — 반드시 구체적 타입 또는 `TypeVar`
- `cast()` 사용 시 사유 주석 필수
- TypeScript: strict + `noImplicitAny` + `noUncheckedIndexedAccess`
- `pyproject.toml`에 `mypy strict = true` 설정

### 테스트 규칙 (TDD)
- **구현 전에 테스트를 먼저 작성** (Red → Green → Refactor)
- 커버리지 목표: `core/` 90%+, `adapters/` 70%+, 전체 60%+
- 인터페이스 계약 테스트: 타입, 리턴값 범위, 불변 조건 검증
- 비즈니스 로직: 정상/엣지/에러 케이스 모두
- 통합 테스트: 주요 시나리오 흐름
- 버그 수정 시 회귀 테스트 **필수** (먼저 실패하는 테스트 작성)

### 테스트 디렉토리 구조
```
tests/
├── core/          ← 필수: 인터페이스 계약 + 비즈니스 로직 (90%+)
├── adapters/      ← 필수: 외부 API 파싱, 데이터 변환 (70%+)
├── api/           ← 필수: 엔드포인트 + 에러 핸들링
├── integration/   ← 필수: 주요 시나리오 E2E
├── fixtures/      ← 테스트 데이터 (JSON, mock 등)
└── conftest.py    ← 공용 fixture
```

### 아키텍처 (Clean Architecture)
- **엄격한 레이어 분리**:
  - `core/` — 순수 도메인 로직. 외부 의존성 zero
  - `adapters/` — 외부 시스템 연동 (DB, API, 파일 등)
  - `api/` — HTTP/gRPC/CLI 진입점
  - `services/` — 유스케이스 오케스트레이션
- 의존성 방향: `api → services → core ← adapters`
- `core`에 정의된 Protocol/ABC를 `adapters`가 구현 (DIP)
- 모든 외부 의존성은 DI로 주입

### 코드 품질
- 체크리스트: 타입 체크, 테스트, 린트, 자가 리뷰
- 새 모듈 추가 시 ADR 작성 (`.work/decisions/`)
- 성능 민감 코드: 벤치마크 테스트 포함
- 에러 핸들링: 커스텀 예외 클래스, 빈 `except` 금지
