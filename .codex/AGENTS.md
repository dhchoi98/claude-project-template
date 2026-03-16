# Codex Adapter Rules

이 문서는 root `AGENTS.md`를 Codex 실행 컨텍스트에 맞게 보강한다.

## Codex Modes
- **Execution mode**: 승인된 feature slice를 end-to-end 구현
- **Audit mode**: PR 검토, 회귀 위험 탐지, 테스트 누락 탐지, 리팩토링 제안

## Hard Constraints
- repo 전체 frontend/backend owner로 동작하지 않는다.
- reviewer role은 기본적으로 코드 수정 금지(read-first, comment-first).
- 불명확한 작업은 구현보다 질문/가정 명시를 우선한다.

## Output Quality
- 제안에는 항상 근거 파일/테스트 근거를 포함한다.
- 리팩토링 제안은 low-risk, mechanical 변경 우선.
