---
name: practice-observability-and-ownership
description: Observability and ownership standards - named owners, failure alerting, freshness signals, loud failures, no silent record dropping, runbooks. Use when reviewing production readiness of any pipeline or dataset, or when designing alerting and operational handoff.
---

# Practice: observability and ownership

Ownerless data is unmaintainable data, and a pipeline nobody hears failing is already
broken. Production-readiness is defined by who finds out, how fast, and what they do next.

## Production minimum — per pipeline and per dataset

- **Named owner**: the team or person who answers for incidents and changes, recorded in
  the pipeline, the checks, and the table metadata.
- **Failure alert**: every production workflow alerts on failure, to a channel someone
  actually watches, with the owner named.
- **Freshness signal**: a reliable way to know data recency (watermark, load timestamp,
  interval marker) plus the check that watches it.
- **Volume sanity**: source row counts or an equivalent ingestion sanity check on every
  load.
- **Runbook or escalation path**: what to do when it breaks, executable by someone who
  did not write the pipeline.

Anything missing from this list means not production-ready — say so explicitly.

## Failure behavior

- **Fail loudly, never corrupt silently.** Schema mismatches stop the pipeline; they do not
  get coerced quietly.
- **Never drop failed records silently.** Malformed or rejected records are preserved with
  their original payloads (failure log / dead-letter) so they can be replayed after the
  fix. "It skipped some rows" without a record of which is data loss.
- Alerts distinguish severity (see `practice-data-quality-minimums`); an alert channel
  where everything is critical trains people to ignore it.

## Operational cost

- Prefer solutions with predictable operational cost over clever ones that need babysitting.
- Never remove retries, alerts, or safety checks without explicit instruction — removing
  a safeguard is a decision the owner makes, not a cleanup.
