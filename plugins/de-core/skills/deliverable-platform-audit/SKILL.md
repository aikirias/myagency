---
name: deliverable-platform-audit
description: Output contract for a data platform audit / health-check engagement - six-dimension review with evidence-backed findings scored by severity and effort, dual-audience report (executive summary + technical body), quick wins and roadmap. Use when auditing, assessing, or health-checking a client's data platform, warehouse, or pipeline estate.
---

# Deliverable contract: platform audit

An audit's value is credibility: every finding is backed by reproducible evidence, every
claim is scoped to what was actually reviewed, and the client leaves knowing exactly what
to do first. The audit itself runs strictly read-only (`method-safe-operations`).

## The six dimensions

A full audit covers all six; a scoped engagement states explicitly which were excluded.

1. **Architecture and modeling** — layers and their violations (serving reading raw),
   grain clarity, history strategies, engine-vs-usage fit, partitioning, structural debt
   (`practice-data-modeling`).
2. **Consistency and source of truth** — business logic duplicated across models, the same
   metric defined differently in different places, more than one "source of truth" for the
   same entity, drift between them measured.
3. **Data quality and observability** — check coverage vs the four minimums, ownerless
   datasets, pipelines with no failure alert, silent-corruption risk, runbook coverage
   (`practice-data-quality-minimums`, `practice-observability-and-ownership`).
4. **Cost** — cost map, top expensive queries/pipelines, zombie assets, retention gaps,
   over-provisioning (`practice-cost-optimization`).
5. **Efficiency and effectiveness** — redundant processing (multiple pipelines computing
   the same thing), refresh cadences nobody needs, built-but-unused datasets (usage audit),
   and whether what exists actually serves the decisions it was built for.
6. **Security, PII, and access** — sensitive data classification, uncontrolled PII copies,
   over-broad privileges, hardcoded credentials, data leaving its boundary
   (`practice-pii-handling`).

Dimensions 4 and 5 overlap by design (a zombie pipeline is both); record the finding once,
under the dimension with the stronger evidence, and cross-reference.

## Finding format

Every finding uses [templates/finding-template.md](templates/finding-template.md):

- **ID** (`AUD-NN`), dimension, one-sentence statement
- **Severity**: critical / high / medium / low — business consequence, not technical taste
- **Effort**: S / M / L to remediate
- **Evidence**: the query/observation that proves it, reproducible by the client
- **Risk if ignored**: what happens, to whom, when
- **Recommendation**: specific enough to become a ticket

Severity × effort yields the priority naturally: **quick wins = high severity + S/M effort.**
No finding without evidence; a suspicion without proof goes to "areas for deeper review",
clearly separated.

## Package shape

```
audit-<client>-<YYYY-MM>/
├── 00-executive-summary.md   # 1 page, business language (template below)
├── 01-findings.md            # technical body: findings grouped by dimension
├── 02-roadmap.md             # quick wins first, then phased by severity/effort
└── evidence/                 # captured queries + outputs, named by finding ID
```

### Mandatory content

1. **Executive summary** — [templates/executive-summary-template.md](templates/executive-summary-template.md):
   one page, no jargon, risks stated in business terms (money, decisions, exposure), the
   top 3-5 actions. Written for the person who paid for the audit, readable in 5 minutes.
2. **Coverage statement** — what was reviewed (systems, schemas, period, access level) and
   what was NOT and why. An audit that hides its blind spots is a liability.
3. **Findings by dimension**, in the finding format, evidence in `evidence/`.
4. **Quick wins** — the high-impact/low-effort subset, listed separately; these justify the
   audit within weeks.
5. **Roadmap** — remaining findings phased (now / next quarter / later), each phase with
   expected outcome.

## Completion checklist

- [ ] All six dimensions covered or explicitly excluded in the coverage statement
- [ ] Every finding has evidence reproducible by the client, filed under its ID
- [ ] Every finding has severity AND effort
- [ ] Executive summary fits one page and contains zero unexplained technical terms
- [ ] Quick wins identified and actionable as tickets
- [ ] Audit ran read-only; any exception was client-approved and is documented
