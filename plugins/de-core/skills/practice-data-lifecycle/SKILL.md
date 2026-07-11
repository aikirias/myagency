---
name: practice-data-lifecycle
description: Data retention, archiving, and tiering guidelines - per-layer retention defaults, raw/bronze archiving with replay guarantees, restore-tested archives, tiering triggers, purge and erasure obligations. Use when defining retention policies, archiving raw data, reviewing storage growth or cost, or designing purge/erasure flows.
---

# Practice: data lifecycle

Every dataset has an explicit lifecycle: **hot → warm/cold → archived → purged**.
"Keep everything forever on the primary tier" is not a policy — it is a decision made by
nobody, discovered later as a cost or compliance finding.

## Retention defaults per layer

| Layer | Default posture | Rationale |
| --- | --- | --- |
| **Raw / bronze** | Keep longest, on the CHEAPEST tier | It is the replay + audit foundation; everything downstream is rebuildable from it |
| **Curated** | Retention driven by consumer queries; rebuildable from raw | If rebuild cost is high (weeks of compute), treat its retention as its own decision |
| **Serving** | Ephemeral — what dashboards actually query | Rebuildable from curated by definition |
| **Reporting / regulatory snapshots** | Set by regulation; immutable; legal-hold aware | These are evidence, not data — never mixed with the working layers |

## Archiving raw/bronze — the rules

Raw is where archiving matters most: it is the largest volume and the least queried, but
losing it means losing replay.

1. **Archive ≠ delete.** Archiving moves raw data to a cold tier (compressed, object
   storage class with retrieval latency); the replay guarantee is retained, just slower.
   State the hot window explicitly (how far back reprocessing is likely — typically the
   last 1-3 months of intervals) and tier everything older.
2. **An archive that was never restored is a hope, not a capability.** Test restores
   periodically (at least one interval per cycle) and time them — the restore SLA is part
   of the archive design.
3. **Schema travels with the data.** Archive the schema version and format notes alongside
   each archived window; schema drift is what makes old archives unreadable years later.
4. **Partition archives by time** so a single interval can be restored without thawing
   the whole history.
5. **Immutable and append-only** — same as raw itself. If the platform supports object
   locks / WORM for regulated data, use them there, not everywhere.

## Tiering triggers

Tie tiering to observed usage, not guesses (`practice-cost-optimization`): data not
queried in N days is a cold-tier candidate; measure with the platform's access/usage
logs during audits. The usual audit finding: 80%+ of primary-tier storage is raw history
nobody has touched in a year.

## Purge — deletion is part of the lifecycle

- **Erasure obligations reach archives too.** A PII erasure request that cleans the hot
  tables but not the archives is not compliance (`practice-pii-handling`). For immutable
  archives, plan crypto-shredding (encrypt per-subject or per-window, delete keys) or
  scheduled re-write cycles.
- Contractual/regulatory retention LIMITS (must-delete-after) are as binding as
  must-keep-until; both go in the dataset's lifecycle record.

## Per-dataset lifecycle record

No dataset is production-ready without: retention per tier, tiering schedule, archive
location + format + schema version, restore procedure (tested when), purge obligations,
and an owner. Ownerless lifecycle = unbounded growth.
