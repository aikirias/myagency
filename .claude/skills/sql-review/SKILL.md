---
name: sql-review
description: Reviews SQL queries for correctness, data quality risk, and performance. Use when reviewing SQL, debugging wrong results, tuning a slow query, or when the user asks to review SQL or optimize a query.
---

When using this skill:

1. Read the SQL and determine the intended output from the query or surrounding context.
2. If the engine is not specified, assume ANSI SQL and state that assumption.
3. Review for:
   - correctness of joins, filters, grouping, and date logic
   - grain, duplication risk, and null handling
   - partition pruning and scan risk on large tables
   - safety for `DELETE`, `UPDATE`, and DDL
4. Prioritize wrong results over performance issues.
5. Rewrite only the affected parts unless a larger rewrite is clearly necessary.

Always check:

- `SELECT *`
- accidental Cartesian products
- missing partition filters on large partitioned tables
- implicit type mismatches in joins
- full refresh patterns hidden inside incremental logic

For detailed standards, use:

- `.claude/rules/sql-style-guide.md`
- `.claude/rules/analytical-modeling-guide.md`

Output format:

```text
## SQL Review

### Summary
[what the query does]

### Findings
[BLOCKER] ...
[WARNING] ...
[SUGGESTION] ...

### Proposed Fix
SQL:
-- corrected fragment or query
```
