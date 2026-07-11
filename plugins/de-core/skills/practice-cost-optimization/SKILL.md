---
name: practice-cost-optimization
description: Cost optimization practice for data platforms - measure before optimizing, the usual wins (pruning, cadence, pre-aggregation, retention, zombie assets), quantified recommendations. Use when analyzing platform costs, reviewing expensive queries or pipelines, or when a client asks to reduce data infrastructure spend.
---

# Practice: cost optimization

Measure before optimizing: find where the money actually goes before touching anything.
Cost work without a baseline produces anecdotes, not savings.

## Step 1 — Build the cost map

Identify the top drivers with real numbers (billing data, query logs, storage metrics):

- **Compute/scan**: which queries and pipelines scan or compute the most, how often
- **Storage**: largest tables, growth rate, how much is never read
- **Idle/over-provisioning**: clusters sized for a peak that rarely happens
- **Transfer/egress**: cross-region or cross-system movement

Rank by spend. Optimize the top of the list; ignore the noise below it.

## Step 2 — The usual wins, in rough order of return

1. **Scan reduction**: partition pruning actually working, column pruning (no `SELECT *`),
   incremental instead of full refresh. On scan-billed engines the `EXPLAIN`/dry-run
   doubles as a cost estimate — use it before and after.
2. **Cadence right-sizing**: does this really need to run hourly? Match refresh frequency
   to the decision it feeds (see `method-discovery` — ask what changes with fresher data).
3. **Pre-aggregation**: dashboards repeatedly aggregating raw detail → materialize the
   aggregate once, serve it many times.
4. **Retention and tiering**: TTLs on raw/history, cold storage for rarely-read data,
   drop what nobody reads — with the owner's sign-off, never unilaterally.
5. **Zombie hunting**: pipelines still running for consumers that no longer exist, tables
   written but never read. Usage audit first, then decommission through the client's
   process.
6. **Right-sizing compute**: smaller clusters, autoscaling, spot/preemptible where retries
   make it safe (see `practice-idempotency-and-reruns` — spot requires rerun safety).

## Rules

- **Quantify every recommendation**: current cost, expected savings, effort, and risk.
  "This would be cheaper" without numbers is not a recommendation.
- **Never trade correctness or safety for cost.** Removing checks, retries, or replicas to
  save money is a client decision made with eyes open, not an optimization.
- **Verify after**: re-measure the driver you optimized and report actual vs expected
  savings in the deliverable.
- Engine-specific levers (engine settings, storage formats, index/order-by tuning) live in
  the stack packs.
