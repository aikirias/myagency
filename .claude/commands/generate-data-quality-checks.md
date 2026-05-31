# Command: /project:generate-data-quality-checks

Generate data quality checks for a dataset or pipeline using the `data-quality-review` skill.

## What Claude should do

1. Read the dataset or pipeline context provided
2. Apply the checklist from `.claude/skills/data-quality-review/SKILL.md`
3. Identify which check categories are covered and which are missing
4. Generate checks for the missing coverage
5. Assign threshold, severity, owner placeholder, and alert path to each check
6. Output a complete data quality check set

## Expected input

- Dataset or table name
- Business key or uniqueness definition
- Time column or refresh signal
- Load frequency and expected availability
- Any known business rules or constraints

If thresholds are not provided, use conservative defaults and state the assumption.

## Notes

- Always generate at minimum: freshness, volume, and duplicate checks
- Severity must be assigned to every check
- Owner should be a placeholder (`[TBD]`) if not provided
- Prefer checks that are actionable and cheap to operate
