---
name: incident-rca
description: Investigates data pipeline incidents and drafts root cause analyses. Use when a pipeline failed, data is late or wrong, an alert fired, or when the user asks to investigate an incident or write an RCA.
---

When using this skill:

1. Read the failure signal, affected pipeline or table, start time, and recent changes.
2. Define scope first: what failed, since when, and who is affected.
3. Generate read-only diagnostic steps and queries before proposing fixes.
4. Build ranked hypotheses with evidence for and against each one.
5. Recommend safe mitigations and separate them from confirmed root cause.
6. If requested, produce an RCA draft with timeline, cause, impact, and action items.

Do not:

- jump to a fix without narrowing scope
- treat assumptions as confirmed causes
- suggest destructive changes without explicit approval

Useful references:

- `.claude/rules/data-engineering-principles.md`
- `.claude/rules/data-quality-standards.md`
- `.claude/rules/orchestration-workflow-guide.md`

Output format:

```markdown
## Incident Investigation: [pipeline_or_table]

### Summary
[what failed and impact]

### Diagnostic Steps
1. [...]

### Hypotheses
1. [...]

### Mitigation
- [...]

### RCA Draft
- Root cause:
- Contributing factors:
- Action items:
```
