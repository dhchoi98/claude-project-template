# Claude Project Template

Claude Code + GitHub 자동화가 세팅된 범용 프로젝트 템플릿.
해커톤, 서비스 개발, SCADA, 퀀트 트레이딩, 보안 실습 등 다양한 용도로 사용 가능.

## 포함 내용

### Claude Code 설정 (`.claude/`)
- **commands/** — 슬래시 명령어 13개 (`/start`, `/end`, `/claim`, `/tasks`, `/plan`, `/review`, `/session`, `/sync`, `/handoff`, `/spec`, `/newfile`, `/cleanup`, `/phase-check`)
- **hooks/** — pre-commit (rigor 레벨별 자동 검사), lint (멀티 언어 포맷팅)
- **settings.json** — 범용 권한 허용/차단 (Python, Node, Go, Rust, Docker, Make 등)

### GitHub 자동화 (`.github/`)
- **workflows/** — PR 자동 라벨링, 프로젝트 보드 연동, stale 이슈 정리
- **ISSUE_TEMPLATE/** — Feature Request, Bug Report, Task
- **PULL_REQUEST_TEMPLATE.md** — PR 체크리스트
- **GIT_WORKFLOW.md** — 브랜치/커밋/이슈/PR 전체 규칙

### 프로젝트 기반
- **CLAUDE.md** — 프로젝트 규칙 (모드/rigor/도메인에 따라 자동 구성)
- **PLAN.md** — 개발 계획 템플릿
- **.gitignore** — Python, Node, Go, Rust, Docker, IDE, OS + 도메인별 추가

## 사용법

### 1. 템플릿에서 새 리포 생성

GitHub에서 **"Use this template"** → **"Create a new repository"** 클릭

### 2. 클론 & 초기화

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
chmod +x setup.sh init-labels.sh
```

### 3. 프로젝트 설정 후 초기화

```bash
./setup.sh <project-name> <github-username> [옵션]
```

#### 실전 예시

```bash
# 해커톤 (빠르게)
./setup.sh hackathon dhchoi98 --type web --rigor mvp

# SCADA 납품용 (엔터프라이즈 품질)
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

### 설정 옵션

#### 프로젝트 유형 (`--type`)

| 유형 | 생성 디렉토리 | 적합한 용도 |
|------|-------------|------------|
| `general` (기본) | `src/ tests/ docs/` | 범용 |
| `web` | `backend/ frontend/ shared/ docs/ tests/` | 웹 서비스 |
| `cli` | `cmd/ internal/ docs/ tests/` | CLI 도구, 시스템 프로그래밍 |
| `security` | `tools/ exploits/ notes/ reports/` | CTF, 보안 실습, 펜테스팅 |
| `ml` | `notebooks/ data/ models/ src/ tests/` | ML/AI 프로젝트 |
| `scada` | `backend/ hmi/ plc/ drivers/ docs/ tests/` | 산업제어, SCADA/HMI |
| `quant` | `core/ strategies/ data/ dashboard/ tests/` | 퀀트 트레이딩, 금융 |

#### 엔지니어링 깊이 (`--rigor`)

| 깊이 | 타입 규칙 | 테스트 | 아키텍처 | 적합한 상황 |
|------|----------|--------|----------|------------|
| `mvp` (기본) | 권장 (선택적) | 선택적 | 자유 | 해커톤, PoC, 대회 |
| `production` | 함수 시그니처 필수 | 핵심 모듈 필수 | Contract-First, 레이어 분리 | 실서비스, 납품 |
| `enterprise` | 변수까지 전부 필수 | TDD 강제, 커버리지 목표 | Clean Architecture, DIP | 장기 운영, 대규모 |

#### Contract-First 워크플로우 (production/enterprise)

```
1단계: 계약 정의 (사람이 직접)
  → ABC/Protocol 인터페이스, 타입, 데이터 모델 정의

2단계: 테스트 작성 (AI에게 시킴)
  → "이 인터페이스에 대한 계약 테스트를 작성해줘"

3단계: 구현 (AI에게 시킴)
  → "이 테스트를 통과하는 구현체를 작성해줘"
```

#### 워크플로우 모드 (`--mode`)

| 모드 | 설명 |
|------|------|
| `solo` (기본) | 1인 개발. Plan 모드 선택적, 티켓 시스템 없음 |
| `team` | 멀티세션 병렬. 5세션 티켓 시스템, Plan 모드 필수 |

### 4. GitHub 라벨 생성

```bash
./init-labels.sh
```

### 5. 정리 & 첫 커밋

```bash
rm setup.sh init-labels.sh
# CLAUDE.md, PLAN.md를 프로젝트에 맞게 수정
git add -A && git commit -m "chore: 프로젝트 초기 설정"
```

**학습 로드맵** (QUICKSTART.md Section 3에 상세):

```
Level 1 (1~2주)   mvp로 시작, 기본 흐름 익히기
Level 2 (2~4주)   production 전환, 타입 + 테스트 추가
Level 3 (1~2개월)  Contract-First 패턴 체득
Level 4 (2~3개월)  멀티세션 병렬 운영
Level 5 (3개월~)   Docker/CI + 템플릿 자체 개선
```

## 커스터마이징

| 파일 | 수정 포인트 |
|------|------------|
| `CLAUDE.md` | 프로젝트 용어, 구조, 기술스택, 절대규칙 |
| `.project-config` | rigor/mode 변경 (hooks가 참조) |
| `.claude/settings.json` | 허용할 CLI 명령어 추가/제거 |
| `.claude/commands/*.md` | 프로젝트에 맞는 명령어 추가 |
| `.github/ISSUE_TEMPLATE/*.yml` | 컴포넌트 드롭다운 수정 |
| `.github/GIT_WORKFLOW.md` | 브랜치 전략 변경 시 |

## 문서 구조

```
CLAUDE.md                    <- AI가 읽는 규칙 (자동 생성)
PLAN.md                      <- 개발 로드맵
docs/
  QUICKSTART.md              <- 사용법 + 학습 가이드
  METHODOLOGY.md             <- 코딩 방법론 (왜 이렇게 하는가)
  CHECKLISTS.md              <- 체크리스트 모음
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
- (선택) `ruff`, `mypy` — Python 프로젝트
- (선택) `prettier`, `eslint` — TypeScript/JavaScript 프로젝트
- (선택) `gofmt`, `go vet` — Go 프로젝트
- (선택) `cargo clippy`, `cargo fmt` — Rust 프로젝트
