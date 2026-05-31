---
name: data-pr-review
description: Reviews Data Engineering pull requests for correctness, operational safety, DDL risk, data quality coverage, and merge readiness. Use when reviewing a PR, checking changed transformations or workflows, or when the user asks to review a data PR.
---

When using this skill:

1. Read the PR description, changed files, and any deployment or backfill notes.
2. Review the diff by change type:
   - SQL logic
   - orchestration definitions or workflow code
   - DDL or schema changes
   - data quality, docs, and operational metadata
3. Flag correctness and operational risks before style issues.
4. Check whether the change is additive, backward compatible, and safe to deploy.
5. If a backfill or downstream impact is implied, call it out explicitly.

Focus on:

- wrong results or duplication risk
- destructive schema changes
- missing retries, timeouts, alerts, or data quality coverage
- undocumented rollout or rollback expectations
- **architecture diagram currency**: if the PR adds, removes, or changes a pipeline component, data flow, layer assignment, or system relationship, verify that the corresponding `architecture/*.likec4` file was updated. A PR that changes pipeline topology without updating the diagram is not merge-ready.
- **DQ two-layer completeness**: if the PR introduces a new dataset or pipeline, verify that both Layer 1 (SQL check definitions in `migrations/`) and Layer 2 (automated executor DAG or tasks) are present. A new pipeline with only SQL checks and no executor is not merge-ready.

For detailed standards, use:

- `.claude/rules/sql-style-guide.md`
- `.claude/rules/orchestration-workflow-guide.md`
- `.claude/rules/data-quality-standards.md`
- `.claude/rules/git-and-pr-conventions.md`

Output format:

```markdown
## PR Review: [title]

### Summary
[what changed and why it matters]

### Blockers
- [...]

### Warnings
- [...]

### Suggestions
- [...]

### Architecture diagram and Backstage sync
- [ ] Topology unchanged — no diagram or catalog update needed
- [ ] Topology changed — `architecture/<file>.likec4` updated and passes completeness checklist
- [ ] Topology changed — `catalog-info.yaml` updated to match diagram changes
- [ ] New external API added — registered as `kind: API` in `catalog-info.yaml` (BLOCKER if missing)
- [ ] Topology changed — diagram or catalog update missing (BLOCKER)

### Data quality coverage
- [ ] No new dataset or pipeline introduced — no DQ check required
- [ ] New dataset/pipeline — Layer 1 present: SQL check definitions in `migrations/<xx>-<dataset>-dq.sql`
- [ ] New dataset/pipeline — Layer 2 present: automated executor DAG or tasks in `airflow/dags/`
- [ ] Layer 1 present but Layer 2 missing (BLOCKER)
- [ ] Execution spec documented (pattern, schedule, failure behavior, result log)
```
