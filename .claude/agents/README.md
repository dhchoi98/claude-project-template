# Subagents

> 메인 컨텍스트를 보호하면서 좁은 작업을 위임할 수 있는 작은 에이전트들.

## 왜 서브에이전트인가?

메인 세션의 컨텍스트는 비싸다. 다음 작업들은 서브에이전트에 위임해서 메인 컨텍스트를 깔끔하게 유지한다:

- **광범위한 코드 탐색** — 결과 요약만 메인에 돌려받기
- **코드 리뷰** — 변경사항을 다른 시각으로 보기
- **장시간 분석** — 메인 작업과 병렬 진행

## 디렉토리 규칙

```
.claude/agents/
├── README.md
└── <agent-name>.md       ← 서브에이전트 정의
```

각 에이전트 파일은 다음 frontmatter를 갖는다:

```yaml
---
name: agent-name
description: 한 줄 — 언제 이 에이전트를 호출해야 하는지
tools: Read, Grep, Glob              # 권한 명시
model: sonnet                         # 또는 opus, haiku
---
```

본문은 그 에이전트가 받을 시스템 프롬프트.

## 호출 방법

메인 세션에서 `Agent` 도구로 호출:

```
Agent(
    subagent_type="code-reviewer",
    description="리뷰 요청",
    prompt="다음 변경사항을 리뷰해줘: ..."
)
```

## 기본 제공 에이전트

- [code-reviewer](code-reviewer.md) — 변경사항을 다른 시각에서 검토
- [Explore](https://docs.claude.com/en/docs/claude-code/sub-agents) — 코드베이스 탐색 (Claude Code 내장)

## 안티 패턴

- 단순한 작업까지 위임 — 오버헤드만 발생
- 메인 세션이 직접 가진 컨텍스트를 다시 전달 안 함 — 서브에이전트는 처음부터 시작이라 컨텍스트를 명시적으로 줘야 함
- 결과를 받고 그대로 신뢰 — 항상 핵심 부분은 검증
