# RES-004: Real-time serving layer

**Status**: in-progress
**Date**: 2026-06-25 — **Last updated**: 2026-06-28
**Owner**: fixture
**Implementation**: —

## TL;DR

Investigation blocked on an unresolved escalation: the project overlay mandates
batch-only serving, but the stakeholder requirement and vendor guidance point to
streaming ingestion for the fraud dashboard.

## Escalations

- **Conflict**: project decision "batch-only platform, no streaming components"
  (overlay) vs vendor best practice for sub-minute fraud detection (official docs)
- **Stakes**: keeping constraint → fraud team gets 15-min data; changing → new ops
  surface, on-call burden
- **Options presented**: uphold / scoped exception for fraud topic / supersede decision
- **Resolution**: <!-- UNRESOLVED — planted for TC-29: review must surface this FIRST -->

## Journal

- 2026-06-25 — framed question, gathered constraints
- 2026-06-28 — vendor docs reviewed; conflict identified and escalated
