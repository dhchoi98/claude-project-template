# Claude Project Template

Claude Code + GitHub 자동화가 세팅된 프로젝트 템플릿.

## 포함 내용

### Claude Code 설정 (`.claude/`)
- **commands/** — 슬래시 명령어 7개 (`/plan`, `/review`, `/session`, `/spec`, `/newfile`, `/cleanup`, `/phase-check`)
- **hooks/** — pre-commit (docstring/보안/lint 자동 검사), lint (ruff + mypy)
- **settings.json** — 권한 허용/차단 기본값

### GitHub 자동화 (`.github/`)
- **workflows/** — PR 자동 라벨링, 프로젝트 보드 연동, stale 이슈 정리
- **ISSUE_TEMPLATE/** — Feature Request, Bug Report, Task
- **PULL_REQUEST_TEMPLATE.md** — PR 체크리스트
- **GIT_WORKFLOW.md** — 브랜치/커밋/이슈/PR 전체 규칙

### 프로젝트 기반
- **CLAUDE.md** — 프로젝트 규칙 (Claude Code 컨텍스트)
- **PLAN.md** — 개발 계획 템플릿
- **.gitignore** — Python + Node + IDE + OS

## 사용법

### 1. 템플릿에서 새 리포 생성

GitHub에서 **"Use this template"** → **"Create a new repository"** 클릭

### 2. 클론 & 초기화

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
chmod +x setup.sh init-labels.sh
./setup.sh <project-name> <github-username> "<프로젝트 설명>"
```

### 3. GitHub 라벨 생성

```bash
./init-labels.sh
```

### 4. 정리 & 첫 커밋

```bash
rm setup.sh init-labels.sh README.md
# CLAUDE.md, PLAN.md를 프로젝트에 맞게 수정
git add -A && git commit -m "chore: 프로젝트 초기 설정"
```

### 5. (선택) GitHub Projects 보드

1. GitHub → Projects → New Project → Board
2. Settings → Secrets → `PROJECT_TOKEN` 추가 (repo + project 권한의 PAT)
3. `.github/workflows/auto-project.yml`의 project-url 확인

## 커스터마이징

| 파일 | 수정 포인트 |
|------|------------|
| `CLAUDE.md` | 프로젝트 용어, 구조, 기술스택, 절대규칙 |
| `.claude/settings.json` | 허용할 CLI 명령어 추가/제거 |
| `.claude/commands/*.md` | 프로젝트에 맞는 명령어 추가 |
| `.github/ISSUE_TEMPLATE/*.yml` | 컴포넌트 드롭다운 수정 |
| `.github/GIT_WORKFLOW.md` | 브랜치 전략 변경 시 |

## 요구사항

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh auth login` 완료)
- (선택) `ruff`, `mypy` — Python 프로젝트 시
