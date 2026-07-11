#!/usr/bin/env bash
# de-core hook: warn on risky SQL patterns after a file is written or edited.
# PostToolUse on Write|Edit — reads the hook JSON from stdin, checks the file on disk.
# Warnings go to stdout (surfaced to Claude as context); never blocks.

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ -z "$FILE" || "$FILE" != *.sql || ! -f "$FILE" ]] && exit 0

WARNINGS=()

if grep -qiE 'SELECT\s+\*' "$FILE" 2>/dev/null; then
    WARNINGS+=("SELECT * found — name columns explicitly in production queries (practice-sql-quality).")
fi

if grep -qiE '^\s*DELETE\s+FROM\s+\S+\s*;?\s*$' "$FILE" 2>/dev/null; then
    WARNINGS+=("DELETE without WHERE clause — this deletes all rows.")
fi

if grep -qiE '^\s*UPDATE\s+\S+\s+SET\s+' "$FILE" 2>/dev/null && ! grep -qiE '\bWHERE\b' "$FILE" 2>/dev/null; then
    WARNINGS+=("UPDATE without WHERE clause found.")
fi

if grep -qiE 'DROP\s+TABLE' "$FILE" 2>/dev/null; then
    WARNINGS+=("DROP TABLE found — confirm intent; never in pipeline logic, migrations only.")
fi

if grep -qiE '^\s*TRUNCATE' "$FILE" 2>/dev/null; then
    WARNINGS+=("TRUNCATE found — confirm intent; never in pipeline logic, migrations only.")
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "=== SQL warnings for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  - $w"
    done
fi

exit 0
