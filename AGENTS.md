# AGENTS.md — Universal Dev Harness Contract

이 파일은 이 저장소에서 동작하는 모든 AI 도구(Claude Code, Codex, Cursor 등)의 **공통 운영 계약**입니다.
도구별 상세 규칙은 각 adapter 문서(`CLAUDE.md`, `.codex/AGENTS.md`, `.cursor/rules/*`)에서 보완합니다.

## 0) 목적
- 인간(선장)이 방향/우선순위/승인을 담당한다.
- AI(선원)는 구현, 검증, 품질 제안 작업을 병렬로 수행한다.
- 시스템은 lean하게 유지하고, 실전 프로젝트에서 검증하며 진화시킨다.

## 1) Execution Model — SWMR
**Single Writer, Many Reviewers**
- 한 feature branch/worktree에는 한 시점에 **writer 1명만** 코드 수정한다.
- reviewer는 기본적으로 읽기/검증 전용이다.
- 병렬화는 write-heavy가 아니라 review-heavy 작업에 우선 적용한다.

## 2) Task Ownership
- **Write tasks**: feature-based full-stack 단위로 쪼갠다.
  - 예: `feature/auth`, `feature/order-engine`, `feature/dashboard`
- **Read tasks**: role-based로 운영한다.
  - 예: `reviewer`, `security-reviewer`, `test-verifier`, `docs-researcher`
- frontend/backend 레이어 전담 ownership을 기본값으로 두지 않는다.

## 3) Non-Negotiables
1. Read-first: 수정 전 관련 코드/문서 먼저 확인
2. Small diffs: 작업 하나당 관심사 하나
3. Self-verification: 변경 후 테스트/린트/빌드 검증
4. Explicit git actions: 커밋/브랜치/PR/merge는 명시적 지시 시 수행
5. Secrets safety: 키/토큰/개인정보 하드코딩 금지

## 4) Write Boundaries
- shared hotspot 파일(예: global config, schema, shared types)은 변경 최소화.
- hotspot 변경이 필요하면 이유와 영향 범위를 계획에 명시한다.
- reviewer가 hotspot drift 여부를 우선 점검한다.

## 5) Decision Pipeline
1. Human defines objective + constraints
2. Planner proposes execution plan (feature slices + dependencies)
3. Writer implements one approved slice
4. Review agents validate correctness/security/tests/docs
5. Human approves merge

## 6) Automation Policy (Safe by Default)
- 자동화는 초기에는 **report/comment-only**로 시작한다.
- 순서: PR review → nightly audit → safe refactor proposal(draft PR)
- auto-merge, direct-main write 금지.

## 7) Required Steering Artifacts
- `docs/steering/repo-contract.md`
- `docs/steering/write-boundaries.yaml`
- `docs/steering/review-gates.yaml`
- `docs/steering/hotspot-files.yaml`

도구는 변경 전 위 파일을 읽고, 해당 규칙을 작업 계획에 반영해야 한다.
