---
name: ticket-refinement
description: Refines vague or oversized tickets into clear, estimable work items. Use when grooming a ticket, splitting scope, clarifying acceptance criteria, or when the user asks to refine a ticket.
---

When using this skill:

1. Read the current ticket and identify ambiguity, missing acceptance criteria, or oversized scope.
2. Decide whether the ticket should be clarified in place or split into smaller tickets.
3. Make the output specific enough to estimate and implement.
4. For Data Engineering work, explicitly cover affected datasets or pipelines, production impact, backfill needs, data quality, and documentation.
5. Flag open questions that still block refinement.

Prefer tickets that are:

- small enough to complete in a sprint
- scoped to one main objective
- testable through explicit acceptance criteria

Output format:

```markdown
## Refined Ticket: [title]

### Summary
[what should be done and why]

### Acceptance Criteria
- [ ]

### Dependencies
- [...]

### Open Questions
- [...]
```
