#!/bin/bash
# pre-commit hook: 코드 품질 자동 검사
# .project-config의 rigor 수준에 따라 검사 강도를 조절한다.
# mvp: 하드코딩 API키 + docstring
# production: + 함수 시그니처 타입 + ruff/mypy + 핵심 모듈 테스트 존재
# enterprise: + 변수 타입 + 전체 테스트 존재 + strict mypy

set -e

echo "[Hook] 코드 품질 검사 시작..."

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SECTION 0: Sandbox & Secret Guards (fail-fast, rigor 무관)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# 목적: Cursor/Codex/기타 에이전트 sandbox가 repo를 임의 디렉토리로
# 복제한 뒤 자동 커밋을 시도하거나, .gitignore를 우회해 시크릿 파일을
# 스테이지에 올리는 사고를 차단한다. 실제 사고 사례는
# .work/decisions/ADR-001-sandbox-secret-guards.md 참조.
#
# 두 가드 모두 escape hatch가 있다 (의도된 운영용):
#   ALLOW_FOREIGN_PATH=1  → canonical-path guard 우회
#   ALLOW_SECRET=1        → secret filename blocklist 우회

# ─── 0a. Canonical path guard ────────────────────────────
# .project-config 에 PROJECT_CANONICAL_PATH=... 가 설정돼 있으면,
# 현재 git toplevel 이 그 경로와 정확히 일치할 때만 커밋을 허용한다.
# (sandbox/nanoid 디렉토리에서 도는 자동 커밋을 잡는다.)
if [ -f ".project-config" ]; then
    CANONICAL_PATH=$(grep "^PROJECT_CANONICAL_PATH=" .project-config | cut -d= -f2- || true)
    if [ -n "$CANONICAL_PATH" ] && [ "${ALLOW_FOREIGN_PATH:-0}" != "1" ]; then
        TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
        if [ "$TOPLEVEL" != "$CANONICAL_PATH" ]; then
            echo "FAIL canonical-path guard: 현재 repo 경로가 PROJECT_CANONICAL_PATH 와 다릅니다."
            echo "  expected: $CANONICAL_PATH"
            echo "  actual:   $TOPLEVEL"
            echo "  → Cursor/Codex sandbox 가 repo 를 복제했을 가능성. 원본 경로에서 작업하세요."
            echo "  의도적인 작업이면: ALLOW_FOREIGN_PATH=1 git commit ..."
            exit 1
        fi
    fi
fi

# ─── 0b. Secret filename blocklist ───────────────────────
# 내용을 검사하기 전에 파일 이름 자체로 차단한다. .gitignore 가 우회되거나
# 새 파일이 의도치 않게 추가되는 경우를 잡는다.
if [ "${ALLOW_SECRET:-0}" != "1" ]; then
    SECRET_PATTERNS=(
        '(^|/)env\.sh$'
        '(^|/)\.env(\.|$)'
        '(^|/)[^/]*\.key$'
        '(^|/)[^/]*\.pem$'
        '(^|/)id_(rsa|ed25519|ecdsa)(\.|$)'
        '(^|/)[^/]*client_secret[^/]*\.json$'
        '(^|/)[^/]*credentials[^/]*\.json$'
        '(^|/)\.openclaw/'
        '(^|/)\.clawhub/'
        '(^|/)secrets?/'
    )
    BLOCKED=""
    STAGED_ALL=$(git diff --cached --name-only --diff-filter=ACM)
    for pat in "${SECRET_PATTERNS[@]}"; do
        MATCH=$(echo "$STAGED_ALL" | grep -E "$pat" || true)
        if [ -n "$MATCH" ]; then
            BLOCKED="$BLOCKED$MATCH"$'\n'
        fi
    done
    if [ -n "$BLOCKED" ]; then
        echo "FAIL secret-filename blocklist: 시크릿 파일로 의심되는 항목이 스테이지에 있습니다."
        echo "$BLOCKED" | sed 's/^/  /'
        echo "  → 의도적이면: ALLOW_SECRET=1 git commit ..."
        exit 1
    fi
fi

# ─── 설정 읽기 ───────────────────────────────────────────

RIGOR="mvp"
if [ -f ".project-config" ]; then
    RIGOR=$(grep "^PROJECT_RIGOR=" .project-config | cut -d= -f2 || echo "mvp")
fi

ERRORS=0
WARNINGS=0
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# 언어별 파일
PY_FILES=$(echo "$STAGED_FILES" | grep '\.py$' || true)
TS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx)$' || true)
GO_FILES=$(echo "$STAGED_FILES" | grep '\.go$' || true)
RS_FILES=$(echo "$STAGED_FILES" | grep '\.rs$' || true)
CODE_FILES=$(echo "$STAGED_FILES" | grep -E '\.(py|ts|tsx|js|jsx|go|rs)$' || true)

echo "  Rigor: $RIGOR"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MVP 이상: 기본 검사 (모든 rigor 레벨)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 1. 하드코딩된 API 키/시크릿 체크
if [ -n "$CODE_FILES" ]; then
    echo "  하드코딩 API 키 검사..."
    for file in $CODE_FILES; do
        if grep -inE '(api_key|secret|password|token)\s*=\s*["\x27][A-Za-z0-9]{8,}' "$file" 2>/dev/null; then
            echo "    FAIL $file — 하드코딩된 API 키/시크릿 의심"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 2. Python docstring 체크
if [ -n "$PY_FILES" ]; then
    echo "  Python docstring 검사..."
    for file in $PY_FILES; do
        if [[ "$file" == *"__init__.py" ]] || [[ "$file" == *"conftest.py" ]]; then
            continue
        fi
        FIRST_CONTENT=$(grep -m1 -v '^$\|^#\|^from __future__' "$file" 2>/dev/null || true)
        if [[ ! "$FIRST_CONTENT" == '"""'* ]] && [[ ! "$FIRST_CONTENT" == "'''"* ]]; then
            echo "    FAIL $file — 파일 상단에 docstring이 없습니다"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 3. TypeScript JSDoc 체크
if [ -n "$TS_FILES" ]; then
    echo "  TypeScript JSDoc 검사..."
    for file in $TS_FILES; do
        FIRST_CONTENT=$(head -5 "$file" | grep -c '/\*\*' || true)
        if [ "$FIRST_CONTENT" -eq 0 ]; then
            echo "    FAIL $file — 파일 상단에 JSDoc이 없습니다"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 4. 위험한 DB 명령어 체크
if [ -n "$PY_FILES" ]; then
    echo "  위험한 DB 명령어 검사..."
    for file in $PY_FILES; do
        if grep -inE '(DROP TABLE|TRUNCATE|DELETE FROM [a-z_]+ *$|DELETE FROM [a-z_]+ *;)' "$file" 2>/dev/null; then
            echo "    FAIL $file — 위험한 DB 명령어가 감지되었습니다"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 5. Go format 체크
if [ -n "$GO_FILES" ] && command -v gofmt &> /dev/null; then
    echo "  Go format 검사..."
    UNFORMATTED=$(gofmt -l $GO_FILES 2>/dev/null || true)
    if [ -n "$UNFORMATTED" ]; then
        echo "    FAIL 포맷되지 않은 Go 파일:"
        echo "$UNFORMATTED" | sed 's/^/      /'
        ERRORS=$((ERRORS + 1))
    fi
fi

# 6. Rust clippy 체크
if [ -n "$RS_FILES" ] && command -v cargo &> /dev/null && [ -f "Cargo.toml" ]; then
    echo "  Cargo clippy 검사..."
    cargo clippy --quiet 2>/dev/null || ERRORS=$((ERRORS + 1))
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# PRODUCTION 이상: 타입 + 린트 + 테스트 존재
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$RIGOR" == "production" || "$RIGOR" == "enterprise" ]]; then

    # Python 함수 시그니처 타입 체크
    if [ -n "$PY_FILES" ]; then
        echo "  Python 함수 시그니처 타입 검사..."
        for file in $PY_FILES; do
            if [[ "$file" == *"__init__.py" ]] || [[ "$file" == *"conftest.py" ]] || [[ "$file" == *"test_"* ]]; then
                continue
            fi
            # def 뒤에 -> 가 없는 함수
            MISSING_RETURN=$(grep -nE '^\s*def [a-zA-Z_]+\([^)]*\)\s*:' "$file" | grep -v '\->' || true)
            if [ -n "$MISSING_RETURN" ]; then
                echo "    FAIL $file — 리턴 타입이 없는 함수:"
                echo "$MISSING_RETURN" | head -3 | sed 's/^/      /'
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi

    # Ruff lint
    if [ -n "$PY_FILES" ] && command -v ruff &> /dev/null; then
        echo "  Ruff lint 검사..."
        ruff check $PY_FILES || ERRORS=$((ERRORS + 1))
    fi

    # mypy (production: 기본, enterprise: strict)
    if [ -n "$PY_FILES" ] && command -v mypy &> /dev/null; then
        echo "  MyPy 타입 검사..."
        if [[ "$RIGOR" == "enterprise" ]]; then
            mypy $PY_FILES --strict --ignore-missing-imports --no-error-summary 2>/dev/null || ERRORS=$((ERRORS + 1))
        else
            mypy $PY_FILES --ignore-missing-imports --no-error-summary 2>/dev/null || ERRORS=$((ERRORS + 1))
        fi
    fi

    # Go vet
    if [ -n "$GO_FILES" ] && command -v go &> /dev/null; then
        echo "  Go vet 검사..."
        go vet ./... 2>/dev/null || ERRORS=$((ERRORS + 1))
    fi

    # 핵심 모듈 테스트 존재 체크 (core/ 디렉토리 변경 시)
    CORE_FILES=$(echo "$STAGED_FILES" | grep -E '(core/|engine/|models/)' | grep -v 'test_' | grep -v '__pycache__' || true)
    if [ -n "$CORE_FILES" ]; then
        echo "  핵심 모듈 테스트 존재 검사..."
        for file in $CORE_FILES; do
            # 파일에 대응하는 테스트 파일 찾기
            BASENAME=$(basename "$file" | sed 's/\.[^.]*$//')
            TEST_EXISTS=$(find tests/ -name "test_${BASENAME}.*" 2>/dev/null || true)
            if [ -z "$TEST_EXISTS" ]; then
                echo "    WARN $file — 대응하는 테스트 파일이 없습니다 (tests/*/test_${BASENAME}.*)"
                WARNINGS=$((WARNINGS + 1))
            fi
        done
    fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ENTERPRISE: 변수 타입 + 전체 테스트 필수
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if [[ "$RIGOR" == "enterprise" ]]; then

    # 모든 소스 파일에 대응하는 테스트 필수
    NON_TEST_PY=$(echo "$PY_FILES" | grep -v 'test_' | grep -v '__init__' | grep -v 'conftest' || true)
    if [ -n "$NON_TEST_PY" ]; then
        echo "  전체 테스트 존재 검사 (enterprise)..."
        for file in $NON_TEST_PY; do
            BASENAME=$(basename "$file" | sed 's/\.[^.]*$//')
            TEST_EXISTS=$(find tests/ -name "test_${BASENAME}.*" 2>/dev/null || true)
            if [ -z "$TEST_EXISTS" ]; then
                echo "    FAIL $file — 테스트 파일이 반드시 필요합니다 (enterprise)"
                ERRORS=$((ERRORS + 1))
            fi
        done
    fi
fi

# ─── 결과 ────────────────────────────────────────────────

echo ""
if [ $WARNINGS -gt 0 ]; then
    echo "WARN $WARNINGS 건의 경고"
fi
if [ $ERRORS -gt 0 ]; then
    echo "FAIL 검사 실패: $ERRORS 건의 문제 발견 (rigor: $RIGOR)"
    exit 1
else
    echo "PASS 모든 검사 통과 (rigor: $RIGOR)"
    exit 0
fi
