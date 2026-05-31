---
name: technical-use-case-generation
description: Converts a functional specification into technical data use cases and implementation components. Use when decomposing a requirement into datasets, pipelines, contracts, quality checks, and delivery tracks, or when the user asks to generate technical use cases.
---

When using this skill:

1. Read the functional specification or validated requirements.
2. Identify the business use cases and map each one to technical components:
   - source systems
   - target datasets or models
   - processing workflows
   - transformation logic
   - data quality checks
   - exposure or consumption layers
3. Note dependencies, risks, observability needs, and rough effort.
4. Keep each technical use case concrete enough to become one or more implementation tickets.
5. If the specification is incomplete, state what is missing before inventing details.
6. Use `.claude/rules/engineering-workflow.md` to decide whether the next handoff is proposal refinement, architecture design, or implementation planning.

Output format:

```markdown
## Technical Use Cases: [initiative_name]

### Use Case 1
- Business origin:
- Components:
- Acceptance criteria:
- Dependencies:
- Risks:
```
