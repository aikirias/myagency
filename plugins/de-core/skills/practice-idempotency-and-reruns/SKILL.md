---
name: practice-idempotency-and-reruns
description: Idempotency and rerun-safety standards for pipelines - safe write patterns, partial-failure cleanliness, deterministic behavior under retries and replays. Use when designing, implementing, or reviewing any pipeline, load process, or write pattern.
---

# Practice: idempotency and reruns

Every pipeline must be safe to re-run for the same logical interval without producing
incorrect results. Retries, replays, and backfills are normal operation, not exceptions —
design for them from the start.

## Write patterns

| Pattern | Rerun-safe | Notes |
| --- | --- | --- |
| Interval-bounded replace | Yes | Replaces exactly the targeted interval |
| DELETE + INSERT in one transaction | Yes | Atomic partition replacement |
| MERGE / UPSERT by business key | Yes | Idempotent by definition; key must be truly unique |
| Blind INSERT / append | No | Duplicates on every retry — never acceptable alone |
| File append | No | Same problem; replace or version deterministically |

If the engine's dedup semantics are eventual (merge-on-read engines), rerun safety must
account for the window where duplicates are visible — the applicable stack pack covers the
engine-specific mechanics.

## Rules

- **Partial failure leaves a clean state.** A run that dies halfway must not leave a
  half-loaded interval that the retry then doubles. Write atomically per interval, or
  stage-then-swap.
- **Deduplication is explicit.** Name the business key and the conflict-resolution rule
  (latest wins by which column?). "The engine handles it" is not a design.
- **Deterministic outputs.** Same input interval → same output, independent of run time.
  Never derive logic from "now" inside the transformation; the execution interval is a
  parameter.
- **Every step has retries and a timeout.** A step without a timeout can hang a whole
  schedule; a step without retries turns transient blips into incidents.
- **Prove it before trusting it.** Before enabling automatic retries, replays, or
  backfills, actually re-run an interval and verify counts and key metrics are unchanged.
