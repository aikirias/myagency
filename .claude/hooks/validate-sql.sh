#!/usr/bin/env bash
# Validate SQL files for common risky patterns before writing.
# Called by Claude Code as a PreToolUse hook on Write operations.

FILE="$1"

# Only run on .sql files
if [[ "$FILE" != *.sql ]]; then
    exit 0
fi

WARNINGS=()

# Warn on SELECT *
if grep -qiE 'SELECT\s+\*' "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: SELECT * found in $FILE — specify columns explicitly in production queries.")
fi

# Warn on DELETE without WHERE
if grep -qiE '^\s*DELETE\s+FROM\s+\S+\s*$' "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: DELETE without WHERE clause found in $FILE — this will delete all rows.")
fi

# Warn on UPDATE without WHERE
if grep -qiE '^\s*UPDATE\s+\S+\s+SET\s+' "$FILE" 2>/dev/null; then
    if ! grep -qiE 'WHERE' "$FILE" 2>/dev/null; then
        WARNINGS+=("WARNING: UPDATE without WHERE clause found in $FILE.")
    fi
fi

# Warn on DROP TABLE
if grep -qiE 'DROP\s+TABLE' "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: DROP TABLE found in $FILE — confirm this is intentional and not targeting production.")
fi

# Warn on TRUNCATE
if grep -qiE '^\s*TRUNCATE' "$FILE" 2>/dev/null; then
    WARNINGS+=("WARNING: TRUNCATE found in $FILE — confirm this is intentional and not targeting production.")
fi

# Output warnings
if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo "=== SQL Validation Warnings for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  $w"
    done
    echo "============================================"
    echo ""
fi

# Exit 0 — warnings only, do not block the write
exit 0
