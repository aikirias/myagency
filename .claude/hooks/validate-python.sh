#!/usr/bin/env bash
# Validate Python files for syntax errors and common DAG issues before writing.
# Called by Claude Code as a PreToolUse hook on Write operations.

FILE="$1"

# Only run on .py files
if [[ "$FILE" != *.py ]]; then
    exit 0
fi

WARNINGS=()

# Syntax check
if command -v python3 &>/dev/null; then
    SYNTAX_OUTPUT=$(python3 -m py_compile "$FILE" 2>&1)
    if [ $? -ne 0 ]; then
        echo ""
        echo "=== Python Syntax Error in $FILE ==="
        echo "$SYNTAX_OUTPUT"
        echo "====================================="
        echo ""
        # Exit 1 to block the write on syntax errors
        exit 1
    fi
fi

# Warn on hardcoded secrets patterns
if grep -qE "(password|passwd|secret|token|api_key)\s*=\s*['\"][^'\"]{4,}" "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: Possible hardcoded secret found in $FILE — use Airflow Connections or a secrets backend.")
fi

# Warn on print statements in DAG files
if [[ "$FILE" == *dag* ]] || [[ "$FILE" == *DAG* ]]; then
    if grep -qE '^\s*print\s*\(' "$FILE" 2>/dev/null; then
        WARNINGS+=("WARNING: print() statement found in DAG file $FILE — use logging.info() instead.")
    fi
fi

# Warn on datetime.now() as start_date
if grep -qE 'start_date\s*=\s*datetime\.now\(\)' "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: datetime.now() used as start_date in $FILE — use a fixed datetime instead.")
fi

# Warn on catchup=True
if grep -qE "catchup\s*=\s*True" "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: catchup=True found in $FILE — confirm this is intentional and the pipeline is idempotent.")
fi

# Output warnings
if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo "=== Python Validation Warnings for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  $w"
    done
    echo "============================================="
    echo ""
fi

exit 0
