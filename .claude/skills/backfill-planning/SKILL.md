---
name: backfill-planning
description: Designs safe backfill plans for pipelines and tables. Use when reprocessing history, planning a backfill, recovering from failed loads, or when the user asks to generate a backfill plan.
---

When using this skill:

1. Gather the pipeline or table name, date range, reason, estimated volume, and operational constraints.
2. Verify whether the pipeline is idempotent and whether source data is available for the full range.
3. Define the execution strategy:
   - batch size and order
   - concurrency limits
   - validation checkpoints
   - rollback approach
4. Isolate backfill activity from normal production scheduling whenever possible.
5. Call out blockers clearly if idempotency, source availability, or rollback safety is not established.

Always cover:

- scope and date range
- execution batches
- QA and reconciliation
- source and target load risk
- rollback and communication plan

For detailed standards, use:

- `.claude/rules/backfill-standards.md`
- `.claude/rules/data-engineering-principles.md`

Output format:

```markdown
## Backfill Plan: [pipeline_or_table]

### Summary
[why the backfill is needed]

### Assumptions
- [...]

### Execution Plan
1. [...]

### QA Checks
- [...]

### Rollback
- [...]

### Risks
- [...]
```
