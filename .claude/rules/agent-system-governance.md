# Agent System Governance

These rules apply to the `.claude/` surface itself: agents, skills, commands, hooks, and shared guidance.

## Scope discipline

- Keep the core system small and domain-relevant.
- Add a new agent, skill, or command only when the workflow is recurring enough to justify standardization.
- Do not import large third-party catalogs wholesale.
- Prefer adapting proven patterns to the local domain instead of copying generic frameworks verbatim.

## Authoring rules

- Every agent must have clear frontmatter with at least `name` and `description`.
- Every skill must use `SKILL.md` and frontmatter with at least `name` and `description`.
- Every command must state what it does, what input it expects, and how Claude should behave when input is incomplete.
- Every rule must describe a persistent standard, not a one-off task.

## Routing rules

- Use agents for judgment and role-specific trade-offs.
- Use skills for repeatable checklists and output formats.
- Use commands as entry points, not as the place where workflow logic lives.
- Use rules for standards that should apply regardless of task entry point.

## Change management

- Prefer additive changes over large reorganizations of the `.claude/` surface.
- Do not rename or split agents, skills, or commands unless the old shape is causing recurring problems.
- When a recurring failure appears, first decide whether it belongs in a rule, a skill checklist, or an agent responsibility.
- Keep descriptions concrete enough for reliable matching.

## Validation

- Run `make validate-claude` after changing agent, skill, command, or rule files.
- Treat malformed metadata, missing frontmatter, or ambiguous routing as defects.
- Keep examples aligned with the actual repo structure and current workflows.
