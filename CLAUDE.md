# 프로젝트 운영 규칙

> 1인 개발자 전용. 메인 도구는 **Claude Code**, 보조로 **Codex**.
>
> 새 프로젝트라면 Claude에게 `/init` 을 실행하면 대화로 프로젝트 이름/유형/엄격도/디렉토리 구조를 잡아준다.

---

## 절대규칙

### 1. 읽기 우선 (Read-First)
- 코드 변경 전 관련 파일과 아키텍처를 먼저 읽는다.
- 최소한: 루트 `CLAUDE.md` → 작업 모듈 → 호출하는/호출되는 코드.
- 모르는 코드를 추측으로 쓰지 않는다.
- 자세한 절차: [.claude/skills/read-first/SKILL.md](.claude/skills/read-first/SKILL.md)

### 2. 최소 변경 (Simple & Minimal Impact)
- 변경은 작고 단순하게.
- 하나의 작업 = 하나의 관심사.
- "이왕 하는 김에" 식 추가 리팩토링/추가 기능 금지.

### 3. 자가 검증 루프 (Self-Verification)
- 작업 완료 보고 전 반드시 스스로 검증한다: 테스트 / 빌드 / 린트 / 타입.
- 실패하면 직접 수정하고 다시 검증. 깨진 코드를 사용자에게 넘기지 않는다.
- 자세한 절차: [.claude/skills/self-verify/SKILL.md](.claude/skills/self-verify/SKILL.md)

### 4. Plan 모드 (선택적)
- 복잡한 변경은 Plan 모드 권장. 간단한 수정은 바로 진행 가능.
- Plan에 포함할 것: 변경 대상 파일, 변경 이유, 예상 영향, 리스크.

### 5. Git/GitHub 금지
- 커밋, 푸시, PR, 브랜치 생성/삭제, merge — 사용자가 명시적으로 지시할 때만.

### 6. 기본 코드 규칙
- **Docstring**: 모든 파일 최상단에 목적 기술 (Python `"""..."""`, TS/JS `/** */`, Go `// Package ...`, Rust `//! ...`).
- **API키**: 하드코딩 금지. 환경변수(`.env`) → 설정 모듈 → 참조.
- **타입**: `.project-config`의 rigor 수준에 따름 (아래 엔지니어링 규칙 참조).
- **새 파일/폴더 생성 시**: 해당 폴더 `CLAUDE.md` 갱신.

---

## 워크플로우 (1인 개발)

> **엔지니어링 깊이**: `.project-config`의 `PROJECT_RIGOR=mvp|production|enterprise`로 결정. 자세한 규칙은 [docs/RIGOR.md](docs/RIGOR.md).

```
1. PLAN.md에서 다음 할 일 확인
2. (복잡하면) Plan 모드로 계획 수립
3. 관련 파일 읽기 (Read-First)
4. 구현
5. 자가 검증 (테스트/빌드/린트/타입)
6. PLAN.md 상태 업데이트
```

세션 시작 시 `.claude/hooks/session-start.sh`가 PLAN.md/MISTAKES/Git 상태를 자동 로드한다.
컨텍스트 압축 직전 `.claude/hooks/pre-compact.sh`가 `.work/snapshots/`에 작업 상태를 자동 저장한다.

---

## 도구 분업 (Claude Code / Codex)

| 도구 | 역할 | 적합한 작업 |
|------|------|------------|
| **Claude Code (CC)** | 메인 — 설계 + 구현 + 리뷰 | 거의 모든 작업. 설계, 멀티파일 변경, 디버깅, 코드 리뷰, 리팩토링 |
| **Codex** | 보조 — 자잘한 구현 | 단순 보일러플레이트, 작은 함수 구현, 반복 패턴 채우기. **CC의 토큰을 아끼고 싶을 때만** |

### Codex 호출 패턴

CC 세션 안에서 Codex를 셸로 호출하는 방식:

```bash
codex "이 인터페이스를 통과하는 구현체 작성: <파일 경로>"
```

호출 후 반드시:
1. Codex 결과를 CC가 직접 읽는다 (`Read` 도구)
2. CC가 자가 검증 루프 실행 (테스트/빌드/린트)
3. 문제가 있으면 CC가 직접 수정

> Codex 결과를 검증 없이 신뢰하지 않는다. 책임은 메인 세션(CC)에 있다.

### Codex 사용 기준

- ✅ 200줄 미만의 단일 파일 구현
- ✅ 인터페이스/테스트가 명확히 정의된 구현체
- ✅ 보일러플레이트 (CRUD 라우트, DTO, 마이그레이션)
- ❌ 멀티파일 리팩토링 (CC가 직접)
- ❌ 설계가 필요한 작업 (CC가 직접)
- ❌ 미묘한 버그 수정 (CC가 직접)

---

## 디렉토리 구조

프로젝트 유형은 `/init` 명령으로 결정 (`.project-config`에 저장):

```
general:  src/ tests/ docs/
web:      backend/ frontend/ shared/ docs/ tests/
cli:      cmd/ internal/ docs/ tests/
security: tools/ exploits/ notes/ reports/
ml:       notebooks/ data/ models/ src/ tests/
scada:    backend/ hmi/ plc/ drivers/ docs/ tests/
quant:    core/ strategies/ data/ dashboard/ tests/
```

공통:

```
.claude/
├── settings.json          — 권한 + 훅 등록
├── commands/              — 슬래시 명령어
├── hooks/                 — 자동 검증/컨텍스트 훅
├── skills/                — 재사용 가능한 작업 패턴 (읽고 시작)
└── agents/                — 서브에이전트 정의 (code-reviewer 등)

.work/
├── MISTAKES.md            — 오답 노트 (반복 회피)
├── decisions/             — 아키텍처 결정 기록 (ADR)
└── snapshots/             — 컨텍스트 압축 직전 자동 스냅샷

PLAN.md                    — 개발 로드맵 (Phase별)
.project-config            — 엄격도 (/init 명령이 생성)
```

---

## 기술스택

| 카테고리 | 기술 | 비고 |
|----------|------|------|
| — | — | 프로젝트에 맞게 채우기 |

---

## 상세 문서

- [PLAN.md](PLAN.md) — 개발 로드맵
- [.work/MISTAKES.md](.work/MISTAKES.md) — 오답 노트
- [.claude/skills/](.claude/skills/) — 작업 패턴 (read-first, self-verify, tdd-loop)
- [.claude/agents/](.claude/agents/) — 서브에이전트 (code-reviewer)
- [docs/QUICKSTART.md](docs/QUICKSTART.md) — 템플릿 사용법
- [docs/METHODOLOGY.md](docs/METHODOLOGY.md) — 코딩 방법론

---

## 작업 시작 전 체크

1. `PLAN.md`에서 다음 할 일 확인했는가?
2. `.work/MISTAKES.md`를 한 번 봤는가? (같은 실수 반복 회피)
3. 관련 `.claude/skills/`를 읽었는가?
4. 변경 대상 파일을 **전체** 읽었는가?
