# Claude Project Template

[English documentation](README.md)

**Claude Code + Codex + GitHub 자동화**를 함께 운용할 수 있는 범용 개발 템플릿입니다.
해커톤, 서비스 개발, SCADA, 퀀트 트레이딩, 보안 실습 등 다양한 프로젝트에 사용할 수 있습니다.

## 포함 내용

### Claude Code 설정 (`.claude/`)
- **commands/** — 슬래시 명령어 13개 (`/start`, `/end`, `/claim`, `/tasks`, `/plan`, `/review`, `/session`, `/sync`, `/handoff`, `/spec`, `/newfile`, `/cleanup`, `/phase-check`)
- **hooks/** — rigor 레벨별 pre-commit 검사, 멀티 언어 lint/format 훅
- **settings.json** — 기본 허용/차단 명령 정책 (Python, Node, Go, Rust, Docker, Make 등)

### 공통 에이전트 계약 (`AGENTS.md`, `docs/steering/`)
- **AGENTS.md** — 도구 공통 운영 계약 (SWMR: Single Writer, Many Reviewers)
- **docs/steering/** — 저장소 계약, 쓰기 경계, 리뷰 게이트, 핫스팟 정책

### Codex 설정 (`.codex/`)
- **AGENTS.md** — Codex 전용 보충 규칙 (execution/audit 모드)
- **config.toml** — 프로젝트 로컬 Codex 실행 프로필
- **agents/** — 역할 프롬프트 (`explorer`, `reviewer`, `feature-worker`)

### GitHub 자동화 (`.github/`)
- **workflows/** — PR 라벨링, 보드 연동, stale 이슈 정리
- **workflows/codex-pr-review.yml** — Codex PR 자동 리뷰 (comment/report-first)
- **ISSUE_TEMPLATE/** — Feature Request, Bug Report, Task 템플릿
- **PULL_REQUEST_TEMPLATE.md** — PR 체크리스트
- **GIT_WORKFLOW.md** — 브랜치/커밋/이슈/PR 규칙

### 프로젝트 기반 파일
- **CLAUDE.md** — 프로젝트 규칙 (mode/rigor/domain 기반)
- **PLAN.md** — 구현 계획 템플릿
- **.gitignore** — Python, Node, Go, Rust, Docker, IDE, OS 기본 + 도메인 확장

## 사용법

### 1) 템플릿으로 새 저장소 생성

GitHub에서 **Use this template** → **Create a new repository**를 선택합니다.

### 2) 클론 및 초기화

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
chmod +x setup.sh init-labels.sh
```

### 3) setup 실행

```bash
./setup.sh <project-name> <github-username> [options]
```

#### 실행 예시

```bash
# 해커톤 (빠른 시작)
./setup.sh hackathon dhchoi98 --type web --rigor mvp

# SCADA 납품 (엔터프라이즈 품질)
./setup.sh scada-hmi dhchoi98 --type scada --rigor enterprise --mode team

# 퀀트 트레이딩 (프로덕션 품질, Contract-First)
./setup.sh quant-bot dhchoi98 --type quant --rigor production

# 보안 실습 / CTF
./setup.sh ctf-2026 dhchoi98 --type security --rigor mvp

# ML 프로젝트
./setup.sh ml-project dhchoi98 --type ml --rigor production

# 팀 프로젝트 (5세션 병렬)
./setup.sh my-service dhchoi98 --type web --rigor production --mode team
```

### 옵션 설명

#### 프로젝트 유형 (`--type`)

| 유형 | 생성 디렉토리 | 용도 |
|------|----------------|------|
| `general` (기본) | `src/ tests/ docs/` | 범용 프로젝트 |
| `web` | `backend/ frontend/ shared/ docs/ tests/` | 웹 서비스 |
| `cli` | `cmd/ internal/ docs/ tests/` | CLI/시스템 도구 |
| `security` | `tools/ exploits/ notes/ reports/` | CTF, 보안 실습, 펜테스트 |
| `ml` | `notebooks/ data/ models/ src/ tests/` | ML/AI 프로젝트 |
| `scada` | `backend/ hmi/ plc/ drivers/ docs/ tests/` | 산업제어, SCADA/HMI |
| `quant` | `core/ strategies/ data/ dashboard/ tests/` | 퀀트 트레이딩, 금융 |

#### 엔지니어링 엄격도 (`--rigor`)

| rigor | 타입 규칙 | 테스트 | 아키텍처 | 적합한 상황 |
|------|-----------|--------|----------|--------------|
| `mvp` (기본) | 권장(선택) | 선택 | 유연 | 해커톤, PoC |
| `production` | 함수 시그니처 필수 | 핵심 모듈 필수 | Contract-First, 레이어 분리 | 실서비스 |
| `enterprise` | 변수 포함 강한 타입 규칙 | TDD + 커버리지 목표 | Clean Architecture, DIP | 장기/대규모 시스템 |

#### Contract-First 워크플로우 (production/enterprise)

```
1단계: 계약 정의 (사람 주도)
  → 인터페이스/프로토콜, 타입, 데이터 모델

2단계: 테스트 작성 (AI 보조)
  → "이 인터페이스 계약 테스트를 작성해줘"

3단계: 구현 (AI 보조)
  → "이 테스트를 통과하는 구현을 작성해줘"
```

#### 워크플로우 모드 (`--mode`)

| 모드 | 설명 |
|------|------|
| `solo` (기본) | 1인 개발, plan 모드 선택, 티켓 시스템 없음 |
| `team` | 멀티세션 병렬 개발, 5세션 티켓 워크플로우, plan 모드 필수 |

### 4) GitHub 라벨 생성

```bash
./init-labels.sh
```

### 5) 정리 및 첫 커밋

```bash
rm setup.sh init-labels.sh
# 프로젝트에 맞게 CLAUDE.md, PLAN.md를 수정
git add -A && git commit -m "chore: initial project setup"
```

## 커스터마이징 포인트

| 파일 | 수정 포인트 |
|------|-------------|
| `AGENTS.md` | 도구 공통 운영 계약, SWMR 정책 |
| `CLAUDE.md` | 프로젝트 용어, 아키텍처, 스택, 강제 규칙 |
| `.codex/config.toml` | Codex 실행 정책, 프로필, 역할 매핑 |
| `.project-config` | rigor/mode 스위치 (hooks 참조) |
| `.claude/settings.json` | 명령 허용/차단 정책 |
| `.claude/commands/*.md` | 프로젝트 맞춤 명령 |
| `.github/ISSUE_TEMPLATE/*.yml` | 이슈 폼 항목/드롭다운 |
| `.github/GIT_WORKFLOW.md` | 브랜치/릴리즈 정책 |

## 문서 구조

```
AGENTS.md                    <- 모든 AI 도구 공통 계약
CLAUDE.md                    <- Claude 전용 보충 지침
PLAN.md                      <- 계획 템플릿
docs/
  steering/
    repo-contract.md         <- 저장소 운영 계약
    write-boundaries.yaml    <- 쓰기 경계 규칙
    review-gates.yaml        <- 품질 게이트
    hotspot-files.yaml       <- 고충돌 파일 정책
  QUICKSTART.md              <- 빠른 시작 + 학습 가이드
  METHODOLOGY.md             <- 코딩 방법론
  CHECKLISTS.md              <- 체크리스트
.codex/
  AGENTS.md                  <- Codex 보충 규칙
  config.toml                <- Codex 실행 설정
  agents/                    <- Codex 역할 프롬프트
.work/
  BOARD.md                   <- 티켓 보드 (team 모드)
  WORKFLOW_GUIDE.md          <- 멀티세션 운영 가이드
  MISTAKES.md                <- 오답 노트
.github/
  GIT_WORKFLOW.md            <- Git/PR/이슈 규칙
```

## 요구사항

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh auth login` 완료)
- (선택) Python: `ruff`, `mypy`
- (선택) JavaScript/TypeScript: `prettier`, `eslint`
- (선택) Go: `gofmt`, `go vet`
- (선택) Rust: `cargo clippy`, `cargo fmt`
