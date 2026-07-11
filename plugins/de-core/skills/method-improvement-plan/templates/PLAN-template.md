# PLAN-NNN: <improvement title>

**Status**: draft | approved | in-execution | completed | abandoned | superseded by PLAN-NNN
**Created**: <YYYY-MM-DD> — **Last updated**: <YYYY-MM-DD>
**Owner**: <name>
**Approval**: approved by <user>, <date>, via <channel> | pending
**Related**: <RES-NNN research record, audit finding AUD-NN, or diagnosis notes>

## Problem

<Evidence-backed statement: what is wrong/suboptimal, since when, impact.>

**Baseline** (captured <date> — the drift reference and the "before" evidence):

| Metric | Value |
| --- | --- |
| <e.g. p95 dashboard latency> | <value> |

## Solution paths considered

| Path | Pros (in context) | Cons (in context) | Chosen |
| --- | --- | --- | --- |
| A: <name> | | | yes — <why> |
| B: <name> | | | no — <why> |

<Link the RES record instead if the choice went through a full investigation.>

## Success criteria

- [ ] <measurable, vs baseline: e.g. p95 latency under X; cost per run below Y>

## Checkpoints

| # | Phase / checkpoint | Expected state | Verification (concrete) | Rollback point | Status | Actual / evidence |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | <e.g. staging table created> | <expected> | <query/test to run> | yes/no | pending / passed / drifted | <result + timestamp> |
| 2 | | | | | | |

Checkpoints touching production boundaries: <list # — these also require the
method-safe-operations approvals before execution>.

## Drift log

<Every deviation, minor or major. An unlogged correction is invisible drift.>

| Date | CP | Dimension | Class | What drifted | Resolution |
| --- | --- | --- | --- | --- | --- |
| <date> | <#> | result / scope / approach / timeline / safety | minor / major | <description> | auto-corrected: <fix> / escalated (see Escalations) |

## Escalations

<One block per major drift. Execution does not continue past the checkpoint while unresolved.>

- **Drift**: <what happened, evidence>
- **Impact on plan**: <criteria/assumptions affected>
- **Options presented**: re-plan from CP <n> / amend and continue / roll back and switch path
- **Resolution**: <choice> — decided by <user>, <date> <(re-approval date if scope changed)>

## Completion

**Outcome**: <completed / abandoned + why>

| Metric | Baseline | Final | Target met |
| --- | --- | --- | --- |
| <metric> | <before> | <after> | yes/no |

<Divergences between the executed work and the approved plan, all traceable to the Drift
log. Handoff: which deliverable contract packaged this work.>
