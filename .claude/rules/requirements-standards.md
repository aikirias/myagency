# Requirements Standards

## Core principle

A requirement that cannot be verified is not a requirement — it is an intention. Every requirement should be answerable with "yes" or "no" when asked whether it was fulfilled.

## When a requirement is ready for technical design

- [ ] The business objective is articulated, not just the requested artifact
- [ ] All business terms have an agreed and written definition
- [ ] Dates are specified: event, processing, and reporting
- [ ] Filters and exclusions are explicit (cancellations, returns, nulls)
- [ ] Output granularity is defined
- [ ] Update frequency is defined
- [ ] The consumer and consumption channel are identified
- [ ] Acceptance criteria are verifiable by the stakeholder

If any of these are missing, the requirement is not ready for technical design.

## Definitions that must always be resolved

### Metrics

Never assume what a metric includes. Always ask:

| Metric | Required questions |
|---|---|
| Revenue / Sales | Does it include cancellations? Returns? Taxes? Discounts? |
| Active customers | What counts as active? Purchased in the last N days? Has an account? |
| Units sold | Units of what? Order lines? Distinct products? |
| Conversion | Conversion from what to what? What is the population? |

### Dates

Always specify which of these is being used:

- **Event date**: when the event happened (order created, payment completed)
- **Processing date**: when it arrived in the system
- **Reporting date**: which business period it belongs to

Never leave "sale date" undefined as to which of the three it means.

### Granularity

Explicitly define the level of detail:

- One row per order? Per customer? Per day? Per product?
- Can multiple levels be aggregated or is it a fixed level?

## Required functional specification format

Every functional specification handed to the technical team must include:

1. **Business objective** — what decision it enables
2. **Agreed definitions** — a table of terms and definitions
3. **Use cases** — in the format "[Actor] can [do X] to [achieve Y]"
4. **Business rules** — numbered, one rule per item
5. **Acceptance criteria** — verifiable by the stakeholder, not just the engineer
6. **Out of scope** — explicit if there is scope creep risk
7. **Open questions** — with owner and due date

## What is not a valid requirement

- "Improve pipeline performance" -> by how much? Compared to which baseline?
- "See sales by region" -> which metric? Which date? Which regions?
- "Customer dashboard" -> which metrics? Which granularity? How often?
- "The same as the Excel report but in the dashboard" -> the Excel must be analyzed and its rules documented explicitly

## The "three whys" rule

For any request, ask "why?" up to three times to reach the real objective:

```
Stakeholder: "I need to see sales by city."
Why? "To know which cities are underperforming."
Why? "To decide where to allocate more sales effort."
Why? "Because the commercial manager defines the Q2 budget based on that."

Real objective: the commercial manager needs a ranking of cities by revenue
to decide sales force allocation for Q2.
```

That real objective changes how the solution should be designed.
