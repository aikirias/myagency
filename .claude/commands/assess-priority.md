# Command: /project:assess-priority

Prioritize a backlog of tickets using the scoring framework from the `priority-assessment` skill.

## What Claude should do

1. Read the list of tickets with their context
2. Apply scoring by criterion: impact, urgency, effort, dependencies, and delay risk
3. Apply overrides for active incidents and committed SLAs
4. Validate whether `P0` and `P1` items fit within available capacity
5. Produce a prioritized backlog with visible justification
6. Identify tickets that need refinement before they can be scored

## Expected input

- List of tickets with title and short description
- Sprint capacity (points or days) — if not provided, prioritize without validating capacity
- Deadlines or committed SLAs if they exist

## Behavior

- If a ticket does not have enough description to assess impact, mark it as "not scorable" and continue with the rest
- If the sum of `P0` and `P1` exceeds capacity, call it out explicitly and propose what to defer
- If an active incident is mentioned, apply the `P0` override automatically and state it explicitly

## Notes

- Scoring is an input to the team's discussion, not a final verdict
- The justification for each score must be readable — the team needs to be able to challenge it
- Use this command before sprint planning, not during it
