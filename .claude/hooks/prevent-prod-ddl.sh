#!/usr/bin/env bash
# Warn when a SQL file contains DDL targeting production schemas.
# Customize PROD_SCHEMAS to match your environment.
# This hook warns by default — change exit code to 1 to block.

FILE="$1"

# Only run on .sql files
if [[ "$FILE" != *.sql ]]; then
    exit 0
fi

# Customize: add your production schema names here
PROD_SCHEMAS=("prod" "production" "dw" "dwh" "gold" "mart")

WARNINGS=()

for SCHEMA in "${PROD_SCHEMAS[@]}"; do
    # Match common DDL forms like:
    # ALTER TABLE dw.fact_orders ...
    # DROP TABLE dw.fact_orders
    # TRUNCATE TABLE dw.fact_orders
    # CREATE TABLE dw.fact_orders ...
    # CREATE OR REPLACE TABLE dw.fact_orders ...
    if grep -qiE "(DROP\s+TABLE|TRUNCATE\s+TABLE|ALTER\s+TABLE|CREATE\s+TABLE|CREATE\s+OR\s+REPLACE\s+TABLE)\s+${SCHEMA}\." "$FILE" 2>/dev/null; then
        WARNINGS+=("WARNING: DDL targeting production schema '${SCHEMA}' found in $FILE — review before executing.")
    fi
done

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo "=== Production DDL Warning for $FILE ==="
    for w in "${WARNINGS[@]}"; do
        echo "  $w"
    done
    echo ""
    echo "  If this is intentional, proceed. This hook warns only — it does not block."
    echo "  To block production DDL, change 'exit 0' to 'exit 1' at the end of this script."
    echo "========================================="
    echo ""
fi

# Exit 0 = warn only. Change to exit 1 to block.
exit 0
