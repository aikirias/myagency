# Cases: de-core practice skills

### TC-12 — SQL review catches the planted defects

- **Type**: unit · **Target**: practice-sql-quality
- **Setup**: sandbox; copy `tests/fixtures/bad_query.sql` in
- **Prompt**: "Revisá este SQL antes de que lo mandemos a prod."
- **Expected** (all six planted defects found, correctness ranked first):
  - [ ] `SELECT *` · [ ] implicit cartesian join · [ ] positional GROUP BY
  - [ ] function on partition column (kills pruning) · [ ] `= NULL` · [ ] DELETE without WHERE flagged as blocker
  - [ ] Proposes corrected version; wrong-results issues ranked above style

### TC-13 — Idempotency review of a blind-append DAG

- **Type**: unit · **Target**: practice-idempotency-and-reruns (+ airflow notes if installed)
- **Setup**: sandbox; copy `tests/fixtures/blind_append_dag.py` in
- **Prompt**: "Revisá este DAG, ¿está listo para producción?"
- **Expected**:
  - [ ] Blind INSERT flagged as blocker (duplicates on retry/catchup)
  - [ ] `catchup=True` + non-idempotent combo called out; wall-clock date vs data interval called out
  - [ ] Missing retries/timeout flagged; proposes bounded replace/upsert pattern
  - [ ] Verdict: NOT production-ready

### TC-14 — DQ suite generation is complete and automated

- **Type**: integration (testbed) · **Target**: practice-data-quality-minimums
- **Prompt**: "Generá los checks de calidad para `db_data_model.eth_price_daily`."
- **Expected**:
  - [ ] The four minimums present (freshness, volume, duplicates on the business key, nulls)
  - [ ] Every check has severity + owner + alert channel + threshold (placeholder thresholds labeled as needing calibration)
  - [ ] Includes the automated-execution spec (where it runs, on what schedule, what happens on critical FAIL) — a SQL file alone = FAIL
  - [ ] Zero-rows case marked critical

### TC-15 — Backfill plan preconditions

- **Type**: unit · **Target**: practice-backfill-safety
- **Prompt**: "Necesito re-cargar 18 meses de historia de una tabla de ~2M filas/día."
- **Expected**:
  - [ ] Refuses to produce a "just run it" plan; the five preconditions appear (idempotency verified, source availability, target state, downstream notified, rollback defined)
  - [ ] Batch size fits the volume table (1-3 days per batch); first batch = canary with validation
  - [ ] Off-peak/concurrency guidance; QA checkpoints per batch

### TC-16 — Architecture selection pushes back correctly

- **Type**: unit · **Target**: practice-architecture-selection
- **Prompt** (two parts): (a) "Quiero SCD2 en la dimensión de clientes." (b) "El dashboard tiene que ser real-time."
- **Expected**:
  - [ ] (a) Demands a concrete named point-in-time query before accepting SCD2; offers SCD1/snapshots as defaults
  - [ ] (b) Asks what decision changes with 1-minute vs 1-hour data; maps human-reader → batch/micro-batch
  - [ ] Recommendations framed via the decision frameworks (engine class, layering), not tool marketing

### TC-17 — Lifecycle answers with a policy, not a shrug

- **Type**: unit · **Target**: practice-data-lifecycle
- **Prompt**: "¿Cuánto tiempo guardamos el raw? El storage está creciendo mucho."
- **Expected**:
  - [ ] Hot window + cold tier for raw (archive ≠ delete, replay retained)
  - [ ] Restore-tested archives + schema-travels-with-data mentioned
  - [ ] Ties tiering to observed usage; purge/erasure obligations reach archives

### TC-18 — Cost work demands a baseline

- **Type**: unit · **Target**: practice-cost-optimization
- **Prompt**: "El cliente quiere bajar el gasto de la plataforma ya. ¿Qué hacemos?"
- **Expected**:
  - [ ] First step is the cost map from real data (billing/query logs), not generic tips
  - [ ] Recommendations follow the return-ordered levers and are quantified (current cost, expected saving, effort, risk)
  - [ ] Refuses to trade correctness/safety for cost without explicit client decision

### TC-19 — PII discipline in evidence

- **Type**: unit · **Target**: practice-pii-handling
- **Setup**: sandbox with a small table/file containing fake emails + names
- **Prompt**: "Armá la evidencia del diagnóstico con algunas filas de ejemplo de esta tabla de clientes."
- **Expected**:
  - [ ] Sample rows in the produced evidence have identifier columns masked/hashed
  - [ ] Prefers aggregates over raw rows to prove the point
  - [ ] No PII written outside the project boundary (no scratch copies with raw identifiers)
