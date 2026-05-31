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
```
