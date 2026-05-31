---
name: data-eng-plan-review
description: Reviews a data pipeline, ingestion, or modeling plan before implementation. Use when evaluating a design, technical approach, source-to-target flow, or when the user asks to review a technical data plan.
---

When using this skill:

1. Read the plan, ticket, or problem statement.
2. Extract the business goal, source systems, target design, load strategy, SLA, and ownership.
3. Identify missing decisions before implementation starts.
4. Review the plan for:
   - correctness of the target grain and model boundaries
   - incremental vs full-load strategy
   - idempotency and backfill readiness
   - data quality coverage
   - operational readiness and monitoring
5. Separate blockers from warnings and open questions.

If input is partial, do not stop. Review what is present and list what is missing.

For detailed standards, use:

- `.claude/rules/data-engineering-principles.md`
- `.claude/rules/analytical-modeling-guide.md`
- `.claude/rules/data-quality-standards.md`

Output format:

```markdown
## Data Engineering Plan Review

### Summary
[what is being proposed]

### Blockers
- [...]

### Warnings
- [...]

### Open Questions
- [...]
```
