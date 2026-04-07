# Skills

> 재사용 가능한 도메인 지식 패키지. 명령어보다 상위 개념.

## Skill이란?

**Skill = 특정 작업에 대한 "어떻게 해야 하는지" 가이드 + 컨텍스트 + 예시 묶음**.

명령어(`commands/`)는 한 번 실행되는 액션이지만, Skill은 작업 방식 그 자체를 패키징한다. 예를 들어:

- `/start`는 명령 — 세션 시작 절차를 한 번 실행
- `tdd-loop` Skill은 지식 — TDD를 어떻게 굴리는지에 대한 표준 + 예시 + 체크리스트

## 디렉토리 규칙

```
.claude/skills/
├── README.md                  ← 이 파일
├── <skill-name>/
│   └── SKILL.md               ← 메인 정의 (필수)
└── <single-file-skill>.md     ← 단일 파일 형태도 허용
```

각 SKILL.md 상단에 YAML frontmatter를 둔다:

```yaml
---
name: skill-name
description: 한 줄 설명 — 언제 이 skill이 활성화되어야 하는지
when_to_use: 트리거 조건 (자유 서술)
---
```

## 사용 방법

1. 작업 시작 전 관련 skill을 먼저 읽는다 (CLAUDE.md "절대규칙 1: 읽기 우선"의 연장)
2. Skill 내용은 그 작업을 진행하는 동안의 행동 지침
3. 새로운 패턴이 안정화되면 새 Skill로 추출 (`MISTAKES.md`에 한 번 실수한 후 두 번째 실수면 Skill로)

## 기본 제공 Skill

- [tdd-loop](tdd-loop/SKILL.md) — TDD Red→Green→Refactor 루프 표준
- [self-verify](self-verify/SKILL.md) — 자가 검증 루프 (테스트/빌드/린트) 표준 절차
- [read-first](read-first/SKILL.md) — 코드 변경 전 무엇을 어떤 순서로 읽을지

## 새 Skill 만들기

```bash
mkdir .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md
```

원칙:
- **하나의 skill = 하나의 작업 패턴**
- 일반론 금지. 이 프로젝트에서 실제 쓰는 방식만 기록
- 예시는 실제 파일 경로/코드로 (가짜 예시 금지)
- 200줄 넘으면 분할 신호
