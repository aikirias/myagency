---
name: method-safe-operations
description: Safety rules for operating in client environments - read-only by default, EXPLAIN before executing any query, no object creation or DML/DDL in production without explicit permission, evidence logging. Use whenever connecting to, querying, or considering ANY action against a client database, orchestrator, or production system.
---

# Method: safe operations in client environments

A consultant's access is a privilege operating on someone else's production. The default
posture is read-only, bounded, and auditable. These rules apply to every client environment;
treat any environment as production unless the client explicitly states otherwise.

## Query execution rules

1. **EXPLAIN first, always.** Before executing any query you wrote, run `EXPLAIN` (or the
   engine's dry-run / cost-estimate equivalent) and read it. If the plan shows a full scan on
   a large table, an exploding join, or missing partition pruning — do not run it; bound it
   first.
2. **Bound every probe.** Diagnostic queries carry partition/date filters and `LIMIT` unless
   there is a specific reason not to, stated before running.
3. **Prefer non-production.** For heavy analysis, ask for a replica, staging copy, or
   sampled extract. Only run heavy queries on production when there is no alternative and
   the EXPLAIN says it is safe, ideally off-peak.
4. **Watch what you displace.** A "read-only" query can still degrade a shared cluster.
   If the environment serves live traffic, size your queries accordingly.

## Write and object rules

5. **No object creation in production without explicit permission.** No tables, views,
   temp/scratch schemas, functions, or indexes — not even "harmless" ones. If a helper
   object is genuinely needed, request permission naming the exact object, its purpose,
   and when it will be dropped.
6. **No DML/DDL without explicit approval.** UPDATE/DELETE/INSERT/ALTER against client data
   happen only as part of an agreed fix, with the rollback plan written first (see the
   deliverable contracts). Destructive statements always have an explicit WHERE/partition
   bound.
7. **No operational interventions without approval.** Do not kill queries, change settings,
   pause/trigger pipelines, or restart services on your own initiative — recommend the
   action and let the client execute or approve it.

## Implementation discipline

8. **Dry run before implementing.** When testing whether something works or performs
   better, validate it in dry-run form first — `EXPLAIN`/cost estimate, the engine's
   dry-run mode, or a transaction you roll back — and move to real implementation only
   after the dry run passes. Never test by creating real objects ad hoc.
9. **Leave no orphans.** Every object created (with permission) is recorded with its
   purpose and a planned removal step. Before closing the engagement, every temporary
   object is dropped or explicitly handed over — the client's database ends cleaner than
   you found it.

## Evidence and audit

10. **Log everything you execute.** Keep a running log of every statement run in a client
   environment: statement, target, timestamp, why, result summary. It doubles as audit trail
   and as the evidence base for the deliverable.
11. **Capture, don't mutate.** Evidence gathering must never alter state. Save outputs to
   local files, not to tables in the client's database.

## Credentials and data handling

12. **Never hardcode or copy credentials** into files, deliverables, notes, or chat context.
    Use the client's approved secret mechanism; reference variables, not values.
13. **Minimize data extraction.** Pull aggregates and small samples, not full tables.
    Client data does not leave the client's boundary unless the engagement explicitly
    allows it.

## Stop rule

14. If completing a validation would require breaking any rule above, stop at the safe
    boundary and report exactly what remains unverified and what permission or environment
    would be needed to verify it. An honest "unverified" beats an unauthorized test.
