# de-kafka

Full stack pack for Apache Kafka engagements (Kafka + Kafka Connect + Debezium CDC).
No existing plugin carries Kafka operational judgment — Confluent's is Cloud
provisioning only ([survey](../../docs/stack-packs.md)) — so this pack is first-party,
verified against Apache Kafka 4.x docs and Debezium 3.6 stable docs.

## Skills

- `kafka-idioms` — durability matrix, EOS reality, consumer semantics, compaction and
  retention, partitioning.
- `kafka-diagnosis` — rebalance loops, lag anomalies, lost messages, duplicates, KRaft
  migration state.
- `kafka-connect-debezium` — Connect error handling and internal topics, Debezium
  snapshot/streaming, the SMT and retention traps.

## MCP

Recommended: [mcp-confluent](https://github.com/confluentinc/mcp-confluent) (official,
MIT, works against **self-hosted** Kafka: minimal config needs only `bootstrap_servers`).

- Install: `npx @confluentinc/mcp-confluent --init-config`, then run with
  `--config ./config.yaml`. Node >= 22.
- **No read-only flag** — the safety posture is tool filtering: run with
  `--allow-tools-file mcp/allow-tools-readonly.txt` ([shipped here](mcp/allow-tools-readonly.txt))
  and verify the surface with `--list-tools` before first use on a client system. Tool
  names should be pinned against the installed server version on first use (same
  protocol as de-pulsar's snmcp), then frozen in the client repo.

Watch item: KIP-1318 (upstream Apache Kafka MCP server) is under discussion — revisit
when it lands.

## Setup

`/plugin install de-kafka@myagency --scope project`. Ask for read-only credentials
(a principal with Describe/Read ACLs, no Write/Alter) — the ACL is the durable
guarantee, not the tool filter.
