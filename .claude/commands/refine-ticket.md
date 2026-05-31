# Command: /project:refine-ticket

Refine one or more vague or incomplete tickets using the `ticket-refinement` skill.

## What Claude should do

1. Read the provided ticket or tickets
2. Evaluate whether they are well-defined using the skill checklist
3. If they are mostly well-defined, complete the missing sections
4. If they are too large, propose a decomposition and generate sub-tickets
5. Mark the open questions that block refinement

## Expected input

- One or more tickets (title, description, and any existing criteria)
- Technical context if applicable (pipeline, table, affected system)

## Behavior

- If the ticket has no description, ask for at least one sentence of context before proceeding
- If the ticket is clearly too large (more than one independent technical component), split it without asking first and explain the criterion used
- If there is scope ambiguity, list it as an open question instead of assuming

## Notes

- The output of this skill should be ready to enter sprint planning
- Refined tickets should be reviewed by the owner before estimation
- A well-refined ticket should not need more than 5 minutes of discussion during planning
