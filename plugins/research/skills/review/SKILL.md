---
name: review
description: Maintenance pass over the research/ directory - reconcile INDEX vs records, flag stale investigations, check reopen triggers against current project state, prompt status closures. Use periodically, when entering a project with existing research records, or when asked to review/update the research index.
---

# Research review

The pass that keeps the record system honest. An index that drifts from reality is worse
than no index — it answers wrong with confidence. Run this when entering a project with a
`research/` directory, and periodically on long engagements.

## Checks

1. **Reconcile INDEX vs records**
   - Every `RES-*.md` file appears in `INDEX.md` and vice versa
   - Status, decision, and dates in the INDEX match each record's header
   - No duplicate or skipped IDs

2. **Staleness** (rules from the `investigate` skill)
   - `in-progress` with no journal entry in ~30 days → flag: still being pursued, or
     should it be parked as `not-implemented (deprioritized)`?
   - `concluded` but unimplemented after ~90 days → flag: implement, mark
     `not-implemented`, or reopen?

3. **Loop closure**
   - `implemented` records: implementation link present and valid; "Implementation
     outcome" section filled (including divergences from the research)
   - Recently merged/delivered work that implements a `concluded` RES but never updated
     it → close the loop now

4. **Reopen triggers**
   - For each concluded/implemented record, check its validity conditions against the
     CURRENT project state (versions upgraded? volume changed? a constraint superseded by
     a newer RES?). A fired trigger → flag the record for reopening or superseding.

5. **Consistency of the decision registry**
   - Records that contradict each other without a supersede link → flag; the registry
     must have exactly one live decision per question.

6. **Unresolved escalations**
   - Records with an Escalations block lacking a resolution → surface FIRST in the
     report: these are decisions explicitly waiting on the user, and every day they sit
     unresolved the investigation (and whatever depends on it) is blocked. Cross-check
     the project's pending-decisions file (e.g. `HUMAN-INTERVENTION.md`) still lists them.

## Output

- Updated `INDEX.md` (the mechanical fixes: reconciliation, dates, links)
- A short report in conversation: records touched, and the flagged items **grouped by the
  human decision they need** (park / implement / reopen / supersede) — status changes
  that change meaning (parking, reopening) are proposed, not applied silently.
