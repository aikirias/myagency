# de-lakehouse

Full stack pack for the lakehouse layer: **Apache Iceberg + Delta Lake + Trino** as one
pack, because the consulting delta is precisely the interaction between table-format
maintenance discipline and query-engine behavior. No official skills exist from
apache/iceberg, delta-io, or trinodb ([survey](../../docs/stack-packs.md)) — this content
is first-party, verified against Iceberg 1.11 / Delta OSS / Trino 482 docs.

**Layering**: Spark-engine content is in `de-spark`; Databricks-platform Delta behavior
(DV defaults, liquid clustering auto-on, predictive optimization) is in `de-databricks` +
the official `databricks` plugin. This pack is engine-neutral OSS ground truth.

## Skills

- `iceberg-discipline` — maintenance (compaction/expiration/orphans), MoR vs CoW,
  hidden partitioning/evolution, WAP branches, CDC reads.
- `delta-discipline` — VACUUM vs time travel, deletion vectors, concurrency conflicts,
  schema/column mapping, CDF, UniForm limits.
- `trino-engine` — FTE reality, memory guillotines, CBO/stats discipline, pushdown
  variance, timestamp semantics, connector-side table maintenance.
- `lakehouse-format-selection` — vendor-neutral Iceberg vs Delta vs plain Parquet
  decision inputs (feeds `practice-architecture-selection`).

## MCP (documented, not shipped as `.mcp.json` — pick per engine)

| Engine | Server | Read-only mechanism |
| --- | --- | --- |
| OSS Trino | [tuannvm/mcp-trino](https://github.com/tuannvm/mcp-trino) (Go binary, brew/install.sh) | **Read-only by default** — writes require `TRINO_ALLOW_WRITE_QUERIES=true`, never set it |
| Starburst | Built-in coordinator MCP (SEP 481-e+/Galaxy) | Hard read-only by design (rejects all writes/DDL), 1MB result cap |
| AWS S3 Tables (Iceberg) | awslabs S3 Tables MCP | Read-only by default; `--allow-write` never passed |
| Dremio | dremio/dremio-mcp | Mode-scoped |

Pin exact invocation/env against the current release on first client use, then freeze in
the client repo's `.mcp.json` (same protocol as de-pulsar/de-rabbitmq).

## Setup

`/plugin install de-lakehouse@myagency --scope project`. Ask for a read-only engine user
(Trino: user without write grants on the catalogs; the MCP flag is not the guarantee).
