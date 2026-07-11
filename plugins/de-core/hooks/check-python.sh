#!/usr/bin/env bash
# de-core hook: validate Python files after write/edit — syntax check + secret scan.
# PostToolUse on Write|Edit — reads the hook JSON from stdin, checks the file on disk.
# Syntax errors exit 2 so Claude gets blocking feedback and fixes the file.
# Orchestrator-specific checks (Airflow start_date, catchup, ...) live in the stack packs.

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ -z "$FILE" || "$FILE" != *.py || ! -f "$FILE" ]] && exit 0

if command -v python3 &>/dev/null; then
    if ! SYNTAX_OUTPUT=$(python3 -m py_compile "$FILE" 2>&1); then
        echo "Python syntax error in $FILE:" >&2
        echo "$SYNTAX_OUTPUT" >&2
        exit 2
    fi
fi

if grep -qE "(password|passwd|secret|token|api_key)\s*=\s*['\"][^'\"]{4,}" "$FILE" 2>/dev/null; then
    echo "=== Python warnings for $FILE ==="
    echo "  - Possible hardcoded secret — use the client's secret mechanism, never literals (method-safe-operations rule 12)."
fi

exit 0
