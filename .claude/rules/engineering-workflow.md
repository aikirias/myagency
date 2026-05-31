# Engineering Workflow

Use this rule to sequence discovery, design, implementation, and publication work across Understand Anything, OpenSpec, LikeC4, Backstage, and the local agent/skill system.

## Tool roles

- `Understand Anything` is for discovery, dependency mapping, onboarding, and change-impact analysis.
- `OpenSpec` is for proposal work before implementing non-trivial changes.
- `LikeC4` is for architecture expression and C4 diagrams.
- `Backstage` is for publishing components, ownership, architecture, and operational documentation after the work is defined or delivered.

Do not use these tools interchangeably.

- Do not use `OpenSpec` as a replacement for discovery.
- Do not use `LikeC4` before the design intent is understood.
- Do not use `Backstage` as the primary design tool.
- Do not treat `Understand Anything` output as a substitute for a reviewed proposal.

## Workflow A: Existing system discovery

Use this flow when entering an unfamiliar codebase, legacy pipeline, or externally owned system.

1. Start with `Understand Anything`.
   - Build or refresh the knowledge graph.
   - Map entrypoints, dependencies, owners, and likely impact areas.
2. Summarize what is known and what is still ambiguous.
3. If a meaningful change is likely, write an `OpenSpec` proposal before implementation.
4. If structure, boundaries, or integrations are non-trivial, create or update `LikeC4` diagrams.
5. Publish or register the resulting understanding in `Backstage` when the knowledge should be shared operationally.

Expected outputs:

- system summary
- dependency map
- impact notes
- proposal or design pack when changes are needed
- published ownership or documentation when relevant

## Workflow B: New capability delivery

Use this flow when creating a new pipeline, integration, data product, or structural change.

1. Start from requirements or discovery.
2. Use `OpenSpec` before implementation for non-trivial work.
   - capture problem, scope, success criteria, trade-offs, and open questions
3. Use `LikeC4` to express the design.
   - context, containers, components, and flow where appropriate
4. Implement through the relevant agents, skills, and commands.
5. Use `Backstage` to publish the resulting component, docs, ownership, and operational links when the work is ready to expose.

Expected outputs:

- accepted or reviewable proposal
- architecture diagrams
- implementation tasks
- published component or documentation surface when applicable

## Routing guidance

- Use `codebase-understanding` first when the system is unfamiliar.
- Use `spec-proposal` before non-trivial implementation.
- Use `architecture-diagram` when design boundaries or integrations need to be visible.
- Use implementation and review skills only after the intended pattern is clear enough to execute safely.

## Decision rules

- If the current system is not understood, do discovery before proposing implementation.
- If the change is non-trivial, do proposal work before coding.
- If the architecture is non-trivial, produce diagrams before or alongside implementation.
- If the result should be discoverable by others, publish it in `Backstage` after it is stable enough to expose.

## Data Engineering interpretation

For this workspace, the workflow should surface these questions explicitly before build starts:

- batch vs micro-batch vs streaming
- current-state vs append-only vs SCD1 vs SCD2
- raw vs curated vs serving responsibilities
- ownership, observability, and rollback posture
- downstream consumer impact
