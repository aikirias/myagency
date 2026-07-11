---
name: practice-governance-and-catalog
description: Governance and data catalog guidelines - the minimum metadata contract, when a catalog product pays off, metric definition ownership, access model per layer, schema change management. Use when assessing or designing governance, cataloging, discoverability, metric definitions, or access control on a data platform.
---

# Practice: governance and data catalog

Governance answers four questions about every dataset: **who owns it, what does it mean,
who can see it, and what changed.** Scale the *mechanism* to the team; never skip the
questions. Tooling is optional — the metadata is not.

## The minimum metadata contract

Every production dataset carries, somewhere findable:

- **Owner** (team/person answering for incidents and changes)
- **Description and grain** (one sentence each)
- **Freshness SLA** and layer placement
- **PII classification** (`practice-pii-handling`) — consumers inherit obligations
- **Lineage at table level**: direct upstreams and known downstreams
- **Link to definitions** for the metrics it carries

At small scale this lives perfectly well in versioned YAML or a docs page next to the
code. A catalog product is a *delivery mechanism* for this contract, not a substitute
for it.

## When a catalog product pays off

Signals that justify the investment: more than ~50-100 datasets, more than two teams
producing data, or recurring "where is X / what does this field mean / can I trust this
table" questions eating real time. Before those signals, a well-kept docs page beats a
catalog; after them, tribal knowledge stops scaling.

The failure mode to avoid (and flag in audits): **a stale catalog is worse than none** —
it answers wrong with confidence. A catalog only works if it is populated automatically
where possible and updating it is part of the delivery definition-of-done, not a
best-effort afterthought.

## Metric definitions — one glossary, one owner each

- Every business metric has exactly ONE written definition (inclusions, exclusions, date
  semantics — see the definition discipline in `method-discovery`) and a named owner.
- The curated layer IS the implementation of the glossary. If metric logic lives inside
  dashboards or per-team spreadsheets, governance has already failed — that is the
  "multiple sources of truth" audit dimension (`deliverable-platform-audit` dimension 2).
- Changing a definition is a versioned, announced event: consumers must know that
  "revenue" means something different from March onward.

## Access model — least privilege by layer

- **Raw**: restricted — it holds ungoverned data and unmasked PII; pipeline identities
  and few humans.
- **Curated**: broad read for analysts — this is what the layer is FOR; PII columns gated
  separately (views/column permissions).
- **Serving**: open to its consumer audience by design.
- Access via roles/groups, never individual grants; individual grants are the #1
  ungoverned-access audit finding. Review access on offboarding and per engagement close
  (consultants included — your own access is part of the client's attack surface).

## Change management

Schema and semantic changes are contract changes: versioned, backward-compatible where
possible, deprecation window + downstream notification where not. A breaking change
shipped without notice is a governance incident even when the pipeline "works".

## Audit shortcuts

Governance findings map to `deliverable-platform-audit` dimensions 2 and 6: ownerless
datasets, metrics defined in N places with drift between them, abandoned catalogs, admin
rights for everyone, PII discoverable via search in an open BI tool.
