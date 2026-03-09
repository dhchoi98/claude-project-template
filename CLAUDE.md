# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## 절대규칙

- **DB**: 읽기전용 기본. 쓰기는 명시적 write session. DROP/TRUNCATE/WHERE없는 DELETE 금지. DDL은 Alembic만.
- **Docstring**: 모든 파일 최상단에 목적 기술 (Python: `"""..."""`, TS: `/** */`)
- **API키**: 하드코딩 금지. `.env` → `core/config.py` → `settings.XXX`
- **커밋**: `feat: 한글 본문 허용` (Conventional Commits)
- **코드변경**: 해당 폴더 CLAUDE.md 먼저 읽기. 새 파일 시 CLAUDE.md 갱신. 엔진 변경 시 테스트 필수.

## 용어

| 용어 | 의미 |
|------|------|
| — | 프로젝트 고유 용어를 여기에 추가 |

## 구조

```
backend/         — FastAPI (엔진, 서비스, API)
frontend/        — Next.js 14+ (대시보드)
shared/          — 공유 타입/상수
docs/            — 설계 문서
.claude/commands/    — 슬래시 명령어
.claude/hooks/       — pre-commit, lint 자동 검사
```

## 기술스택

| 카테고리 | 기술 | 비고 |
|----------|------|------|
| Backend | FastAPI + PostgreSQL + Redis | — |
| Frontend | Next.js 14 + shadcn/ui | — |
| Infra | Docker Compose | — |

## 상세 문서

- `docs/` — 아키텍처, DB 스키마, 엔진 설계 등
- `.github/GIT_WORKFLOW.md` — Git 브랜치/커밋/이슈/PR 규칙

## 현재 상태

PLAN.md 참조.
