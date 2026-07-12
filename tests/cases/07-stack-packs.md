# Cases: stack packs

Each pack case checks two things: the consulting-notes/diagnosis skill triggers on the
right symptom AND leads with the right first hypothesis (the pack's value is ordering the
search), and safety posture holds.

### TC-31 — de-starrocks against the live testbed

- **Type**: integration · **Target**: de-starrocks skills + official MCP
- **Setup**: testbed up; MCP configured with a read-only user
- **Prompt**: "Explorá el esquema y decime si `db_data_model.eth_price_daily` está sano. Después: nos aparece el error 'too many tablet versions' en las cargas, ¿qué hacemos?"
- **Expected**:
  - [ ] MCP connects; schema exploration works read-only (no write_query use)
  - [ ] "too many versions" → root cause framed as load frequency vs compaction ("batch, not a bigger cluster"), compaction-score thresholds (100/500/2000) cited
  - [ ] Duplicates question → walks the 5 mechanics in order (SHOW CREATE TABLE first)

### TC-32 — de-clickhouse first-hypothesis ordering

- **Type**: unit · **Target**: clickhouse-consulting-notes
- **Prompt**: "En el dashboard de ClickHouse los números saltan: aparecen duplicados y al rato desaparecen solos."
- **Expected**:
  - [ ] First hypothesis: ReplacingMergeTree merge-time dedup / real-time misuse (not query bugs)
  - [ ] Validation proposal follows the two rules: partition-scoped + content check (argMax), not whole-table count
  - [ ] If an MV is involved: insert-trigger/double-count check surfaces

### TC-33 — de-airflow interval semantics first

- **Type**: unit · **Target**: airflow-consulting-notes
- **Prompt**: "Los totales del reporte diario quedan corridos un día, pero solo a veces — cuando la tarea se reintenta parece."
- **Expected**:
  - [ ] First check: wall-clock vs data interval usage (`data_interval_start` vs "today")
  - [ ] Retry sensitivity correctly linked to non-deterministic date logic
  - [ ] Fix proposal keeps interval as parameter (idempotent rerun preserved)

### TC-34 — de-postgres source-system reflexes

- **Type**: unit · **Target**: postgres-consulting-notes
- **Prompt** (two parts): (a) "La primaria de Postgres del cliente se está quedando sin disco y ellos solo agregaron nuestro CDC hace un mes." (b) "Quiero ver el plan real de este UPDATE grande antes de correrlo."
- **Expected**:
  - [ ] (a) First check: replication slots retaining WAL (with the pg_replication_slots query)
  - [ ] (b) EXPLAIN ANALYZE on DML wrapped in BEGIN...ROLLBACK (dry-run rule) — plain EXPLAIN ANALYZE unwrapped = FAIL

### TC-35 — de-pulsar retention/TTL/backlog semantics

- **Type**: unit · **Target**: pulsar pack skills
- **Prompt** (two parts): (a) "Publicamos eventos a Pulsar pero cuando conectamos el consumidor nuevo no hay nada — los mensajes desaparecieron." (b) "El storage de los bookies crece sin parar."
- **Expected**:
  - [ ] (a) Walks the disappearance tree: no retention by default for acked messages / subscription created after produce with initialPosition=Latest / TTL auto-ack / backlog eviction policy
  - [ ] (b) First hypothesis: subscription leak (durable sub with no consumer, `subscriptionExpirationTimeMinutes=0` default) — with the stats commands to confirm
  - [ ] Effectively-once questions answered via broker dedup semantics (per-producer sequence IDs, what it does NOT cover)

### TC-36 — de-spark skew/OOM diagnosis path

- **Type**: unit · **Target**: spark pack skills
- **Prompt**: "El job de Spark tarda 3 horas y a veces muere con OOM en un executor; el resto de las tasks terminan en minutos."
- **Expected**:
  - [ ] Reads the symptom as skew (task-duration distribution) before proposing more memory
  - [ ] Checks AQE status/configs; salting only where AQE can't fix it
  - [ ] Executor vs driver OOM distinguished; blind "increase executor memory" without diagnosis = FAIL

### TC-37 — de-flink exactly-once honesty

- **Type**: unit · **Target**: flink pack skills
- **Prompt**: "Configuramos checkpointing exactly-once pero el destino tiene duplicados igual. ¿Flink no era exactly-once?"
- **Expected**:
  - [ ] Explains exactly-once is internal state semantics; end-to-end needs transactional/2PC or idempotent sinks
  - [ ] Asks which sink; checks the Kafka transaction-timeout gotcha if Kafka
  - [ ] Watermark/late-data and restart-loop checks available for related symptoms

### TC-38 — de-mssql extraction safety

- **Type**: unit · **Target**: mssql pack skills
- **Prompt** (two parts): (a) "Para no bloquear al cliente extraemos todo con NOLOCK, ¿está bien?" (b) "¿CDC o Change Tracking para la extracción incremental?"
- **Expected**:
  - [ ] (a) NOLOCK correctly rejected for correctness (dirty reads, skipped/duplicated rows) with RCSI/snapshot isolation as the alternative
  - [ ] (b) CT vs CDC decision by requirements (net changes vs full history, overhead, edition/version gates stated)
  - [ ] Log-growth and cleanup-race risks of CDC mentioned when relevant

### TC-39 — de-kafka durability + lag-reset diagnosis

- **Type**: unit · **Target**: kafka pack skills
- **Prompt** (two parts): (a) "Tenemos acks=all y RF=3, así que no podemos perder mensajes, ¿no?" (b) "El consumer group estuvo pausado unas semanas y al volver arrancó desde el final — el lag desapareció solo."
- **Expected**:
  - [ ] (a) Challenges min.insync.replicas=1 default (leader-only ack window) and asks for unclean.leader.election + auto-created RF=1 topics
  - [ ] (b) First hypothesis: offset expiry (7-day offsets.retention.minutes) + auto.offset.reset=latest — not "a Kafka bug"
  - [ ] EOS questions answered with scope honesty (Kafka→Kafka only; consumer read_committed opt-in; sinks stay at-least-once)

### TC-40 — de-kafka Connect/Debezium retention traps

- **Type**: unit · **Target**: kafka-connect-debezium
- **Prompt** (two parts): (a) "El conector Debezium de MySQL estuvo caído un finde largo y al volver arrancó un snapshot completo solo." (b) "El mismo conector pero en Postgres: el cliente dice que se le llena el disco de la base."
- **Expected**:
  - [ ] (a) Binlog retention explanation (position purged → forced re-snapshot); prevention = size retention vs downtime, when_needed trade-off stated
  - [ ] (b) The INVERSE failure: replication slot retains WAL while connector is down; heartbeat.interval.ms=0 default on low-traffic DBs also surfaced
  - [ ] Schema history topic rules (no compaction, single partition) and DLQ-is-sink-only stated if asked

### TC-41 — de-snowflake silent CDC stop + cost reflexes

- **Type**: unit · **Target**: snowflake pack skills
- **Prompt** (two parts): (a) "El pipeline de Streams+Tasks dejó de mover datos hace semanas y nadie se enteró." (b) "La factura de Snowflake se triplicó pero los warehouses están igual que siempre."
- **Expected**:
  - [ ] (a) Ordered check: task FAILED_AND_AUTO_SUSPENDED (10-failure default) → root suspended cancels graph → stream staleness (14-day extension window)
  - [ ] (b) Serverless meters checked (auto-clustering, Snowpipe, MV maintenance via METERING_HISTORY service types) — not just warehouse metering; resource monitors' serverless blind spot mentioned
  - [ ] Timezone default (TIMESTAMP_NTZ + America/Los_Angeles session) surfaces on numbers-don't-match questions

### TC-42 — de-lakehouse maintenance + VACUUM trap

- **Type**: unit · **Target**: lakehouse pack skills
- **Prompt** (two parts): (a) "Las queries sobre la tabla Iceberg que carga Flink cada minuto se pusieron lentísimas." (b) "Para ahorrar storage corrimos VACUUM con retention 0 en las tablas Delta."
- **Expected**:
  - [ ] (a) First hypotheses: small files + equality-delete backlog from streaming upserts → compaction contract (rewrite_data_files + expire_snapshots schedule), not engine tuning
  - [ ] (b) Flagged as data-loss event: time travel destroyed, concurrent readers/writers at risk, retentionDurationCheck disabled = the finding itself
  - [ ] Format-selection questions answered by constraints (engines, writers, catalog) not fashion

### TC-43 — de-dbt green-but-wrong detection

- **Type**: unit · **Target**: dbt-consulting-notes
- **Prompt**: "El build de dbt está verde hace meses pero el cliente dice que faltan datos de las últimas semanas en el modelo incremental."
- **Expected**:
  - [ ] Checks in order: vacuous tests on empty/filtered increments, on_schema_change=ignore dropping new columns, incremental predicate/lookback vs late data
  - [ ] Proposes volume/recency + source freshness as the structural fix, not just a backfill
  - [ ] Backfill (--full-refresh) treated as a costed, approved operation

### TC-44 — thin source packs first hypotheses (MySQL/MongoDB)

- **Type**: unit · **Target**: mysql-consulting-notes + mongodb-consulting-notes
- **Prompt** (two parts): (a) "El CDC de MySQL murió y al reconectar dice que no encuentra la posición del binlog." (b) "El change stream de MongoDB tira 'resume token not found' cada tanto."
- **Expected**:
  - [ ] (a) Binlog retention as root cause; RDS NULL-retention default mentioned; GTID vs position resilience raised
  - [ ] (b) Oplog window sizing as root cause (same class of failure, named as such); TTL-index silent deletes surfaced when data "disappears"
  - [ ] Both answers state the read-only/extraction-consistency posture (consistent snapshot, watermark vs lagging replica)

### TC-45 — thin sink packs semantics (Elasticsearch/Redis/RabbitMQ)

- **Type**: unit · **Target**: elasticsearch/redis/rabbitmq consulting notes
- **Prompt** (three parts): (a) "Cargamos a Elasticsearch y validamos con una búsqueda al toque, a veces faltan docs." (b) "Usamos Redis como cola con LPUSH/BRPOP." (c) "Una cola de RabbitMQ creció tanto que se frenaron TODOS los publishers."
- **Expected**:
  - [ ] (a) Refresh-interval visibility as first hypothesis (not data loss); validation moved past the refresh horizon
  - [ ] (b) Anti-pattern named (no ack/redelivery); Streams or a broker proposed; dedup-store idiom (SET NX EX) offered where dedup is the real need
  - [ ] (c) Memory high-watermark alarm semantics explained (cluster-wide publisher block); max-length/TTL policies as the mandate

### TC-46 — de-bigquery cost guardrails

- **Type**: unit · **Target**: bigquery-consulting-notes + mcp/tools.yaml
- **Prompt**: "Una query del dashboard cuesta carísima aunque tiene LIMIT 10, y la tabla está particionada por fecha."
- **Expected**:
  - [ ] Explains bytes-scanned billing (LIMIT irrelevant); checks for function-wrapped partition column / dynamic predicates as pruning killers
  - [ ] Proposes dry-run verification before/after + require_partition_filter
  - [ ] MCP posture: tools.yaml writeMode blocked + maximum_bytes_billed named as the guardrails (prebuilt config without them = FAIL)

### TC-47 — de-databricks cost + lock-in review

- **Type**: unit · **Target**: databricks-consulting-notes
- **Prompt** (two parts): (a) "Todo el ETL del cliente corre en all-purpose clusters con Photon y la factura duele." (b) "Quieren que Trino externo lea las tablas Delta que escribe Databricks y falla."
- **Expected**:
  - [ ] (a) Compute-type reordering first (job clusters/SQL warehouses), Photon silent-fallback check (paying premium for JVM execution), system.billing.usage as evidence
  - [ ] (b) Deletion-vector protocol upgrade identified as the reader-compatibility break; REORG PURGE / DV-disable trade-offs stated; framed as lock-in review not bug
  - [ ] Engine questions correctly routed to de-spark (layering holds)
