#!/bin/bash
# pre-compact.sh — 컨텍스트 압축(compaction) 직전에 현재 상태를 스냅샷 저장한다.
#
# 호출 시점: PreCompact 훅 (Claude Code가 컨텍스트를 압축하기 직전)
# 목적: 압축으로 잃어버릴 수 있는 작업 상태를 디스크에 남긴다.
#
# 저장 위치: .work/snapshots/snapshot-<timestamp>.md
# 저장 내용:
#   - 타임스탬프 + 모드/엄격도
#   - Git working tree 상태 (변경된 파일 목록 + diff 요약)
#   - PLAN.md 미완료 항목
#   - 최근 5 커밋

set -e

SNAPSHOT_DIR=".work/snapshots"
mkdir -p "$SNAPSHOT_DIR"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
SNAPSHOT_FILE="$SNAPSHOT_DIR/snapshot-$TIMESTAMP.md"

RIGOR="mvp"
if [ -f ".project-config" ]; then
    RIGOR=$(grep "^PROJECT_RIGOR=" .project-config | cut -d= -f2 || echo "mvp")
fi

{
    echo "# 컨텍스트 압축 직전 스냅샷"
    echo ""
    echo "- **시각:** $(date '+%Y-%m-%d %H:%M:%S')"
    echo "- **엄격도:** $RIGOR"
    echo ""

    if [ -d ".git" ]; then
        echo "## Git 상태"
        echo ""
        echo "### 최근 커밋"
        echo '```'
        git log --oneline -5 2>/dev/null || echo "(no commits)"
        echo '```'
        echo ""

        DIRTY=$(git status --porcelain 2>/dev/null || true)
        if [ -n "$DIRTY" ]; then
            echo "### Working tree 변경"
            echo '```'
            echo "$DIRTY"
            echo '```'
            echo ""

            echo "### Diff 통계"
            echo '```'
            git diff --stat 2>/dev/null || true
            git diff --cached --stat 2>/dev/null || true
            echo '```'
            echo ""
        fi
    fi

    if [ -f "PLAN.md" ]; then
        echo "## PLAN.md 미완료 항목"
        echo '```'
        grep -nE '^\s*-\s*\[ \]' PLAN.md 2>/dev/null | head -20 || echo "(없음)"
        echo '```'
        echo ""
    fi

    echo "---"
    echo "_복원: 다음 세션 시작 시 이 파일을 읽고 작업 상태를 재구성._"
} > "$SNAPSHOT_FILE"

# 30개 초과 시 가장 오래된 스냅샷 정리
SNAPSHOT_COUNT=$(ls -1 "$SNAPSHOT_DIR"/snapshot-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$SNAPSHOT_COUNT" -gt 30 ]; then
    ls -1t "$SNAPSHOT_DIR"/snapshot-*.md | tail -n +31 | xargs rm -f 2>/dev/null || true
fi

echo "[PreCompact] 스냅샷 저장: $SNAPSHOT_FILE"
