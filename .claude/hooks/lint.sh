#!/bin/bash
# lint hook: 자동 포맷팅 및 타입 체크
# 설치된 도구를 자동 감지하여 실행한다.

set -e

TARGET=${1:-.}

echo "[Hook] Lint & Format..."

# ─── Python ──────────────────────────────────────────────

if command -v ruff &> /dev/null && find "$TARGET" -name "*.py" -print -quit 2>/dev/null | grep -q .; then
    echo "  Ruff format..."
    ruff format "$TARGET" --quiet
    echo "  Ruff check..."
    ruff check "$TARGET" --fix --quiet
fi

# Python strict 모드: mypy
if [ -f ".python-strict" ] && command -v mypy &> /dev/null; then
    PY_TARGET="$TARGET"
    if [ "$TARGET" = "." ]; then
        # 전체 프로젝트에서 Python 디렉토리 자동 탐색
        for dir in src backend cmd internal; do
            [ -d "$dir" ] && PY_TARGET="$dir" && break
        done
    fi
    if find "$PY_TARGET" -name "*.py" -print -quit 2>/dev/null | grep -q .; then
        echo "  MyPy type check..."
        mypy "$PY_TARGET" --ignore-missing-imports --quiet || true
    fi
fi

# ─── JavaScript / TypeScript ─────────────────────────────

if command -v prettier &> /dev/null && find "$TARGET" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -print -quit 2>/dev/null | grep -q .; then
    echo "  Prettier format..."
    prettier --write "$TARGET/**/*.{ts,tsx,js,jsx}" --log-level warn 2>/dev/null || true
fi

if command -v eslint &> /dev/null && [ -f ".eslintrc*" ] || [ -f "eslint.config.*" ]; then
    echo "  ESLint check..."
    eslint "$TARGET" --fix --quiet 2>/dev/null || true
fi

# ─── Go ──────────────────────────────────────────────────

if command -v gofmt &> /dev/null && find "$TARGET" -name "*.go" -print -quit 2>/dev/null | grep -q .; then
    echo "  Go format..."
    gofmt -w "$TARGET" 2>/dev/null || true
fi

# ─── Rust ────────────────────────────────────────────────

if command -v cargo &> /dev/null && [ -f "Cargo.toml" ]; then
    echo "  Cargo fmt..."
    cargo fmt --quiet 2>/dev/null || true
fi

echo "Lint 완료"
