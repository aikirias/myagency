# Tasks: ETH Price Daily Ingestion

## Architecture & design
- [ ] Review proposal.md and design.md — confirm schema, load pattern, and open questions
- [ ] Resolve open question: keep or drop `price_change_24h_usd` from stage table

## DDL & migration
- [ ] Create migration `02-eth-price.sql` in `local-stack/starrocks/migrations/`
  - `db_stage.eth_price_daily` (mirrors BTC stage table, asset = `ethereum`)
  - `db_data_model.fact_eth_daily_price` (mirrors BTC curated table)
- [ ] Apply migration to local StarRocks

## Pipeline implementation
- [ ] Create DAG `eth_price_daily.py` in `local-stack/airflow/dags/`
  - CoinGecko URL with `ids=ethereum`
  - Stage table: `db_stage.eth_price_daily`
  - Model table: `db_data_model.fact_eth_daily_price`
  - Schedule: `0 6 * * *`, `catchup=False`, `max_active_runs=1`
  - Retries: 3, retry_delay: 5 min, execution_timeout: 30 min
  - Tasks: `start → fetch_and_load → transform_to_model → validate_load → end`

## Data quality checks
- [ ] Define freshness check on `fact_eth_daily_price` (threshold: 26h)
- [ ] Define volume check (COUNT > 0 per run, alert if 0 rows)
- [ ] Define duplicate check on `price_date`
- [ ] Define null check on `price_usd` (required field, 0% null threshold)

## Validation
- [ ] Trigger DAG manually from Airflow UI — confirm all tasks green
- [ ] Verify `db_stage.eth_price_daily` has 1 row for today's `price_date`
- [ ] Verify `db_data_model.fact_eth_daily_price` has 1 row for today's `price_date`
- [ ] Re-trigger DAG for same date — confirm no duplicate rows produced
- [ ] Confirm `price_usd` value is reasonable (cross-check spot price manually)

## Documentation & publication
- [ ] Add `eth_price_daily` to `local-stack/README.md` demo tables section
- [ ] Add migration notes to `local-stack/starrocks/migrations/` header comment
