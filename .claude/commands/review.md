현재 세션의 변경사항을 리뷰한다.

수행 단계:

1. `git status` 와 `git diff` 로 변경/생성된 파일 목록 확인
2. 가능하면 `code-reviewer` 서브에이전트를 호출 (`Agent` 도구, `subagent_type=code-reviewer`)
3. 직접 체크할 항목:
   - 파일 상단 docstring/JSDoc 존재 여부
   - 하드코딩된 API 키/시크릿 없는지
   - 핵심 로직 변경 시 대응 테스트 존재 여부
   - 새 파일 생성 시 해당 폴더 CLAUDE.md 갱신 여부
   - `.claude/skills/self-verify` 의 검증 단계가 모두 수행되었는지
4. 린트 실행 (해당 언어 도구가 있을 때)

출력:

```
━━━ REVIEW ━━━
변경 파일: {N}건

✅/❌ docstring
✅/❌ API 키 없음
✅/❌ 테스트 존재
✅/❌ CLAUDE.md 갱신
✅/❌ 자가 검증 (테스트/린트/빌드)

(서브에이전트 의견이 있으면 요약)

종합: PASS / {N}건 수정 필요
━━━━━━━━━━━━━━
```
