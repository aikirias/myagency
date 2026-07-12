# de-flink

Full stack pack for Apache Flink engagements. Nothing curated exists in the ecosystem
([survey](../../docs/stack-packs.md)) — these skills are first-party, verified against
official docs for **1.20 LTS and 2.3** (config keys taught are the ones identical in
both; version breaks flagged inline).

## What this pack provides

- **Skills**: `flink-idioms` (checkpointing/exactly-once, watermarks, state, savepoints,
  SQL vs DataStream, Kafka connector), `flink-diagnosis` (backpressure localization,
  checkpoint failures, state explosion, restart loops, watermark stalls),
  `flink-operations` (deployment/HA, metrics, rescaling limits, upgrade discipline,
  config pitfalls).
- **MCP: none shipped.** The survey found no shippable Flink MCP server (community ones
  are run-from-source, single-digit maturity; Confluent's covers Confluent Cloud only).
  Diagnostics go through the Flink UI / REST API (`/jobs`, checkpoint stats) — document
  the client's endpoints in the project overlay. Revisit on the next ecosystem survey.

## Critical version note

**State compatibility is NOT guaranteed between Flink 1.x and 2.x** (official release
notes). A 1.20 savepoint is not a supported upgrade path to 2.x — plan 1.x→2.x moves as
migrations (fresh state or dual-run), never as routine savepoint upgrades.

## Per-project setup

1. `/plugin install de-flink@myagency --scope project`
2. Record in the overlay: Flink version (1.20 vs 2.x changes advice), deployment mode,
   REST endpoint, checkpoint storage location.
