---
name: spark-idioms
description: Apache Spark engine idioms - idempotent writes (partition overwrite modes), object-storage commit protocols and their traps, AQE scope, join strategies, file sizing, Structured Streaming sink guarantees. Use when designing or reviewing Spark jobs, writes, joins, or streaming pipelines.
---

# Spark idioms (OSS 3.5.x / 4.x; version gates flagged)

## Idempotent writes (practice-idempotency-and-reruns on Spark)

- Blind `append` is never rerun-safe. The bounded-replace pattern is
  `INSERT OVERWRITE ... PARTITION (...)` / `df.write.mode("overwrite")` with
  `spark.sql.sources.partitionOverwriteMode`:
  - **`STATIC` (default)**: deletes ALL partitions matching the spec before writing —
    an unpartitioned-spec overwrite replaces the whole table.
  - **`dynamic`**: only partitions that receive data are overwritten. The per-write
    option `df.write.option("partitionOverwriteMode", "dynamic")` takes precedence over
    the session config — check both when reviewing.
- 4.x also has `INSERT INTO ... REPLACE WHERE` for predicate-bounded replaces.

## Object-storage commits — where correctness silently dies

- Rename-based `FileOutputCommitter`: **v1** is safe but "very, very slow" on S3 (docs'
  words); **v2** is faster but UNSAFE where renames/listings aren't atomic. Finding
  either on S3 without an S3A committer is an audit finding.
- S3A committers (directory/partitioned/**magic** — magic is Hadoop's current
  recommendation) write via multipart uploads completed at job commit: no renames, task
  failures can't corrupt output. Spark side: `fs.s3a.committer.name` +
  `spark.sql.sources.commitProtocolClass=...PathOutputCommitProtocol` +
  `BindingParquetOutputCommitter`.
- **Documented trap**: dynamic partition overwrite is **NOT supported by the S3A
  committers on S3** — that combination is where "sometimes the partition is empty after
  the job" comes from. On S3 use partitioned-committer conflict modes or a table format
  (Iceberg/Delta/Hudi). GCS/ABFS: use the manifest committer (Hadoop ≥3.3.5), which DOES
  support dynamic overwrite (mandatory on GCS — no atomic dir rename).

## Partitions and files

- `coalesce(n)` = no shuffle but collapses upstream parallelism when drastic;
  `repartition` = shuffle but keeps parallelism. Read-split sizing:
  `spark.sql.files.maxPartitionBytes` (128MB default).
- **OSS Spark has no automatic small-file compaction.** Levers: `REBALANCE` hint under
  AQE (targets `advisoryPartitionSizeInBytes`), `maxRecordsPerFile`, explicit
  `repartition(cols)` before write; periodic compaction jobs or table formats are the
  structural fix (community-standard practice).

## AQE — what it fixes and what it does NOT

Enabled by default since 3.2. It auto-fixes: post-shuffle partition coalescing,
SMJ→broadcast conversion at runtime, and **skewed partitions in sort-merge JOINS**
(`skewedPartitionFactor` 5× median AND >256MB threshold).

It does NOT fix: skew in **aggregations**, a single hot key (partition splitting can't
split one key), or cases where the fix needs an extra shuffle (unless
`forceOptimizeSkewedJoin`). **Key salting remains the manual fix** for those
(community pattern). Two configs worth setting on busy clusters:
`coalescePartitions.parallelismFirst=false` (docs' own advice — default ignores the size
target) and a high `initialPartitionNum` letting AQE coalesce down.

## Joins

- Broadcast threshold `spark.sql.autoBroadcastJoinThreshold` = 10MB, stats-based —
  stale/absent stats broadcast the wrong thing or miss the chance; `broadcastTimeout` =
  300s fails slow builds. Inspect estimates with `EXPLAIN COST`.
- Hints are requests, not orders (docs: no guarantee); precedence BROADCAST > MERGE >
  SHUFFLE_HASH > SHUFFLE_REPLICATE_NL.

## Structured Streaming — sink guarantees (know the table)

End-to-end exactly-once = replayable source + checkpoint (HDFS-compatible dir) +
**idempotent sink**. Per sink:

| Sink | Guarantee |
| --- | --- |
| File | Exactly-once (append only) |
| Kafka | At-least-once |
| foreach | At-least-once |
| **foreachBatch** | At-least-once by default — **use the provided `batchId` to dedupe for exactly-once** |

foreachBatch extras: persist/unpersist the batch DF when running multiple actions on
stateful queries (state reloads per action otherwise).
