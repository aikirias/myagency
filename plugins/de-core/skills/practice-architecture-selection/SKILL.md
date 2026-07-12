---
name: practice-architecture-selection
description: Technology-agnostic decision frameworks for platform architecture - OLTP vs OLAP vs specialized storage classes, when medallion layering applies (and when it is cargo cult), warehouse vs lakehouse paradigm, history strategy selection (current-state vs SCD1 vs SCD2 vs events vs snapshots), and processing cadence. Use when choosing or reviewing the shape of a data platform, storage engines, layering, history handling, or load cadence.
---

# Practice: architecture selection

Five decisions that shape everything downstream. Each has a default, and deviating from
the default requires naming the consumer need that justifies it — never the technology's
marketing. All of these are paradigm decisions; the engine-specific mechanics live in the
stack packs.

## Decision 1 — Storage engine class: match the workload

Before any product choice, classify the workload the storage must serve:

| Class | Optimized for | Typical signals |
| --- | --- | --- |
| **OLTP** (row store) | Many small transactions, point reads/writes by key, per-row mutations, high concurrency | Operational apps, current-state entities, per-transaction ACID |
| **OLAP** (column store) | Scans and aggregations over many rows / few columns, bulk loads | Analytics, dashboards, batch/micro-batch ingestion |
| **Log / stream storage** | Append-only ordered events, replay by offset, fan-out to consumers | Integration backbone, event transport, source-of-truth event streams |
| **Key-value / document** | Point lookups by key at scale, flexible schema, low latency | Feature/profile serving, session state, ML online stores |
| **Specialized** (time-series, search) | One dominant access pattern (windowed metrics, full-text) | Observability, log exploration |

Rules:

- **The two classic (and expensive) mismatches** — both generate consulting engagements:
  1. *Analytics on the production OLTP database*: reports and extracts throttling the
     application is THE signal that an analytical platform is due; the fix is replication
     into an OLAP store, not query tuning on the app database.
  2. *OLAP used as OLTP*: point updates/deletes as a routine workflow, per-event inserts,
     read-your-write expectations — mutations on column stores are heavyweight or eventual
     BY DESIGN (see `method-diagnosis` step 3 and the stack packs for engine specifics).
- **One engine class per workload.** Serving the same data to two workload classes is a
  replication/pipeline problem, not a reason to force one engine to do both jobs badly.
- **Every additional specialized store must pay rent**: each one adds an ops surface, a
  copy of the data, and a consistency boundary. Adopt one only when its access pattern is
  truly dominant and measured, not anticipated.

## Decision 2 — Platform paradigm: warehouse, lakehouse, or hybrid

**Warehouse-centric** (managed analytical database as the platform):

Choose when: data is overwhelmingly structured; consumers are SQL/BI; one compute engine
is enough; the team is small and values operational simplicity; volumes are within what
the engine handles economically.

**Lakehouse** (object storage + open ACID table format + independent compute — the
"delta lake" pattern, regardless of vendor):

Choose when at least two of these are true:
- Multiple compute engines need the SAME data (SQL + ML/data science + streaming)
- A significant share is semi/unstructured or schema-volatile
- Volume makes decoupled cheap storage the dominant cost factor
- Long raw-history retention with replay is a requirement
- Avoiding single-vendor lock on the storage layer matters to the client

Its price: you inherit database internals as YOUR ops problem — small-file compaction,
metadata/manifest health, table maintenance jobs. A lakehouse without an owner for that
maintenance becomes a swamp with ACID guarantees.

**Hybrid** (lake for raw + heavy processing, warehouse for curated/serving): the most
common consulting answer for mid-size clients — cheap replayable history plus a serving
engine analysts already know.

Wrong-fit signals to call out in audits: a lakehouse serving only small structured BI
(pure overhead); a warehouse choking on raw semi-structured blobs and reprocessing needs;
"we built a data lake" with no table format, no schema, no owner (a file dump).

## Decision 3 — Layering: when medallion applies

**Default: 3 layers (raw → curated → serving) for any analytical platform with more than
one source or more than one consumer class.** Each layer must earn its existence:

- **Raw** earns it via replay, lineage, and audit: reprocess without re-extracting,
  prove what arrived. Immutable/append-only.
- **Curated** earns it via conformance: one place where typing, dedup, and business
  definitions happen — the single source of truth for entities and metrics.
- **Serving** earns it via access patterns: shapes optimized for how consumers read.

**A 2-layer design (raw + serving) is legitimate** when there is a single source, simple
conformance, and one consumer class — document it as a decision, keep raw immutable, and
note the trigger for introducing the middle layer (second source, first metric-definition
conflict).

Anti-patterns (audit findings, dimension: architecture):
- **Cargo-cult medallion**: a "silver" layer that is a 1:1 copy of bronze with renamed
  columns — a layer with no conformance job is cost without value.
- Consumers querying raw directly (the layering contract is broken; expect metric drift).
- Reporting/audit side-tables becoming the de facto curated layer.
- Layer-skipping "just this once" without a documented justification.

Medallion is a *responsibility* pattern, not a batch pattern — in streaming topologies the
same three responsibilities apply (raw stream → conformed stream/table → serving views).

**Layer-naming house rule (set 2026-07-12).** Medallion terms (bronze/silver/gold ≙
raw/curated/serving) are the CONCEPTUAL vocabulary — use them in design notes, audits,
and client conversations. Physical dataset/schema/folder naming follows the repo's
transformation-tool ecosystem convention (in dbt projects: `staging` ≙ raw→curated
conformance edge, `intermediate` ≙ curated, `marts` ≙ serving). This equivalence is
declared HERE once; the client overlay states which naming the repo uses. Never mix both
vocabularies within one artifact.

## Decision 4 — History strategy

Work through these questions IN ORDER; stop at the first match. The strategy table lives
in `practice-data-modeling`; this is the selection logic.

1. **Are the events themselves the business truth** (orders, payments, clicks)?
   → **Append-only event store**; any "current state" is a derived view. Never overwrite
   facts.
2. **Does any consumer need to reconstruct what was true/believed at a past date?**
   If NO → **current-state or SCD1** (overwrite). This is the default for dimensions and
   reference data. Most platforms need far less history than they build.
3. If point-in-time IS needed — **demand a concrete example query before proceeding**
   ("show me the report that needs the customer's segment as of last March"). Then:
   - Only specific **attributes** need change tracking → **SCD2 on those attributes
     only** (hybrid SCD1/SCD2 per column). Full-table SCD2 by default is years of
     avoidable joins on validity windows.
   - The **whole dataset's state** at intervals matters more than attribute-level change
     → **snapshots** (simple, replayable, linear storage cost — often the honest answer
     when "as of month-end" granularity suffices).
4. **Regulatory/audit "prove what we reported"** → immutable **snapshots of the served
   output** at reporting time, separate from the modeling-layer history choice.

Cost truths to state in every design: SCD2 costs every future query (validity-window
joins), every backfill (rewriting history windows), and every correction (what does
"fixing" a historical row mean?). Snapshots cost storage but almost no complexity. The
rule: **no SCD2 without a named, real point-in-time question** — "we might need it" is
not a consumer need.

**SCD2 implementation house rule (set 2026-07-12).** Once SCD2 is justified: where dbt
is in the stack, implement it as **dbt snapshots** (strategy caveats live in the dbt
stack pack); where it is not, use the platform-native change-tracking mechanism of the
stack pack in play. Deviating from this default is a documented decision in the design
note, not a per-pipeline preference.

## Decision 5 — Processing cadence

Batch is the default. Escalate only along real decision latency:

- **Batch (daily/hourly)**: the consumer is a human reading reports → almost always enough.
- **Micro-batch (minutes)**: operational dashboards, freshness SLAs measured in minutes.
- **Streaming (seconds)**: the consumer is a MACHINE acting automatically (alerting,
  personalization, fraud) — humans do not read at streaming speed.

The discovery question that settles it (`method-discovery`): *what decision would change
with 1-minute data versus 1-hour data?* If the answer is "none", the "real-time"
requirement is an aesthetic, and building it costs eventual-consistency traps, dedup
complexity, and ops burden (see the requirement-fit checks in `method-diagnosis` step 3).

[REVIEW: this encodes standard doctrine + your stated approach (challenge real-time,
simplest-that-works). Adjust any default that clashes with how you actually decide — e.g.
if you default to hybrid platforms, or if you use snapshots more/less aggressively than
step 3 suggests.]
