# Prioritization Framework

## Core principle

The priority of a ticket is not the urgency perceived by the requester. It is a function of the impact created if it is done, the cost of not doing it now, and the effort it requires. These three factors must be explicit and debatable.

## Scoring criteria

Score each ticket from 0 to 3 for every criterion:

### Business impact (what value it creates if done)

| Score | Description |
|---|---|
| 0 | There is no clear impact or it is not justified |
| 3 | Enables a critical business decision, unblocks a business process, or has direct impact on revenue or customers |
| 2 | Improves an existing process, reduces manual work, or improves the quality of data the business already uses |
| 1 | Nice to have, cosmetic improvement, or impact is difficult to quantify |

### Urgency (cost of waiting)

| Score | Description |
|---|---|
| 0 | No deadline, no concrete consequence from delay, or urgency is not justified |
| 3 | There is a committed SLA this week, an active incident, or a hard business deadline |
| 2 | There is a deadline in the next 2-4 weeks or debt is accumulating over time |
| 1 | No defined deadline and no cost to waiting until the next sprint |

### Effort (inverse: less effort = more points)

| Score | Description |
|---|---|
| 0 | XL — more than 2 weeks or effort still uncertain |
| 3 | S — 1 to 2 days |
| 2 | M — 3 to 5 days |
| 1 | L/XL — more than one week |

### Dependencies (effect on the team)

| Score | Description |
|---|---|
| 0 | Blocked by unresolved external dependencies |
| 3 | Unblocks 2 or more tickets from other people or teams |
| 2 | Independent — neither blocked nor blocking |
| 1 | Blocked by another unresolved ticket |

### Delay risk (what happens if this is not done now)

| Score | Description |
|---|---|
| 0 | No material consequence if it waits |
| 3 | Production, customer, or SLA impact if delayed |
| 2 | Accumulates technical debt or makes future work more expensive |
| 1 | No material consequence from waiting |

## Priority table

| Total score | Priority | Action |
|---|---|---|
| 13-15 | P0 | Goes into the immediate sprint; if not included, something breaks |
| 10-12 | P1 | Goes into the sprint if there is capacity |
| 7-9 | P2 | Next sprint |
| 4-6 | P3 | Refined backlog, no committed date |
| 0-3 | P4 | Discardable, on hold, or not justified yet |

## Automatic overrides

These scenarios move a ticket to P0 regardless of score:

- **Active production incident** — any ticket that mitigates or resolves it
- **Contractual SLA** — a firm deadline with contractual or reputational consequences
- **Business blocker** — another team cannot operate until this is resolved

When an override is applied, document the reason.

## Sprint capacity and load

- Do not commit more than **80% of sprint capacity** to prioritized tickets
- The remaining 20% absorbs interruptions, support, and reviews
- If P0 and P1 exceed capacity, reduce scope or move tickets; do not inflate capacity

## When to review prioritization

- A production incident arrives -> review the sprint's P0 and P1 items
- A stakeholder wants to add something urgent -> apply scoring before committing
- Two sprints pass and a P3 ticket has not moved -> re-evaluate whether it is still P3 or has been overtaken by circumstances

## What is not a valid prioritization criterion

- "It was requested a long time ago" -> age is not impact
- "It is easy and we can do it quickly" -> low effort only helps if impact justifies it
- "The manager asked for it" -> requester seniority is not a criterion; the impact of the request is
- "Since we are already here" -> scope creep is not prioritization
