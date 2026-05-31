# Command: /project:spec-proposal

Create a spec-driven proposal using the `spec-proposal` skill before implementing a new pipeline, feature, or integration.

## What Claude should do

1. Read the request or context from the user's message.
2. Apply the full template from `.claude/skills/spec-proposal/SKILL.md`.
3. Generate the three files: `proposal.md`, `design.md`, and `tasks.md`.
4. Place them in `openspec/specs/<kebab-name>/`.
5. Mark any unknown sections explicitly with `[TODO: ...]`.

## Expected input

The user will provide one of:
- A verbal description of the feature or pipeline to build
- A ticket or issue with partial requirements
- An existing design to formalize into a spec

If the business objective is not clear, ask: "What decision or process does this enable for the business?"

## Notes

- Requires OpenSpec installed: `make install-openspec`
- Do not write implementation code in the proposal phase — the output is documentation only
- For pipeline proposals, the design.md must include grain, load pattern, and idempotency strategy
- Flag missing acceptance criteria and open decisions explicitly
- Cross-reference with `.claude/rules/requirements-standards.md` for definition completeness
