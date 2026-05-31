---
name: priority-assessment
description: Prioritizes tickets or initiatives using explicit scoring and visible tradeoffs. Use when grooming a backlog, comparing urgency, evaluating cost of delay, or when the user asks to prioritize tickets, initiatives, or backlog items.
---

When using this skill:

1. Read the list of tickets or initiatives plus any deadline, dependency, and capacity context.
2. Score each item using explicit criteria:
   - business impact
   - urgency
   - effort
   - dependencies
   - cost of delay
3. Apply override rules only when there is a clear production or contractual reason.
4. Flag items that are too vague to prioritize reliably.
5. Produce a ranked list with visible justification.

Use the shared framework in:

- `.claude/rules/prioritization-framework.md`

Output format:

```markdown
## Prioritized Backlog

### Scoring
| Item | Impact | Urgency | Effort | Dependencies | Delay Risk | Total | Priority |
|---|---|---|---|---|---|---|---|

### Ordered Backlog
1. [item] — [why]

### Unclear Items
- [...]
```
