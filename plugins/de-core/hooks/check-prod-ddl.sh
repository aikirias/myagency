#!/usr/bin/env bash
# de-core hook: warn when a SQL file contains DDL targeting production-looking schemas.
# PostToolUse on Write|Edit — reads the hook JSON from stdin, checks the file on disk.
# Schema list is configurable per project: export DE_PROD_SCHEMAS="prod dw core_gold"
# Warnings only; the approval boundary for actually EXECUTING DDL is method-safe-operations.

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

[[ -z "$FILE" || "$FILE" != *.sql || ! -f "$FILE" ]] && exit 0

read -r -a PROD_SCHEMAS <<< "${DE_PROD_SCHEMAS:-prod production dw dwh gold mart}"

WARNINGS=()

for SCHEMA in "${PROD_SCHEMAS[@]}"; do
    if grep -qiE "(DROP\s+TABLE|TRUNCATE\s+TABLE|ALTER\s+TABLE|CREATE\s+(OR\s+REPLACE\s+)?TABLE)\s+(IF\s+(NOT\s+)?EXISTS\s+)?${SCHEMA}\." "$FILE" 2>/dev/null; then
        WARNINGS+=("DDL targeting production-looking schema '${SCHEMA}' — requires explicit client approval before executing (method-safe-operations rules 5-6).")
    fi
done

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "=== Production DDL warnings for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  - $w"
    done
fi

exit 0
