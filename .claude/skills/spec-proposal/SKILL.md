---
name: spec-proposal
description: Creates spec-driven proposals for new pipelines, features, or integrations using OpenSpec. Use when planning a new pipeline, proposing a schema change, documenting a change before implementation, or when the user asks to write a proposal or spec.
---

When using this skill:

1. Identify the feature, pipeline, or change being proposed.
2. Confirm the stakeholder, business objective, and consumer.
3. Create the spec directory at `openspec/specs/<kebab-name>/`.
4. Generate the three files in order: `proposal.md` → `design.md` → `tasks.md`.
5. Follow `.claude/rules/engineering-workflow.md` for when proposal work should hand off to architecture diagrams or implementation.

Do not write implementation code during the proposal phase.

## File structure

```
openspec/specs/<name>/
  proposal.md   — What and why
  design.md     — How (source-to-target, components, trade-offs)
  tasks.md      — Decomposed implementation steps
```

## proposal.md template

```markdown
# Proposal: <title>

**Status**: Draft | Under Review | Accepted | Rejected
**Owner**: [name or team]
**Date**: YYYY-MM-DD

## Problem
[What business or technical problem does this solve?]

## Proposed Solution
[One paragraph: what is being built and why]

## Success Criteria
- [ ] [Verifiable criterion — specific, not vague]

## Out of Scope
- [Explicit exclusions to prevent scope creep]

## Open Questions
| Question | Owner | Due |
|---|---|---|
| | | |
```

## design.md template

```markdown
# Design: <title>

## Source
- System / database / API:
- Table / endpoint / topic:
- Ingestion pattern: full / incremental / streaming

## Target
- Layer: stage / data_model / business_model
- Table: db.schema.table_name
- Grain: one row per [X]

## Transformation logic
[CTEs, business rules, key joins]

## Load pattern
- Idempotency: bounded replace / upsert / delete+insert
- Partition key:
- Frequency:

## Trade-offs
| Option | Pros | Cons |
|---|---|---|

## Dependencies
- Upstream:
- Downstream:

## Open decisions
[TODO: ...]
```

## tasks.md template

```markdown
# Tasks: <title>

- [ ] Create source schema documentation
- [ ] Implement staging pipeline
- [ ] Implement transformation
- [ ] Write data quality checks (freshness, volume, duplicates, nulls)
- [ ] Create runbook
- [ ] Notify downstream consumers
- [ ] Deploy and validate
```

## References

For acceptance criteria format: `.claude/rules/requirements-standards.md`
For pipeline design constraints: `.claude/rules/data-engineering-principles.md`
For DRD structure: `.claude/rules/documentation-standards.md`
For tool sequencing and handoffs: `.claude/rules/engineering-workflow.md`
