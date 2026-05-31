---
name: documentation-generation
description: Generates structured Data Engineering documentation such as ADRs, DRDs, runbooks, technical tickets, and concise delivery summaries. Use when writing technical docs, documenting a decision, creating a ticket, or when the user asks to generate technical documentation.
---

When using this skill:

1. Identify the target document type from the request.
2. If the type is ambiguous, infer the most likely format and state the assumption.
3. Generate concise, operational documentation with explicit owners, risks, and next steps.
4. Prefer templates that are easy to paste into Markdown, Plane, or Notion.
5. Do not add generic filler or long narrative context.

Supported document types:

- ADR: decision, context, alternatives, consequences
- DRD: design, dependencies, trade-offs, open questions
- Runbook: trigger, steps, validation, rollback
- Technical ticket: scope, acceptance criteria, notes, dependencies
- Summary: what changed, why, risks, follow-up

For ticket-specific standards, use:

- `.claude/rules/documentation-standards.md`
- `.claude/rules/plane-integration.md`

Output format:

```markdown
# [Document Title]

## Context
[brief context]

## Main Content
[document-type-specific content]

## Risks / Open Questions
- [...]
```
