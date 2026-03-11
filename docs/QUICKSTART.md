# Quickstart — 템플릿 사용법 + 학습 가이드

> 이 템플릿으로 첫 프로젝트를 만들고, 바이브 코딩을 단계별로 익히는 가이드.

---

## 1. 첫 프로젝트 만들기 (5분)

### Step 1: 템플릿에서 새 리포 생성

GitHub에서 **"Use this template"** > **"Create a new repository"**

### Step 2: 클론 & 초기화

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
chmod +x setup.sh init-labels.sh

# 예: 웹 서비스, 프로덕션 품질, 혼자 개발
./setup.sh my-app dhchoi98 --type web --rigor production
```

### Step 3: 프로젝트 맞춤 설정

```bash
# 1. CLAUDE.md 열어서 기술스택 테이블 채우기
# 2. PLAN.md에 Phase 1 태스크 작성
# 3. GitHub 라벨 생성
./init-labels.sh

# 4. 정리 & 첫 커밋
rm setup.sh init-labels.sh
git add -A && git commit -m "chore: 프로젝트 초기 설정"
```

### 끝! 이제 Claude Code를 열고 작업을 시작하면 된다.

```bash
claude
# Solo 모드: PLAN.md 보고 바로 작업
# Team 모드: /start → /claim T001 → 작업 → /end
```

---

## 2. 설정 옵션 선택 가이드

### 프로젝트 유형 (`--type`)

어떤 걸 만드는지에 따라 디렉토리 구조가 달라진다.

| 상황 | 선택 | 생성되는 구조 |
|------|------|-------------|
| "뭘 만들지 아직 모르겠어" | `general` | `src/ tests/ docs/` |
| "웹 서비스 / SaaS" | `web` | `backend/ frontend/ shared/` |
| "CLI 도구 / 시스템" | `cli` | `cmd/ internal/` |
| "CTF / 보안 실습" | `security` | `tools/ exploits/ notes/` |
| "ML / AI 프로젝트" | `ml` | `notebooks/ data/ models/` |
| "SCADA / 산업제어" | `scada` | `backend/ hmi/ plc/ drivers/` |
| "퀀트 / 트레이딩" | `quant` | `core/ strategies/ data/` |

### 엔지니어링 깊이 (`--rigor`)

**처음이면 `mvp`로 시작하고, 프로젝트가 자리 잡으면 `production`으로 올려라.**

| 상황 | 선택 | AI에게 강제되는 것 |
|------|------|------------------|
| "빨리 만들고 싶어" (해커톤, PoC) | `mvp` | docstring, API키 체크만 |
| "실제로 쓸 거야" (서비스, 봇) | `production` | + 함수 타입, 린트, 핵심 테스트 |
| "장기 운영 / 납품" | `enterprise` | + 변수 타입, TDD, 전체 테스트 |

### 워크플로우 모드 (`--mode`)

| 상황 | 선택 |
|------|------|
| "혼자 하나씩 작업" | `solo` |
| "Claude Code 탭 여러 개 동시에" | `team` |

---

## 3. 학습 로드맵

### Level 1: 기본기 (첫 1~2주)

**목표:** 템플릿의 기본 흐름에 익숙해지기

1. `--rigor mvp`로 프로젝트 하나 만들기
2. PLAN.md에 간단한 태스크 3~5개 적기
3. Claude Code로 하나씩 구현해보기
4. `CLAUDE.md`가 AI 행동에 어떤 영향을 주는지 관찰

**이 단계에서 읽을 것:**
- 이 파일 (QUICKSTART.md) 전체
- `CLAUDE.md`의 절대규칙 섹션

**체크포인트:** Claude Code에게 "PLAN.md 보고 다음 할 일 알려줘"라고 했을 때 유용한 답이 오는가?

---

### Level 2: 타입 + 테스트 (2~4주차)

**목표:** AI가 더 정확한 코드를 생성하게 만들기

1. `--rigor production`으로 전환 (또는 새 프로젝트)
2. 핵심 모듈에 타입 힌트 추가
3. AI에게 "이 인터페이스의 계약 테스트를 작성해줘" 시키기
4. pre-commit hook이 타입/린트를 잡아주는 걸 경험

**이 단계에서 읽을 것:**
- `docs/METHODOLOGY.md` Section 2 (타입 시스템)
- `docs/METHODOLOGY.md` Section 4 (테스트 전략)
- `docs/CHECKLISTS.md` 새 기능 체크리스트

**체크포인트:** 함수에 타입 힌트를 달았을 때 AI가 생성하는 코드 품질이 눈에 띄게 올라가는가?

---

### Level 3: Contract-First (1~2개월차)

**목표:** "사람이 계약, AI가 구현" 패턴 체득

1. `contracts.py` (또는 인터페이스 파일) 직접 작성
2. AI에게 테스트 → 구현 순서로 시키기
3. Cursor Auto와 CC를 분업시키기 (CC: 설계, Auto: 구현)
4. `.work/MISTAKES.md`에 교훈 기록하는 습관

**이 단계에서 읽을 것:**
- `docs/METHODOLOGY.md` Section 3 (Contract-First)
- `docs/METHODOLOGY.md` Section 9 (AI에게 잘 시키는 법)
- `CLAUDE.md`의 Contract-First 분업 패턴 섹션

**체크포인트:** 인터페이스를 정의하고 테스트를 먼저 쓴 뒤, AI에게 "이 테스트를 통과시켜"라고 했을 때 한 번에 통과하는가?

---

### Level 4: 멀티세션 병렬 (2~3개월차)

**목표:** 5개 세션 동시 운영으로 생산성 극대화

1. `--mode team`으로 전환
2. 티켓을 파일 범위가 겹치지 않게 쪼개기
3. 탭 3~5개 열고 `/start` → `/claim` → 작업 → `/end`
4. 핸드오프 문서가 실제로 유용한지 확인

**이 단계에서 읽을 것:**
- `.work/WORKFLOW_GUIDE.md` 전체
- `docs/CHECKLISTS.md` 충돌 방지 체크리스트

**체크포인트:** 5세션이 동시에 돌 때 파일 충돌 없이 각자 작업을 완료하는가?

---

### Level 5: 운영 + 발전 (3개월차~)

**목표:** 템플릿 자체를 개선하고 자신만의 패턴 정립

1. Docker + CI/CD 파이프라인 구축
2. 프로젝트 간 공통 코드 추출 (Rule of Three)
3. `CLAUDE.md`를 프로젝트 특성에 맞게 커스터마이징
4. 이 템플릿에 PR을 보내서 개선

**이 단계에서 읽을 것:**
- `docs/METHODOLOGY.md` Section 7, 8 (Docker, CI/CD)
- `docs/METHODOLOGY.md` Section 10 (보안)

**체크포인트:** 새 프로젝트를 만들 때 30분 안에 "AI가 잘 따르는" 상태가 되는가?

---

## 4. 일일 워크플로우

### Solo 모드

```
1. PLAN.md에서 오늘 할 일 확인
2. Claude Code 열기
3. 작업 (필요하면 Plan 모드로 계획 먼저)
4. 자가 검증 (테스트/빌드/린트)
5. 커밋
6. PLAN.md 업데이트
```

### Team 모드

```
1. 터미널 탭 3~5개 열기
2. 각 탭: claude → /start → /claim T{XXX}
3. 세션마다 "이 티켓 구현해줘. Plan 모드로 계획 먼저 보여줘."
4. 탭 순회하며 모니터링 (질문에 답변, 방향 수정)
5. 완료된 세션: /review → /end
6. 모든 세션 끝나면 통합 검증 + 커밋
```

---

## 5. 자주 묻는 질문

### Q: Solo인데 team 모드를 써야 하나요?

아니요. Solo 모드로 충분합니다. Team 모드는 Claude Code를 여러 탭에서 동시에 돌릴 때 **파일 충돌을 방지**하기 위한 시스템입니다. 탭 1개만 쓰면 Solo가 낫습니다.

### Q: rigor를 중간에 바꿀 수 있나요?

`.project-config` 파일의 `PROJECT_RIGOR=` 값을 변경하면 됩니다. hooks가 이 파일을 참조합니다. 단, `CLAUDE.md`의 엔지니어링 규칙 섹션은 수동으로 맞춰야 합니다.

### Q: Cursor 없이 CC만 써도 되나요?

네. CLAUDE.md의 도구 분업 섹션에 "Cursor를 사용하지 않으면 이 섹션은 무시하고, CC와 Any 티켓만 작업한다"고 되어 있습니다. CC만으로 충분히 동작합니다.

### Q: CLAUDE.md를 어떻게 커스터마이징하나요?

가장 효과가 큰 순서:
1. **기술스택 테이블** 채우기 — AI가 올바른 라이브러리를 선택하게 됨
2. **구조 섹션**을 실제 디렉토리에 맞게 수정
3. **용어 테이블**에 도메인 용어 추가
4. **금지 사항** 추가 (프로젝트별 절대 하면 안 되는 것)

### Q: 이 방법론이 Python 외 언어에도 적용되나요?

핵심 원칙(Contract-First, 타입 명시, 계약 테스트)은 언어 무관합니다. 이 템플릿의 hooks도 Python, TypeScript, Go, Rust를 모두 지원합니다. 구체적인 코드 패턴만 해당 언어에 맞게 바꾸면 됩니다.
