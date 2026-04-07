# Quickstart

> 1인 개발자 전용. Claude Code 메인 + Codex 보조.

---

## 1. 첫 프로젝트 만들기 (3분)

### Step 1: 템플릿에서 새 리포 생성

GitHub에서 **Use this template** > **Create a new repository**.

### Step 2: 클론 + Claude Code 실행

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
claude
```

### Step 3: `/init` 실행

Claude Code 안에서:

```
/init
```

Claude가 프로젝트 이름/유형/rigor/스택을 물어본다. 답하면 디렉토리 구조, `.project-config`, PLAN.md 초기 상태까지 한 번에 셋업한다.

### Step 4: 작업 시작

`SessionStart` 훅이 매 세션 자동으로 PLAN.md, MISTAKES.md, 최근 스냅샷, Git 상태를 컨텍스트에 로드한다. 그냥 작업을 지시하면 된다.

---

## 2. Rigor 가이드

`.project-config`의 `PROJECT_RIGOR` 값을 한 줄 바꾸면 Claude가 따르는 규칙이 달라진다. 자세한 규칙은 [RIGOR.md](RIGOR.md).

| 상황 | 선택 | 강제되는 것 |
|------|------|-------------|
| 빨리 만들고 싶다 (해커톤, PoC) | `mvp` | docstring, 시크릿 체크만 |
| 실제로 쓸 것이다 (서비스, 봇) | `production` | + 함수 시그니처 타입, 린트, 핵심 모듈 테스트 |
| 장기 운영 / 납품 | `enterprise` | + 변수 타입, TDD, 전체 테스트 + Clean Architecture |

**처음이면 `mvp`로 시작하고, 자리 잡으면 `production`으로 올린다.**

---

## 3. 일일 워크플로우

```
1. claude (Claude Code 실행)
   → SessionStart 훅이 PLAN/MISTAKES/Git 상태 자동 로드
2. 사용자: "오늘 T001 작업 시작하자"
3. (복잡하면) Plan 모드로 계획 수립
4. 구현
5. 자가 검증 (.claude/skills/self-verify 절차)
6. /review (선택) — code-reviewer 서브에이전트 호출
7. PLAN.md 상태 업데이트
8. (사용자 지시 시) 커밋
```

---

## 4. 도구 분업: Claude Code vs Codex

### 거의 모든 작업: Claude Code
- 설계, 멀티파일 변경, 디버깅, 리팩토링, 코드 리뷰
- "복잡하다" 싶으면 무조건 CC

### Claude Code 안에서 Codex를 부르는 경우
- 200줄 미만의 단순 보일러플레이트
- 인터페이스/테스트가 명확히 정의된 구현체
- CRUD 라우트, DTO, 마이그레이션 등 반복 패턴

```bash
# CC 세션 안에서 호출
codex "이 인터페이스를 통과하는 구현체 작성: <파일 경로>"
```

호출 후 **CC가 반드시 결과를 직접 읽고 자가 검증**한다. Codex 결과를 검증 없이 신뢰하지 않는다.

---

## 5. 자주 묻는 질문

### Q: rigor를 중간에 바꿀 수 있나?

`.project-config` 파일에서 `PROJECT_RIGOR=` 값을 바꾸면 끝. `pre-commit` 훅이 다음 커밋부터 새 강도로 검사한다. CLAUDE.md 본문은 이미 [docs/RIGOR.md](RIGOR.md)를 참조하므로 별도 수정 불필요.

### Q: PLAN.md가 비어 있는데 어떻게 채우나?

Claude에게 "Phase 1 태스크 5개 제안해줘"라고 시키면 된다. 한 번에 다 채우려 하지 말고, Phase 1만 채우고 진행하면서 다음 Phase를 채워나가는 게 좋다.

### Q: SessionStart 훅이 너무 시끄럽다

`.claude/hooks/session-start.sh`를 수정해 출력을 줄이거나, `.claude/settings.json`의 `hooks.SessionStart`를 빼면 비활성화된다.

### Q: 새 슬래시 명령어를 만들고 싶다

`.claude/commands/<이름>.md` 파일을 만들고 본문에 명령 동작을 적는다. Claude Code가 자동으로 `/이름`으로 인식한다.

### Q: 새 스킬을 만들고 싶다

`.claude/skills/<이름>/SKILL.md`를 만들고 frontmatter(name, description, when_to_use)를 채운다. 작업 패턴이 안정화되면 스킬로 추출해두면 다음에 자동으로 활용된다.

### Q: 서브에이전트를 추가하고 싶다

`.claude/agents/<이름>.md` 파일을 만들고 frontmatter(name, description, tools, model)와 시스템 프롬프트를 작성한다. `Agent` 도구로 호출 가능.

### Q: 위험한 명령을 차단하고 싶다

`.claude/settings.json`의 `permissions.deny` 리스트에 추가한다.
