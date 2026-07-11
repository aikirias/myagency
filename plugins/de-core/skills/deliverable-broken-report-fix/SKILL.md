---
name: deliverable-broken-report-fix
description: Output contract for a broken report/query/dataset fix engagement. Defines the client-facing delivery package - numbered runnable SQL, step-by-step README, before/after evidence, rollback plan, prevention. Use when packaging, assembling, or delivering the result of fixing a broken report, query, or dataset for a client.
---

# Deliverable contract: broken report fix

This skill defines **what leaves the building** when a broken-report engagement is done.
It does not define how to diagnose or fix — that is covered by practice skills. Apply this
contract once the fix is understood and validated, or use it upfront to know what evidence
must be captured along the way (before/after outputs cannot be reconstructed later).

## Package shape

One self-contained folder per fix:

```
fix-<YYYY-MM-DD>-<short-slug>/
├── README.md            # the step-by-step document (template below)
├── sql/
│   ├── 01_<action>.sql  # numbered in EXECUTION ORDER, one action per file
│   ├── 02_<action>.sql
│   └── NN_validation.sql
├── scripts/             # only if shell/python steps are needed
└── references.md        # links: docs, tickets, dashboards, source-system docs
```

Naming and ordering rules:

- SQL files are numbered by execution order; the number is the order, no exceptions.
- One logical action per file (diagnose, fix, validate) — never a mixed dump.
- Every SQL file starts with a header comment: purpose, target table(s), expected effect
  (e.g. "updates ~1,240 rows in <schema.table> for 2026-06").
- Diagnosis queries that are evidence-only (read-only) are included too — the client must be
  able to reproduce the diagnosis, not just the fix.

## Mandatory README sections

Every package README contains ALL of these, in this order. Use
[templates/README-template.md](templates/README-template.md) as the skeleton.

1. **Summary** — one paragraph: what was broken, what was done, current status.
2. **Symptom** — what the client saw, since when, business impact.
3. **Diagnosis and root cause** — the causal chain with the evidence (queries + captured
   results) that proves it. No "probably": if it is an hypothesis, label it as one.
4. **Fix steps** — numbered, each referencing the exact `sql/NN_*.sql` or `scripts/*` file,
   with the exact command to run it and what to expect.
5. **Validation evidence (before/after)** — real captured outputs (row counts, key totals,
   sample rows) from before and after the fix. Hypothetical or reconstructed evidence is not
   acceptable; capture "before" evidence during diagnosis.
6. **Data quality tests** — the checks run to prove the dataset is healthy after the fix
   (duplicates on the business key, nulls on required fields, reconciliation against source
   where applicable). Scale to what the fix touched.
7. **Rollback plan** — how to undo the fix, written and verified feasible BEFORE the fix is
   executed. If rollback is impossible, say so explicitly and state the mitigation.
8. **Prevention** — the monitoring/quality checks that would have caught this earlier.
   See "Prevention mode" below for whether these are implemented or recommended.
9. **References** — documentation, tickets, and source materials used.

## Contract rules

- **Self-contained**: the package must be executable and understandable by someone who was not
  in the engagement, with no access to this conversation. It must survive being copied into a
  repo, exported to a wiki, or emailed as a zip.
- **Delivery channel is per-client**: the client project's `CLAUDE.md`/overlay defines where the
  package goes (client repo folder, PR, external doc). Never assume a channel; if the overlay
  does not define one, ask.
- **Prevention mode is per-client**: the overlay defines whether prevention checks are
  *implemented* (code included in the package, ready to deploy) or *recommended*
  (specified precisely enough to be implemented later as separate work). Default when
  unspecified: recommend only, and note it as an open item in the README.
- **Language**: English by default; the client overlay may override the deliverable language.
- **Safety**: any destructive statement (UPDATE/DELETE/DDL) in `sql/` must have an explicit
  scope (WHERE / partition bound), be paired with the rollback plan, and be idempotent or
  explicitly marked "run once".

## Completion checklist

The package is done only when:

- [ ] Every mandatory README section is present and non-empty
- [ ] Every `sql/` file runs in numbered order against the target environment (or the ones that
      could not be run are explicitly marked with why)
- [ ] Before/after evidence is real captured output, with capture timestamps
- [ ] Rollback was defined before the fix ran
- [ ] Prevention mode (implement vs recommend) matches the client agreement
- [ ] A reader with no context could follow README.md top to bottom and reproduce the result
