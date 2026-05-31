# Documentation Standards

## When documentation is required

| Change | Required documentation |
|---|---|
| New pipeline | DRD before implementation, runbook before go-live |
| Significant architecture change | ADR |
| Recurring operational task | Runbook |
| New or changed work item | Technical ticket / Plane issue with acceptance criteria |
| Production incident | RCA within 3 business days |
| Decommissioning a table | Migration notice + updated downstream documentation |

## ADR (Architecture Decision Record)

Use when a significant technical decision was made that others need to understand later.

Required sections:
- **Title**: `ADR-[number]: [Decision title]`
- **Date** and **Status** (Proposed / Accepted / Deprecated)
- **Context**: What problem or situation led to this decision
- **Decision**: What was decided, in one clear sentence
- **Consequences**: What this enables and what it trades away
- **Alternatives considered**: At least two alternatives with rejection reasons

Keep ADRs short. If it takes more than one page to explain a decision, the decision is not clear yet.

## DRD (Design Review Document)

Use before implementing a new pipeline, system, or major change.

Required sections:
- Business objective (what problem this solves for the business)
- Proposed design (source-to-target, components, technology)
- Trade-offs (what this design optimizes for, and what it gives up)
- Open questions (unresolved decisions with owners)
- Dependencies (upstream systems, external teams)
- Success criteria (how we know this is working correctly)

A DRD without a business objective section is incomplete.

## Runbook

Use for any operational task that is performed more than once.

Required sections:
- **When to use**: exact trigger condition (alert, schedule, request)
- **Prerequisites**: access, tools, environment
- **Steps**: numbered, specific, and executable
- **Rollback steps**: what to do if the procedure fails partway through
- **Escalation**: who to contact if the runbook does not resolve the issue

A runbook must be executable by someone who did not write it.

## Technical ticket / Plane issue

Required fields:
- Title: imperative verb + specific outcome ("Add incremental load for fact_orders from MSSQL")
- Type: Task / Bug / Story / Spike
- Priority: `urgent` / `high` / `medium` / `low` / `none`
- Description: context + what needs to be done
- Acceptance criteria: testable conditions, not vague statements
- Technical notes: implementation hints, constraints, links
- Dependencies: what blocks this, what this blocks

Acceptance criteria must be specific: "Row count for fact_orders matches source within 0.1%" not "Pipeline works correctly."

## Writing tone

- Engineering documentation: precise, minimal, direct
- Business-facing documentation: clear, jargon-free, outcome-focused
- Avoid: passive voice, "we should consider", "it may be possible"
- Prefer: "Do X", "This causes Y", "Owner: [name]"

## TODO markers

When a section is incomplete, mark it clearly:

```
[TODO: Define the threshold for the row count check]
[TODO: Confirm source schema with the MSSQL team]
```

Never leave implicit gaps — always mark what is missing.
