---
name: method-improvement-plan
description: Improvement flow for data processes - from evidence-backed problem through solution paths and user choice to an approved, checkpointed plan with drift detection (minor drift auto-corrects and is logged; major drift stops and escalates). Use when analyzing a data process for improvement, proposing solution paths, building an implementation plan, or tracking execution against an approved plan.
---

# Method: improvement plan

The bridge between diagnosis and delivery: problem → solution paths → THE USER chooses →
approved plan → checkpointed execution under drift control. Nothing here replaces the
deliverable contracts — a completed plan is what gets packaged by them.

## 1. Problem statement, with baseline

Start from evidence (`method-diagnosis` output or an audit finding), never from a
solution. Capture the problem's **baseline metrics** now (latency, cost, error rate,
freshness — whatever the problem is measured in): the baseline is both the "before"
evidence for the deliverable and the drift reference during execution.

## 2. Solution paths

- Minimum two real paths, pros/cons **in context** (project constraints and de-core
  practices bind — same precedence discipline as the `research` plugin's investigate
  skill; for choices deep enough to deserve a record, run the investigation there and
  link the RES).
- Present to the user: the problem, the paths, trade-offs, and a recommendation labeled
  as judgment. **The user chooses.** Never auto-pick when paths differ materially in
  risk, cost, or architecture — that choice is the client's/user's to own.

## 3. The plan — approval gate

Write the plan from [templates/PLAN-template.md](templates/PLAN-template.md) as
`plans/PLAN-NNN-<slug>.md` in the project. **No execution before the user approves it**
(same blocking gate as the pipeline design note). A plan must contain:

- Objective and **measurable success criteria** tied to the baseline
- The chosen path, why, and the approval record
- Phases broken into **checkpoints**, each with: expected state, a CONCRETE verification
  (a query, a metric, a test — not "check it works"), acceptance criteria, and whether it
  is a **rollback point** (can we stop and undo here?)
- Which checkpoints touch production boundaries — those inherit the
  `method-safe-operations` approval rules on top of plan approval

Lifecycle: `draft → approved → in-execution → completed | abandoned | superseded`.

## 4. Execution — the plan is a living document

At each checkpoint: run the verification, record actual vs expected IN the plan file
(status, evidence, timestamp). The plan file is the single source of truth for progress —
if the plan says checkpoint 3 passed, the evidence is right there.

## 5. Drift protocol

Drift = reality diverging from the approved plan. Dimensions: **result** (metrics off
expected), **scope** (work appearing/disappearing), **approach** (implementation deviating
from the chosen path), **timeline/cost**, and **safety** (anything touching a
safe-operations boundary).

**Minor drift — auto-correct and log.** ALL of these must hold:

- The checkpoint's acceptance criteria are still met, or met after a local adjustment
- No change to scope, architecture, risk profile, or the chosen path
- No safety dimension involved
- Not part of a pattern (3 consecutive minor drifts = the plan is wrong → treat as major)

Then: apply the local correction, log it in the plan's Drift log (what drifted, why, the
correction), continue. Auto-correction without a log entry is prohibited — an unlogged
fix is invisible drift.

**Major drift — stop and escalate.** Anything that fails the tests above, and always:
baseline assumptions invalidated, success criteria no longer reachable, safety boundary
touched, or accumulated minor drift. Then:

1. STOP at the current checkpoint (this is why rollback points are marked)
2. Escalate to the user with a decision package: what drifted with evidence, impact on
   the plan, options — **re-plan from checkpoint N** / **accept the new course and amend
   the plan** / **roll back and switch path** (back to step 2's alternatives) — and a
   labeled recommendation
3. Record the resolution verbatim in the plan (who, when, what); if scope changed, the
   amended plan goes through approval again

Silent re-planning is prohibited in both directions: the plan only ever changes through
logged auto-corrections (minor) or recorded user decisions (major).

## Registry

Register plans in `plans/INDEX.md` (same one-line-per-item format as the research INDEX:
id, title, status, last updated, outcome). Closing the loop — marking `completed` with
final metrics vs baseline, or `abandoned` with why — is part of the definition of done of
the work (`method-delivery`).
