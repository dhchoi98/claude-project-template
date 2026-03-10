현재 세션 상태를 빠르게 보고한다.

1. `.work/BOARD.md`에서 활성 세션 테이블을 읽는다
2. `PLAN.md`에서 현재 Phase 진행 상황을 파악한다
3. 현재 세션의 브랜치, 클레임 태스크, 변경 파일 수를 확인한다

출력:
```
━━━ SESSION STATUS ━━━
세션: S{N} | 브랜치: {branch}
태스크: T{XXX} — {제목}
Phase: {N} ({완료}/{전체})
변경: {N} files (+{added} -{deleted})
마지막 커밋: {message} ({시간 전})

동료 세션:
  S{X}: T{AAA} (active)
  S{Y}: idle
━━━━━━━━━━━━━━━━━━━━━
```
