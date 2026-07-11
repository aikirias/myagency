---
name: method-discovery
description: Engagement discovery method - understand the need, affected audience, cadence, criticality, consumption path, and definition of done BEFORE touching any system. Use at the start of any consulting engagement, incident, or new request, before diagnosis or design work begins.
---

# Method: discovery

Never start with the tool. Start with the need. Diagnosis and design decisions change
completely depending on who is affected, how often the thing must run, and what "fixed"
means — so these are established first, in the stakeholder's language.

## Questions to answer before any technical work

1. **What exactly is the problem or need?** Both the symptom in the stakeholder's words and
   the observable fact ("the report shows zeros since Tuesday" vs "revenue is wrong").
2. **Who consumes it?** Audience level matters: a C-level report and an analyst's working
   query have different criticality, different tolerance for downtime, and different
   communication expectations.
3. **What is the required cadence?** How often must it run or refresh, and what is the
   real SLA (committed or implied)? "Real time" claims must be challenged: ask what decision
   would change with 1-minute data vs 1-hour data.
4. **Since when, and what changed?** Last known good state; deploys, schema changes, or
   upstream changes around that time.
5. **What is the business impact of it staying broken?** Decisions blocked, money, SLAs,
   trust. This sets priority and how much validation rigor the fix needs.
6. **How is it consumed?** Which tool (BI platform, spreadsheet, API, export), by how many
   people, at what times. The consumption path is both a diagnosis input and a source of
   improvement opportunities beyond the immediate ask.
7. **What does "done" look like?** Acceptance criteria the stakeholder can verify
   ("report matches source total within X" — not "it works").

## Rules

- If a metric or report definition is ambiguous (what does "sales" include?), resolve the
  definition BEFORE diagnosing. A fix against an undefined metric cannot be validated.
- Ask "why" up to three times to reach the real objective behind the request; the real
  objective often changes the right solution.
- State every assumption you could not confirm, explicitly, in the discovery note.

## Output

A short discovery note (goes into the engagement folder and later feeds the deliverable):

- Problem statement (symptom + observable fact)
- Audience and criticality
- Cadence / SLA expectation
- Timeline (since when, what changed)
- Business impact
- Consumption path (tools, users, schedule)
- Acceptance criteria
- Open questions with owners
