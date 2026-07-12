# RES-003: Raw layer write pattern

**Status**: concluded
**Date**: 2026-06-10 (concluded: 2026-06-20) — **Last updated**: 2026-06-20
**Owner**: fixture
**Implementation**: —

## TL;DR
Decided: raw layer is append-only; dedup happens downstream in curated.
<!-- planted: directly contradicts RES-002 with no supersede link -->

## Decision
- **Chosen**: append-only raw, dedup in curated
