# Command: /project:codebase-understanding

Explore, map, or explain codebase structure and pipeline logic using the `codebase-understanding` skill.

## What Claude should do

1. Identify the exploration goal from the user's message.
2. Route to the appropriate Understand Anything command using the table in `.claude/skills/codebase-understanding/SKILL.md`.
3. If the knowledge graph has not been built, instruct the user to run `/understand` first.
4. Interpret results in the context of data engineering: pipeline ownership, data flow, downstream impact.

## Expected input

The user will provide one of:
- A question about a specific pipeline, table, or transformation
- A request to map dependencies before a change
- A request to generate an onboarding guide
- A request to understand how legacy code works

If the intent is ambiguous, ask: "Are you exploring to understand the codebase, or to assess the impact of a specific change?"

## Notes

- Requires Understand Anything installed: `make install-understand-anything`
- Run `/understand` once after cloning before using other commands
- For pre-deploy impact analysis, always run `/understand-diff` and cross-reference with downstream consumers
- Knowledge graph lives in `.understand-anything/knowledge-graph.json` — commit it
