---
name: investigate
description: Conduct and record an investigation - compare alternatives in the project's context, with annotated references, explicit decision, and lifecycle tracking in research/RES-NNN records. Use when researching options, evaluating tools or approaches, comparing alternatives, or making any technology/design decision worth recording - in any domain, not only data.
---

# Investigate

An investigation answers a decision question with alternatives evaluated **in the context
where the decision lives**, and leaves a permanent record (`research/RES-NNN-<slug>.md`)
that tracks whether it led to anything. Generic "best practices" without context are
marketing; the standard here is *best for this project, given its constraints*.

## Process

### 1. Frame before searching

- State the decision question in one sentence, and the success criteria: what would make
  an alternative "win"?
- **Build the constraints list from the host context BEFORE searching**: read the
  project's conventions (CLAUDE.md, design docs, prior RES records, installed practice
  skills — e.g. in a data project, the de-core decisions: medallion layering, engine
  class, idempotency-first). Every recommendation will be judged against this list, not
  in the abstract.
- Check `research/INDEX.md` for prior related investigations — supersede, don't
  duplicate. The INDEX is the project's **decision registry**: every concluded RES is
  itself a binding constraint for this investigation until formally superseded.
- If there are not at least two real alternatives, say so: that is a verification, not an
  investigation (still fine to record, labeled as such).

### 2. Gather

- **Source hierarchy**: official documentation first, then vendor engineering blogs, then
  community content. Note the tier of every source.
- **Version and date every claim**: what is true of version N may be false in N+2; record
  the version a claim applies to and the access date.
- Important claims need **two independent sources** or a local verification (a test, a
  doc example reproduced).
- Record references AS YOU GO, annotated: which claim each link supports. A bare link
  list at the end is not acceptable.

### 3. Analyze in context

- One section per alternative: what it is, **how it would be implemented HERE**, pros and
  cons *relative to the constraints list* (a con that doesn't matter in this context is
  noise; a generic pro that violates a constraint is a con).
- Comparison matrix: criteria derived from the success criteria and constraints — not a
  feature checklist copied from vendors.
- Separate facts (sourced) from judgment (yours/mine) — both belong, labeled.

### 4. Decide and record

- Recommendation with explicit reasoning; rejected alternatives get their rejection reason
  written down (future-you will ask "did we consider X?" — the answer must be findable).
- State **reversibility**: what it would cost to change this decision later.
- Write the record from [templates/RES-template.md](templates/RES-template.md), register
  it in `research/INDEX.md` (create both from templates if missing; next sequential ID).
- **Close in conversation with the summary**: question, alternatives, choice, why, key
  links — the reader should get the outcome without opening the file.

## Practice precedence and conflicts

When "best practice" sources disagree, precedence is fixed:

1. **The project's own recorded decisions** — prior RES records, the project
   overlay/CLAUDE.md, client-mandated constraints
2. **The toolkit practices installed in the project** — e.g. de-core `practice-*` skills
   in a data project
3. **The technology's official best practices**
4. **Generic industry practice**

Lower tiers inform; higher tiers bind. For MINOR tensions (a convention makes the
implementation slightly less idiomatic), the constraint wins and the record notes the
cost. "The docs recommend X" never overrides a project decision by itself. Every Decision
section includes a **constraints check**: complies, deviates-with-approval, or escalated.

### Conflict escalation — BLOCKING gate

When the evidence says a binding project/architecture decision **directly opposes** the
technology's established practice — especially anything with production implications
(safety, correctness, data loss, operational risk) — the investigation must NOT
self-resolve in either direction. Silently complying buries a real risk; silently
deviating breaks the project's decision discipline. Instead, STOP and escalate to the
user with a structured decision package:

1. **The constraint**: what our decision says, and its source (RES-NNN / overlay / rule)
2. **The opposing practice**: what the evidence says, with the references and their tier
3. **Stakes, both directions**: what keeping the constraint costs or risks (quantified
   where possible, especially prod risk) vs what changing it costs (rework, consistency,
   downstream impact)
4. **Options** with pros/cons — including partial ones (exception scoped to this case vs
   superseding the general decision)
5. **A recommendation, labeled as judgment**

Raise it directly in conversation when the user is present; otherwise write it to the
project's pending-decisions file (e.g. `HUMAN-INTERVENTION.md`) and leave the record
`in-progress` with the escalation logged in its Escalations section. The investigation
does not conclude until the user resolves it, and the resolution is recorded verbatim:
who decided, when, what (constraint upheld / exception granted for this case / general
decision superseded by RES-NNN) — so the registry always shows a deliberate human
decision at every point where our architecture and the field's practice collided.

## Keeping records alive

- Every record carries **Last updated**; while in-progress, findings accumulate in a
  dated **Journal** section — long investigations grow in place, and conclusions must be
  traceable to journal evidence, not appear from nowhere.
- Concluded records state **validity conditions / reopen triggers**: the assumptions
  whose failure would invalidate the decision (version upgrade past X, volume beyond Y,
  pricing change, constraint superseded). Trigger-based beats date-based; add a review-by
  date only for fast-moving technology.
- Staleness rules (enforced by the `review` skill): in-progress with no journal entry in
  ~30 days → flag; concluded but unimplemented after ~90 days → revisit (implement, mark
  not-implemented, or reopen). Stale records lie about the project's state.

## Record lifecycle

```
in-progress → concluded → implemented      (+ link to PR/commit/deliverable)
                        → not-implemented  (+ reason: rejected, deprioritized)
                        → superseded       (+ by RES-NNN)
```

Maintenance rules:

- When work implements a concluded investigation, updating its status + implementation
  link is part of that work's definition of done (in data projects this hooks into
  `method-delivery`; elsewhere it is this skill's rule).
- A new investigation that revisits a closed one marks the old record `superseded` with a
  pointer — records are never edited to change history, they are superseded.
- `research/INDEX.md` is updated on every status change; it is the only place that needs
  to be scanned to know the state of all decisions.

## File conventions

- Directory: `research/` at the project root (override via the project's overlay/CLAUDE.md
  if the client requires another path).
- Files: `RES-NNN-<kebab-slug>.md`, NNN sequential per project.
- TL;DR at the TOP of every record: ~10 lines, readable standalone in six months.
