# RES-002: Dedup strategy for raw events

**Status**: concluded
**Date**: 2026-03-01 (concluded: 2026-03-15) — **Last updated**: 2026-03-15
**Owner**: fixture
**Implementation**: —

## TL;DR
Decided: upsert raw events by business key at ingestion.
<!-- planted: concluded >90 days, never implemented; contradicted by RES-003 -->

## Decision
- **Chosen**: upsert by business key at the raw layer
