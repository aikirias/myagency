---
name: requirements-discovery
description: Turns vague business requests into concrete discovery questions and a functional specification. Use when requirements are unclear, preparing stakeholder discovery, clarifying scope, or when the user asks to discover or refine requirements.
---

When using this skill:

1. Read the initial request and identify what is known versus ambiguous.
2. Ask targeted discovery questions about:
   - business goal
   - urgency and deadline
   - definitions and metrics
   - consumers and frequency
   - edge cases and historical coverage
3. Distinguish real blockers from nice-to-have clarifications.
4. If enough information exists, produce a functional specification draft.
5. Make missing assumptions visible instead of filling them silently.

Use the shared standards in:

- `.claude/rules/requirements-standards.md`
- `.claude/rules/prioritization-framework.md`

Output format:

```markdown
## Discovery: [request_name]

### Current Understanding
[one-sentence summary]

### Questions
1. [...]

### Draft Functional Spec
- Goal:
- Consumers:
- Frequency:
- Acceptance criteria:
```
