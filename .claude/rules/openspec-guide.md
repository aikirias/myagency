# OpenSpec Guide

## What it is

OpenSpec is a spec-driven development framework for planning, documenting, and tracking changes as structured proposals before implementation starts.

- Docs: https://openspec.dev
- Install: `make install-openspec`

## When to use

Create an OpenSpec proposal before implementing:
- A new pipeline or ingestion source
- A schema change that affects downstream consumers
- A new data product or serving table
- Any change that requires stakeholder alignment before work begins

## File structure

```
openspec/
  specs/
    <feature-name>/
      proposal.md     # What and why
      design.md       # How
      tasks.md        # Decomposed steps
```

Use `kebab-case` for the feature directory name.

## Workflow

1. **Propose** — articulate the problem and solution in `proposal.md`
2. **Design** — define source-to-target, load pattern, and trade-offs in `design.md`
3. **Decompose** — break into implementable tasks in `tasks.md`
4. Move to implementation only after design is reviewed

## proposal.md format

```markdown
# Proposal: <title>

**Status**: Draft | Under Review | Accepted | Rejected
**Owner**: [team or person]
**Date**: YYYY-MM-DD

## Problem
[What breaks or is missing without this?]

## Proposed Solution
[One paragraph. What is being built and why.]

## Success Criteria
- [ ] [Verifiable. Not "pipeline works" — use row counts, SLAs, specific checks.]

## Out of Scope
- [List explicit exclusions to prevent scope creep]

## Open Questions
| Question | Owner | Due |
|---|---|---|
```

## design.md format for pipelines

```markdown
# Design: <title>

## Source
- System:
- Table / endpoint / topic:
- Ingestion pattern: full refresh | incremental | streaming

## Target
- Layer: stage | data_model | business_model
- Table: db.schema.table_name
- Grain: one row per [X]

## Transformation logic
[Key CTEs, joins, business rules]

## Load pattern
- Idempotency: bounded replace | upsert | delete+insert
- Partition key:
- Frequency:
- Backfill strategy:

## Trade-offs
| Option | Pros | Cons | Decision |
|---|---|---|---|

## Dependencies
- Upstream:
- Downstream:

## Open decisions
[TODO: ...]
```

## tasks.md format

```markdown
# Tasks: <title>

- [ ] Document source schema
- [ ] Create staging pipeline
- [ ] Implement transformation
- [ ] Write data quality checks (freshness, volume, duplicates, nulls)
- [ ] Write runbook
- [ ] Notify downstream consumers
- [ ] Deploy to staging, validate
- [ ] Deploy to production
```

## Standards integration

- Acceptance criteria: `.claude/rules/requirements-standards.md`
- Pipeline design constraints: `.claude/rules/data-engineering-principles.md`
- DRD structure: `.claude/rules/documentation-standards.md`
- Backfill planning: `.claude/rules/backfill-standards.md`
