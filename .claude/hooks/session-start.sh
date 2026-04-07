#!/bin/bash
# session-start.sh — 새 세션이 시작될 때 자동으로 컨텍스트를 로드한다.
#
# 호출 시점: SessionStart 훅 (Claude Code가 새 세션을 열 때)
# 출력: stdout으로 텍스트를 내보내면 그것이 세션의 추가 컨텍스트가 된다.
#
# 로드되는 것:
#   1. .project-config (엄격도)
#   2. PLAN.md 미완료 항목
#   3. .work/MISTAKES.md (있으면) — 과거 실수
#   4. .work/snapshots/ 가장 최근 스냅샷 (있으면) — 직전 세션 상태
#   5. git 최근 변경 (마지막 5 커밋 + working tree 상태)

set -e

OUT=""

append() {
    OUT="${OUT}$1
"
}

append "## 🚀 세션 시작 — 자동 컨텍스트 로드"
append ""

# ─── 1. 프로젝트 설정 ────────────────────────────────────
RIGOR="mvp"
PROJECT_NAME="(unknown)"
if [ -f ".project-config" ]; then
    RIGOR=$(grep "^PROJECT_RIGOR=" .project-config | cut -d= -f2 || echo "mvp")
    PROJECT_NAME=$(grep "^PROJECT_NAME=" .project-config | cut -d= -f2 || echo "(unknown)")
fi

append "**프로젝트:** $PROJECT_NAME | **엄격도:** $RIGOR"
append ""

# ─── 2. PLAN.md 미완료 항목 ───────────────────────────────
if [ -f "PLAN.md" ]; then
    append "### 📋 PLAN.md 미완료 항목 (상위 10개)"
    append '```'
    PLAN_ITEMS=$(grep -nE '^\s*-\s*\[ \]' PLAN.md 2>/dev/null | head -10 || true)
    if [ -n "$PLAN_ITEMS" ]; then
        append "$PLAN_ITEMS"
    else
        append "(미완료 항목 없음 또는 PLAN.md 형식 다름)"
    fi
    append '```'
    append ""
fi

# ─── 3. MISTAKES.md (있으면 마지막 부분) ─────────────────
if [ -f ".work/MISTAKES.md" ]; then
    append "### ⚠️  최근 오답 노트 (반복 회피)"
    append '```'
    MISTAKES_TAIL=$(tail -30 .work/MISTAKES.md 2>/dev/null || true)
    append "$MISTAKES_TAIL"
    append '```'
    append ""
fi

# ─── 4. 직전 세션 스냅샷 ─────────────────────────────────
if [ -d ".work/snapshots" ]; then
    LATEST_SNAPSHOT=$(ls -t .work/snapshots/snapshot-*.md 2>/dev/null | head -1 || true)
    if [ -n "$LATEST_SNAPSHOT" ]; then
        append "### 📸 직전 세션 스냅샷: $(basename "$LATEST_SNAPSHOT")"
        append '```'
        head -40 "$LATEST_SNAPSHOT"
        append '```'
        append ""
    fi
fi

# ─── 5. Git 최근 활동 ────────────────────────────────────
if [ -d ".git" ]; then
    append "### 🌳 Git 최근 활동"
    append '```'
    GIT_LOG=$(git log --oneline -5 2>/dev/null || echo "(no commits)")
    append "$GIT_LOG"
    append '```'
    append ""

    DIRTY=$(git status --porcelain 2>/dev/null || true)
    if [ -n "$DIRTY" ]; then
        append "**Working tree 변경:**"
        append '```'
        DIRTY_HEAD=$(echo "$DIRTY" | head -20)
        append "$DIRTY_HEAD"
        append '```'
        append ""
    fi
fi

# ─── 6. 안내 ──────────────────────────────────────────────
append "---"
append "💡 **다음 행동 제안**"
append "- PLAN.md의 첫 미완료 항목을 검토하거나, 사용자의 명시적 지시를 기다린다."
append "- 작업 시작 전 관련 \`.claude/skills/\`를 먼저 읽는다 (read-first, self-verify, tdd-loop)."
append ""

echo "$OUT"
