# Command: /project:review-orchestration-workflow

Run a review of an orchestration workflow using the `orchestration-workflow-review` skill.

## What Claude should do

1. Read the workflow definition, orchestration code, or scheduler configuration
2. Apply the checklist from `.claude/skills/orchestration-workflow-review/SKILL.md`
3. Assess scheduling, retries, timeout boundaries, dependencies, replay behavior, and alerting
4. Assess idempotency and reprocessing safety explicitly
5. Output findings and recommended configuration or implementation changes

## Expected input

- Workflow definition, orchestration code, or scheduler configuration
- Optionally: required SLA, replay or backfill expectations, and platform name

If replay requirements are not stated, assess replay safety anyway and flag the assumption.

## Notes

- Always check whether scheduling is deterministic
- Missing retry or timeout boundaries is an operational warning at minimum
- If a workflow can block itself through waits or dependency loops, call it out explicitly
- Treat reprocessing safety as a first-class review dimension, not an optional add-on
