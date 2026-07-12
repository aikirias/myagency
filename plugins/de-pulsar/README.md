# de-pulsar

Full stack pack for Apache Pulsar engagements. No curated Pulsar knowledge exists in the
plugin ecosystem ([survey](../../docs/stack-packs.md)) — these skills are first-party,
verified against official docs and the actual 4.0 `broker.conf` defaults.

## What this pack provides

- **Skills**: `pulsar-idioms` (subscriptions, delivery semantics, effectively-once,
  retention/TTL/quota semantics), `pulsar-diagnosis` (backlog forensics, disappearing
  messages, duplicates, storage filling), `pulsar-operations` (tiered storage,
  multi-tenancy policies, monitoring, config pitfalls).
- **MCP (documented, not shipped)**: StreamNative's
  [snmcp](https://github.com/streamnative/streamnative-mcp-server) is vendor-official and
  works with self-hosted Pulsar — install via Homebrew (`snmcp`) or Docker
  (`streamnative/snmcp`) and **always run with `--read-only`** plus a `--features`
  allowlist on client clusters. The exact invocation is pinned during e2e testing before
  shipping a `.mcp.json` here (do not guess flags in client environments).

## Per-project setup

1. `/plugin install de-pulsar@myagency --scope project`
2. Admin access for diagnostics: `pulsar-admin` against the cluster, or snmcp as above.
   Read-only posture per `method-safe-operations`: stats and policies reads; topic
   unsubscribes, policy changes, and offloads are client-approved actions.

Version coverage: semantics verified on 4.0.x LTS; 3.x differences flagged inline in the
skills (metadata store, Key_Shared hash space and blocking behavior).
