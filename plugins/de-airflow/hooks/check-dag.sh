#!/usr/bin/env bash
# de-airflow hook: warn on classic Airflow DAG-file mistakes after write/edit.
# PostToolUse on Write|Edit — reads hook JSON from stdin, checks the file on disk.
# Warnings only; ported from the legacy validate-python.sh Airflow-specific checks.

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ -z "$FILE" || "$FILE" != *.py || ! -f "$FILE" ]] && exit 0

# Only check files that look like DAG definitions
grep -qE '(from airflow|import airflow|@dag\b|DAG\()' "$FILE" 2>/dev/null || exit 0

WARNINGS=()

if grep -qE 'start_date\s*=\s*datetime\.now\(\)' "$FILE" 2>/dev/null; then
    WARNINGS+=("dynamic start_date=datetime.now() — use a fixed datetime; dynamic dates break scheduling determinism.")
fi

if grep -qE 'catchup\s*=\s*True' "$FILE" 2>/dev/null; then
    WARNINGS+=("catchup=True — confirm the DAG is interval-idempotent before enabling catch-up (airflow-consulting-notes).")
fi

if grep -qE '^\s*print\s*\(' "$FILE" 2>/dev/null; then
    WARNINGS+=("print() in a DAG file — use logging so output lands in task logs.")
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "=== Airflow DAG warnings for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  - $w"
    done
fi

exit 0
