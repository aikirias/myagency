# Command: /project:generate-backfill-plan

Generate a safe backfill execution plan using the `backfill-planning` skill.

## What Claude should do

1. Read the pipeline and context provided
2. Apply the checklist from `.claude/skills/backfill-planning/SKILL.md`
3. Verify idempotency is confirmed or flag it as a blocker
4. Define batch size, execution order, and QA checkpoints
5. Define rollback procedure
6. Output a complete backfill plan document

## Expected input

- Pipeline or workflow name
- Target table
- Date range
- Reason for the backfill
- Estimated volume
- Whether the pipeline is idempotent

If idempotency is not confirmed, stop and ask before generating the plan. A backfill on a non-idempotent pipeline is a BLOCKER.

## Notes

- Default batch size: 7 days unless volume or source constraints suggest otherwise
- Default execution order: oldest to newest
- Always include downstream consumer notification in the communication plan
- Flag if the backfill overlaps with a current production load window
