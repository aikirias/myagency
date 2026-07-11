# Proposal: ETH Price Daily Ingestion

**Status**: Accepted
**Owner**: data-engineering
**Date**: 2026-05-31

## Problem

The local stack currently ingests the daily BTC/USD price from CoinGecko and exposes it in a curated model (`db_data_model.fact_btc_daily_price`). There is no equivalent pipeline for ETH/USD. Any analysis, dashboard, or downstream model that needs ETH price data has no available source in the platform — requiring ad-hoc API calls or manual lookups outside the data stack.

## Proposed Solution

Add a daily ETH/USD price ingestion pipeline that mirrors the existing `btc_price_daily` pattern. The pipeline fetches the current ETH price snapshot from the CoinGecko `simple/price` endpoint, lands raw data in `db_stage.eth_price_daily`, transforms it into a curated fact table `db_data_model.fact_eth_daily_price`, and validates the load. The Airflow DAG runs daily at 06:00 UTC with the same retry and timeout boundaries as the BTC pipeline.

## Success Criteria

- [ ] `db_stage.eth_price_daily` exists and receives one row per pipeline run with `price_usd`, `market_cap_usd`, `volume_24h_usd`, `price_change_percentage_24h`, and `loaded_at` populated
- [ ] `db_data_model.fact_eth_daily_price` is unique by `price_date` and contains correctly typed, cast values from stage
- [ ] DAG `eth_price_daily` is visible in Airflow, runs successfully on manual trigger, and produces a validated row in the curated table
- [ ] A re-run for the same `price_date` does not produce duplicate rows in either table
- [ ] Freshness, volume, duplicate, and null data quality checks are defined for `fact_eth_daily_price`

## Out of Scope

- Historical backfill of ETH prices before the first pipeline run
- ETH/non-USD pairs (e.g. ETH/BTC, ETH/EUR)
- Sub-daily or streaming price updates
- Business model / serving layer aggregations on top of ETH price
- Combined BTC+ETH comparison models

## Open Questions

| Question | Owner | Due |
| --- | --- | --- |
| Should the stage table use `UNIQUE KEY(price_date)` (idempotent upsert) like BTC, or `DUPLICATE KEY` (append)? | data-engineering | 2026-06-01 |
| Is there a downstream consumer that needs ETH price immediately after go-live? | data-engineering | 2026-06-01 |
