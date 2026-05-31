# Command: /project:architecture-diagram

Create or update a LikeC4 architecture diagram using the `architecture-diagram` skill.

## What Claude should do

1. Identify the scope from the user's message: full platform, specific pipeline, or component view.
2. Apply the full checklist from `.claude/skills/architecture-diagram/SKILL.md`.
3. Determine the appropriate C4 level and view type.
4. Generate the `.likec4` file in `architecture/`.
5. Suggest the preview command: `likec4 serve architecture/<file>.likec4`.

## Expected input

The user will provide one of:
- A verbal description of the system or pipeline to diagram
- An existing design document or DRD to convert into a diagram
- A request to update an existing `.likec4` file

If the scope is ambiguous, ask one clarifying question: "What is the audience — technical design review or stakeholder communication?"

## Notes

- Requires LikeC4 installed: `make install-likec4`
- For DRDs, generate a container-level (L2) diagram as the default
- Every element must have an explicit label and every relationship must have a description
- Do not use `include *` in views — be explicit
