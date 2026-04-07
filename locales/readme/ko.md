# Claude Project Template

[English documentation](README.md)

**1인 개발자 전용** lean 템플릿. 메인 도구는 **Claude Code**, 보조는 **Codex** (보일러플레이트용).

team 모드도, 멀티세션 티켓 보드도, setup 스크립트도 없습니다. 클론 → Claude Code 실행 → `/init` → 작업 시작.

## 포함 내용

### Claude Code 설정 (`.claude/`)
- **commands/** — 슬래시 명령어 (`/init`, `/tasks`, `/plan`, `/phase-check`, `/review`, `/spec`, `/newfile`, `/cleanup`)
- **skills/** — 재사용 가능한 작업 패턴 (`read-first`, `self-verify`, `tdd-loop`)
- **agents/** — 서브에이전트 정의 (`code-reviewer`)
- **hooks/** — 자동 컨텍스트 로더 (`session-start.sh`, `pre-compact.sh`) + rigor 별 pre-commit 검사
- **settings.json** — 허용/차단 명령 정책 + 훅 등록

### AI 도구 공통 계약 (`AGENTS.md`)
- Claude Code, Codex, 그 외 어떤 AI 도구에도 적용되는 공통 운영 규칙

### Codex 설정 (`.codex/`)
- **AGENTS.md** — Codex 어댑터 규칙
- **config.toml** — 프로젝트 로컬 Codex 프로필
- **agents/** — 역할 프롬프트 (`explorer`, `reviewer`, `feature-worker`)

### GitHub 자동화 (`.github/`)
- **workflows/** — 자동 라벨링, 보드 동기화, stale 이슈 정리
- **workflows/codex-pr-review.yml** — Codex PR 자동 리뷰 (comment/report-only)
- **ISSUE_TEMPLATE/** — Feature, bug, task 템플릿
- **PULL_REQUEST_TEMPLATE.md** — PR 체크리스트
- **GIT_WORKFLOW.md** — 브랜치/커밋/이슈/PR 규칙

### 프로젝트 기반 파일
- **CLAUDE.md** — 1인 개발 규칙 + Claude Code/Codex 도구 분업
- **PLAN.md** — Phase 기반 로드맵 템플릿
- **docs/RIGOR.md** — 엔지니어링 깊이 프리셋 (mvp/production/enterprise)
- **.gitignore** — Python, Node, Go, Rust, Docker, IDE, OS 기본값

## 사용법

### 1) 템플릿으로 새 저장소 생성

GitHub에서 **Use this template** → **Create a new repository**.

### 2) 클론 + Claude Code 실행

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
claude
```

### 3) `/init` 실행

Claude Code 안에서:

```
/init
```

Claude가 다음을 물어봅니다:
- 프로젝트 이름 + 한 줄 설명
- 프로젝트 유형 (`general`, `web`, `cli`, `security`, `ml`, `scada`, `quant`)
- 엔지니어링 깊이 (`mvp`, `production`, `enterprise`)
- 기술스택 (있으면)

대답하면 디렉토리 구조 생성, `.project-config` 작성, PLAN.md 초기화, rigor 안내까지 한 번에.

### 4) 작업 시작

`SessionStart` 훅이 매 세션마다 PLAN.md, MISTAKES.md, 최근 스냅샷, Git 상태를 자동으로 컨텍스트에 로드합니다. Claude Code 열고 바로 작업하면 됩니다.

## Rigor 레벨

`.project-config`에 한 줄로 설정:

```
PROJECT_RIGOR=mvp        # 속도 우선, 타입/테스트 선택
PROJECT_RIGOR=production # Contract-First, 함수 시그니처 타입 + 핵심 모듈 테스트
PROJECT_RIGOR=enterprise # Full strict, TDD, Clean Architecture
```

`pre-commit` 훅이 이 값을 읽어 검사 강도를 조절합니다. 자세한 규칙은 [docs/RIGOR.md](docs/RIGOR.md).

## 도구 분업 (Claude Code / Codex)

| 도구 | 역할 | 적합한 작업 |
|------|------|------------|
| **Claude Code (CC)** | 메인 — 설계 + 구현 + 리뷰 | 거의 모든 작업. 설계, 멀티파일 변경, 디버깅, 리팩토링 |
| **Codex** | 보조 — 자잘한 구현 | 보일러플레이트, 단일 파일 함수, 반복 패턴. CC의 토큰을 아낄 때만 사용. CC가 결과를 반드시 읽고 자가 검증 |

## 커스터마이징 포인트

| 파일 | 수정 포인트 |
|------|-------------|
| `CLAUDE.md` | 프로젝트 규칙, 용어, 스택 |
| `AGENTS.md` | AI 도구 공통 계약 |
| `.codex/config.toml` | Codex 런타임 프로필 |
| `.project-config` | rigor 스위치 (hooks 참조) |
| `.claude/settings.json` | 허용/차단 명령 정책 + 훅 등록 |
| `.claude/commands/*.md` | 슬래시 명령어 |
| `.claude/skills/*` | 프로젝트 고유 재사용 패턴 |
| `.github/ISSUE_TEMPLATE/*.yml` | 이슈 폼 |
| `.github/GIT_WORKFLOW.md` | 브랜치/릴리즈 규칙 |

## 문서 구조

```
CLAUDE.md                    <- 메인 프로젝트 규칙
AGENTS.md                    <- AI 도구 공통 계약
PLAN.md                      <- Phase 기반 로드맵
docs/
  RIGOR.md                   <- mvp/production/enterprise 규칙
  QUICKSTART.md              <- 빠른 시작 가이드
  METHODOLOGY.md             <- 코딩 방법론
  CHECKLISTS.md              <- 체크리스트
.codex/
  AGENTS.md                  <- Codex 어댑터 규칙
  config.toml                <- Codex 런타임 설정
  agents/                    <- Codex 역할 프롬프트
.work/
  MISTAKES.md                <- 오답 노트 (SessionStart 훅이 자동 로드)
  decisions/                 <- ADR (아키텍처 결정 기록)
  snapshots/                 <- PreCompact 훅이 자동 저장
.github/
  GIT_WORKFLOW.md            <- Git/PR/이슈 규칙
```

## 요구사항

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh auth login` 완료)
- (선택) [Codex CLI](https://github.com/openai/codex) — 보일러플레이트 위임용
- (선택) Python: `ruff`, `mypy`
- (선택) JavaScript/TypeScript: `prettier`, `eslint`
- (선택) Go: `gofmt`, `go vet`
- (선택) Rust: `cargo clippy`, `cargo fmt`
