# Command: /project:review-sql

Run a SQL review using the `sql-review` skill.

## What Claude should do

1. Read the SQL query provided (pasted, open file, or selected text)
2. Apply the checklist from `.claude/skills/sql-review/SKILL.md`
3. Check correctness, data quality risk, and performance
4. Apply platform-specific checks only if the engine is known or implied by the context
5. Output findings ordered by severity
6. Produce a corrected or optimized version if changes are needed

## Expected input

- SQL query (one or more queries)
- Optionally: database engine, table sizes, business intent

If the query purpose is unclear, infer from the query structure. State the inference as an assumption.

## Notes

- Lead with correctness issues before performance
- A query that produces wrong results is always a BLOCKER, regardless of performance
- Only rewrite the full query if more than half of it needs to change
- Flag SELECT * even if it is in a subquery or CTE
