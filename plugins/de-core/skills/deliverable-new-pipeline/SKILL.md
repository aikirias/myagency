---
name: deliverable-new-pipeline
description: Output contract for a new pipeline / new data product engagement - approval-gated design note with embedded Mermaid diagrams, implementation, deployable DQ suite, runbook, and validation evidence. Use when scoping, building, or delivering a new pipeline, ingestion, or data product for a client.
---

# Deliverable contract: new pipeline

Two phases with a hard gate between them. The gate is also scope protection: what the
client approved in the design note is what gets built; anything else is a new conversation.

## Phase 1 — Design note (BLOCKING gate)

No implementation starts until the client has reviewed and approved the design note.
Use [templates/design-note-template.md](templates/design-note-template.md). It must contain:

- Business objective — the decision or process this enables, not just the artifact
- Source-to-target: systems, tables/endpoints, ingestion pattern
- Grain in one sentence; layer placement; history strategy; load pattern (idempotency
  mechanism named explicitly)
- **Architecture diagrams, embedded Mermaid**: minimum a context view (actors, sources,
  platform) and a flow view (pipeline steps and storage layers). No external tooling.
- Trade-offs table with rejected alternatives
- **Verifiable success criteria** ("row counts match source within 0.1%", not "works")
- **Out of scope** — explicit, this is the scope-creep fence
- Open questions with owners

Design decisions follow `practice-data-modeling` and `practice-incremental-processing`;
the Data Architect agent produces this phase.

## Phase 2 — Delivery package

One self-contained folder (code itself is delivered through the client's channel — repo/PR
per the project overlay; the package references it):

```
pipeline-<name>/
├── README.md            # delivery summary: what was built, where it lives, how it was validated
├── design-note.md       # the approved note, updated to AS-BUILT
├── runbook.md           # operations manual (template below)
├── dq/                  # implemented check suite + execution spec
└── validation/          # captured evidence
```

### Mandatory components

1. **Design note, as-built.** If implementation changed any structure, flow, or decision,
   the design note and its diagrams are updated before delivery — the documentation
   reflects what exists, not what was planned.
2. **Runbook** — use [templates/runbook-template.md](templates/runbook-template.md):
   failure playbook, how to re-run an interval safely, rollback, escalation. Executable by
   someone who did not build the pipeline.
3. **Deployed DQ suite.** The four minimums (freshness, volume, duplicates, nulls) per
   `practice-data-quality-minimums`, implemented and running automatically — not
   recommended, implemented. A pipeline without its checks is not a finished pipeline.
4. **Validation evidence**, captured:
   - End-to-end run at the safe boundary (staging/testbed if production runs need approval)
   - Row counts / key totals vs source for the validated interval
   - **Idempotency proof**: the same interval re-run, with evidence that counts and key
     metrics did not change (`practice-idempotency-and-reruns`)
5. **Ownership block**: named owner, alert channel, freshness SLA, escalation path
   (`practice-observability-and-ownership`).

## Contract rules

- Delivery channel and language come from the client overlay; the package is
  self-contained either way.
- Anything not validated (e.g. production deploy pending client approval) is listed
  explicitly in README under "Remaining steps", with the exact commands or actions needed.
- Backfill of history, if included, follows `practice-backfill-safety` and its plan ships
  in the package.

## Completion checklist

- [ ] Design note was approved by the client BEFORE implementation started
- [ ] Design note updated to as-built, diagrams included and current
- [ ] Runbook present and executable by a stranger
- [ ] DQ suite implemented, scheduled, and its execution spec documented
- [ ] Validation evidence captured, including the idempotency re-run
- [ ] Ownership block complete
- [ ] Out-of-scope items and remaining steps explicitly listed
