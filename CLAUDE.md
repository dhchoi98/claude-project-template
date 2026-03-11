# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

---

## 절대규칙 (모든 세션이 반드시 따를 것)

### 1. 읽기 우선 (Read-First)
- **코드 변경 전 반드시** 관련 파일과 아키텍처를 먼저 읽는다.
- 최소한 다음을 확인: 이 파일의 CLAUDE.md → 관련 모듈 → 호출하는/호출되는 코드
- 모르는 코드베이스에서 추측으로 코드를 쓰지 않는다.

### 2. Plan 모드 ({{PROJECT_MODE}} mode)
<!-- solo: 복잡한 변경에만 Plan 모드 권장. 간단한 수정은 바로 진행 가능. -->
<!-- team: 항상 Plan 모드에서 계획을 먼저 제시하고 승인을 받는다. -->
- **team 모드**: 항상 Plan 모드에서 계획을 먼저 제시하고 승인을 받는다.
- **solo 모드**: 복잡한 변경은 Plan 모드 권장. 간단한 수정은 바로 진행 가능.
- Plan에 포함할 것: 변경 대상 파일, 변경 이유, 예상 영향 범위, 리스크
- 승인 후 auto-accept로 구현을 진행한다.

### 3. 최소 변경 (Simple & Minimal Impact)
- 변경은 **최대한 작고 단순하게** 유지한다.
- 하나의 작업 = 하나의 관심사. 여러 기능을 한 번에 섞지 않는다.
- "이왕 하는 김에" 식의 추가 리팩토링, 추가 기능은 하지 않는다.

### 4. 자가 검증 루프 (Self-Verification)
- 작업 완료 전 **반드시 스스로 검증**한다:
  - 테스트 실행 (있으면)
  - 빌드 확인 (있으면)
  - 린트 확인 (있으면)
- 검증 실패 시 직접 수정하고 다시 검증한다. 사용자에게 깨진 코드를 넘기지 않는다.

### 5. Git/GitHub 금지
- 커밋, 푸시, PR, 브랜치 생성/삭제, merge 등 **모든 Git/GitHub 행동은 사용자가 명시적으로 지시할 때만** 수행한다.

### 6. 기본 코드 규칙
- **Docstring**: 모든 파일 최상단에 목적 기술 (Python: `"""..."""`, TS/JS: `/** */`, Go: `// Package ...`, Rust: `//! ...`)
- **API키**: 하드코딩 금지. 환경변수(`.env`) → 설정 모듈 → 참조
- **타입**: `.project-config`의 rigor 수준에 따름 (아래 엔지니어링 규칙 참조)
- **코드변경**: 해당 폴더 CLAUDE.md 먼저 읽기. 새 파일 시 CLAUDE.md 갱신.

---

## 워크플로우

> **현재 모드: {{PROJECT_MODE}}** | **엔지니어링 깊이: {{PROJECT_RIGOR}}**
> setup.sh에서 `--mode solo|team`, `--rigor mvp|production|enterprise`로 설정됨.

### Solo 모드 (1인 개발)

간단하고 빠른 워크플로우:

1. PLAN.md에서 다음 할 일 확인
2. 필요하면 Plan 모드로 계획 수립 (선택적)
3. 구현
4. 자가 검증 (테스트/빌드/린트)
5. 완료 시 PLAN.md 상태 업데이트

### Team 모드 (멀티세션 병렬)

> 최대 5개의 로컬 세션이 독립적인 티켓을 병렬로 처리한다.
> 각 세션은 고정된 역할이 아니라 **할당된 티켓**에 집중한다.

#### 세션 생명주기

```
/start
  ├─ BOARD.md 읽기 (현재 상황 파악)
  ├─ 핸드오프 읽기 (이전 세션 작업 파악)
  ├─ 세션 번호 결정 (S1~S5 중 idle)
  └─ 클레임 가능한 티켓 추천
      │
/claim T{XXX}
  └─ 티켓 클레임 + BOARD 업데이트
      │
Plan 모드 → 계획 제시 → 사용자 승인
      │
구현 (auto-accept)
      │
자가 검증 (테스트/빌드/린트)
      │
/review → 변경사항 리뷰
      │
/end
  ├─ 핸드오프 문서 작성
  ├─ BOARD.md 업데이트
  └─ (Git 작업 안 함)
```

#### 핵심 규칙

1. **티켓 기반 작업**: 각 세션은 BOARD.md에서 하나의 티켓을 클레임하고 그것만 한다.
2. **파일 소유권**: 클레임한 티켓의 `파일 범위`에 명시된 파일만 수정한다. 다른 세션 소유 파일 수정 금지.
3. **핸드오프 필수**: 세션 종료 시 다음 세션이 이어받을 수 있도록 인수인계 문서를 남긴다.
4. **충돌 방지**: 티켓 설계 시 파일 범위가 겹치지 않도록 쪼갠다.

---

## 도구 분업 (CC / Cursor)

> Cursor를 사용하지 않으면 이 섹션은 무시하고, CC와 Any 티켓만 작업한다.

티켓마다 `도구` 컬럼으로 어느 도구에서 작업할지 지정한다.

| 도구 | 역할 | 모델/모드 | 과금 | 적합한 작업 |
|------|------|----------|------|------------|
| `CC` | 수석 아키텍트 | Claude Code (터미널) | API 종량제 | 설계, 디자인 패턴, 멀티파일 구조 변경, 복잡한 로직, 스켈레톤/인터페이스 생성 |
| `Auto` | 시공반장 (Cursor Auto) | Auto 모드 (기본) | **무제한** (Pro $20 포함) | 구현체 채우기, 비즈니스 로직, API, UI, 문법 수정, 보일러플레이트, 반복 작업 |
| `Premium` | 트러블슈터 (Cursor Premium) | Claude/GPT-4.5 수동 선택 | 기본 크레딧 차감 | 복잡한 에러 분석, 멀티파일 참조 테스트, 고난이도 디버깅 |
| `MAX` | 대공사 (Cursor MAX) | MAX Mode | **추가 과금** (사용 후 즉시 끌 것) | 전면 리팩토링, 대규모 마이그레이션 (주의 필요) |
| `BG` | 백그라운드 워커 (--teleport) | CC 웹 세션 | API 종량제 | 코드 분석, 대량 문서화, 보안 스캔 등 장시간 비동기 작업 |
| `Any` | 무관 | — | — | 어느 도구든 가능한 작업 |

**CC 세션은 `CC`/`Any` 티켓만 클레임한다. `Auto`/`Premium`/`MAX`/`BG` 티켓은 건너뛴다.**

> **비용 최적화 원칙**: Auto를 기본으로 쓰고 → 막히면 잠깐 Premium → 해결되면 다시 Auto. MAX는 정말 필요할 때만.

### Contract-First 분업 패턴 (production/enterprise)

CC가 설계+테스트까지 잡아주면, Cursor Auto는 테스트라는 정답지를 보고 구현한다.

```
CC 티켓 (설계+계약)          Auto 티켓 (구현)              비고
─────────────────────────   ──────────────────────────   ──────────────
T001 CC  인터페이스 정의      T002 Auto 구현체 작성         T001 → T002 의존
  → ABC/Protocol 정의          → 테스트 통과시키기
  → 타입, 데이터 모델           → Red→Green 반복
  → 계약 테스트 작성            → (Auto 무제한이라 부담 없음)
```

**티켓 설계 예시:**
```
T001 CC   "주문 엔진 인터페이스 + 계약 테스트"   파일: core/engine.py, tests/core/test_engine.py
T002 Auto "주문 엔진 구현체"                    파일: core/engine_impl.py         의존: T001
T003 CC   "브로커 어댑터 인터페이스 + 테스트"     파일: adapters/broker.py, tests/adapters/test_broker.py
T004 Auto "바이낸스 브로커 구현"                 파일: adapters/binance.py         의존: T003
```

**CC에서 테스트까지 작성하는 이유:**
- 인터페이스를 정의한 사람(CC)이 "어떻게 써야 하는지"를 가장 잘 안다
- 테스트가 곧 구현 명세서 → Auto가 읽고 그대로 구현
- Auto가 방향을 잃지 않고, 테스트 통과 = 작업 완료 기준이 명확

---

## 용어

| 용어 | 의미 |
|------|------|
| CC | Claude Code (고난이도 작업 도구) |
| Auto | Cursor Auto 모드 — 시공반장 (무제한 구현) |
| Premium | Cursor Premium — 트러블슈터 (크레딧 차감) |
| MAX | Cursor MAX — 대공사 (추가 과금, 주의) |
| BG | --teleport 백그라운드 웹 세션 (장시간 비동기) |
| 세션(S{N}) | 하나의 Claude Code 인스턴스 (S1~S5, team 모드) |
| 티켓(T{XXX}) | BOARD에 등록된 독립적 작업 단위 (team 모드) |
| 클레임 | 티켓을 자기 세션에 배정하는 행위 (team 모드) |
| 핸드오프 | 세션 종료 시 다음 세션을 위한 인수인계 문서 (team 모드) |
| — | 프로젝트 고유 용어를 여기에 추가 |

## 구조

```
# 프로젝트 유형별 (setup.sh --type 으로 결정)
# general:  src/ tests/ docs/
# web:      backend/ frontend/ shared/ docs/ tests/
# cli:      cmd/ internal/ docs/ tests/
# security: tools/ exploits/ notes/ reports/
# ml:       notebooks/ data/ models/ src/ tests/
# scada:    backend/ hmi/ plc/ drivers/ docs/ tests/
# quant:    core/ strategies/ data/ dashboard/ tests/

.work/                — 세션 조율 허브 (team 모드)
  BOARD.md            — 티켓 보드 (단일 진실 공급원)
  handoffs/           — 세션 핸드오프 문서
  decisions/          — 아키텍처 결정 기록 (ADR)
  MISTAKES.md         — 오답 노트 (세션 간 교훈 공유)
.claude/commands/     — 슬래시 명령어
.claude/hooks/        — pre-commit, lint 자동 검사
```

## 기술스택

| 카테고리 | 기술 | 비고 |
|----------|------|------|
| — | — | 프로젝트에 맞게 채우기 |

## 상세 문서

- `PLAN.md` — 전체 개발 로드맵 (Phase별)
- `.work/BOARD.md` — 티켓 보드 (team 모드)
- `.work/WORKFLOW_GUIDE.md` — 멀티세션 운영 가이드
- `.work/MISTAKES.md` — 오답 노트
- `docs/` — 설계 문서

## 현재 상태

PLAN.md 참조. team 모드 시 `.work/BOARD.md`도 확인.

---

## 오답 노트 참조

작업 전 `.work/MISTAKES.md`를 확인하여 이전 세션의 실수를 반복하지 않는다.
