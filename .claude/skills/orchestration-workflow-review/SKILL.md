---
name: orchestration-workflow-review
description: Reviews orchestration workflows for scheduling, retries, idempotency, replay safety, and operational risk. Use when reviewing workflow code, scheduler configuration, job dependencies, or when the user asks to review an orchestration workflow.
---

When using this skill:

1. Read the workflow definition, scheduler configuration, and any stated SLA or replay requirements.
2. If critical context is missing, state assumptions explicitly instead of guessing silently.
3. Review the workflow for:
   - deterministic scheduling
   - retry and timeout boundaries
   - idempotency and safe re-runs
   - dependency behavior and waiting strategy
   - replay or backfill safety
   - alerting, ownership, and observability
4. Prioritize blockers before style comments.
5. Recommend concrete configuration or implementation changes when the workflow is unsafe.

Focus areas:

- "Now"-based scheduling is a blocker
- Missing retry or timeout boundaries is an operational risk
- Hidden dependency loops or self-blocking waits are blockers
- Replay behavior must be explicit, not accidental

For detailed standards, use:

- `.claude/rules/orchestration-workflow-guide.md`
- `.claude/rules/data-engineering-principles.md`
- `.claude/rules/backfill-standards.md`

Output format:

```markdown
## Orchestration Workflow Review

### Summary
[What the workflow does, its schedule or trigger, and key risk profile]

### Findings
[BLOCKER] ...
[WARNING] ...
[SUGGESTION] ...

### Recommended Changes
- [specific fix]
```
