# AGENTS.md — AI Tool Contract

이 파일은 이 저장소에서 동작하는 모든 AI 도구(Claude Code, Codex 등)의 **공통 운영 계약**입니다.
도구별 상세 규칙은 `CLAUDE.md`와 `.codex/AGENTS.md`(있으면)에서 보완합니다.

## 0) 목적

- **인간(1인 개발자)** 이 방향/우선순위/승인을 담당한다.
- **AI** 는 구현, 검증, 코드 리뷰를 담당한다.
- 시스템은 lean하게 유지하고, 실전에서 검증하며 진화시킨다.

## 1) Non-Negotiables

1. **Read-first**: 수정 전 관련 코드/문서 먼저 확인
2. **Small diffs**: 작업 하나당 관심사 하나. "이왕 하는 김에" 금지
3. **Self-verification**: 변경 후 테스트/린트/빌드/타입 검증을 거치고 보고
4. **Explicit git actions**: 커밋/브랜치/PR/merge는 사용자가 명시적으로 지시할 때만 수행
5. **Secrets safety**: 키/토큰/개인정보 하드코딩 금지

## 2) 도구 분업

- **Claude Code (CC)** — 메인. 설계, 멀티파일 변경, 디버깅, 코드 리뷰
- **Codex** — 보조. 단순 보일러플레이트, 작은 함수 구현. **CC가 결과를 반드시 읽고 자가 검증**

자세한 사용 기준은 [CLAUDE.md](CLAUDE.md) 의 "도구 분업" 섹션 참조.

## 3) Decision Pipeline

1. 사용자가 목적/제약을 정의
2. AI가 (필요하면 Plan 모드로) 실행 계획을 제안
3. 사용자 승인 후 구현
4. AI가 자가 검증 (테스트/린트/빌드/타입)
5. 결과 보고
6. 사용자가 머지/커밋 결정

## 4) Automation Policy (Safe by Default)

- 자동화는 **report/comment-only** 가 기본
- auto-merge, direct-main push 금지
- 위험 명령(`rm -rf`, `git push --force`, `git reset --hard` 등)은 `.claude/settings.json` 의 deny 리스트에서 차단

## 5) Steering 문서 (선택)

- `docs/steering/repo-contract.md` — 레포 계약
- `docs/steering/write-boundaries.yaml` — 변경 경계
- `docs/steering/review-gates.yaml` — 리뷰 게이트
- `docs/steering/hotspot-files.yaml` — 충돌 위험 파일

이 문서들은 있을 때만 따른다. 없으면 무시.
