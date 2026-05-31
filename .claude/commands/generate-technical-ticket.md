# Command: /project:generate-technical-ticket

Generate a Plane-ready technical ticket using the `documentation-generation` skill.

## What Claude should do

1. Read the task description provided
2. Apply the ticket template from `.claude/skills/documentation-generation/SKILL.md`
3. Infer type, priority, and acceptance criteria from context
4. Add technical notes and implementation hints based on the Data Engineering context
5. Output a complete, ready-to-copy technical ticket

## Expected input

- What needs to be done
- Why it needs to be done
- Any known constraints, dependencies, or technical details
- Priority (if not specified, infer from context and state the assumption using `urgent | high | medium | low | none`)

## Notes

- Acceptance criteria must be specific and testable — avoid vague criteria like "pipeline works"
- Include a `Technical notes` section with implementation hints even when not asked
- Flag any open questions that would block implementation
- If the task involves a production change, add a `Deployment notes` section
- Format the output so it can be pasted directly into Plane, Notion, or markdown
