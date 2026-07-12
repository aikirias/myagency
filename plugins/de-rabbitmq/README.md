# de-rabbitmq

Thin stack pack for RabbitMQ in data-pipeline engagements (queues feeding pipelines, CDC
buffers). No vendor AI assets exist for RabbitMQ ([survey](../../docs/stack-packs.md)) —
the consulting surface is narrow, so this pack is one skill plus MCP guidance.

## What this pack provides

- **MCP (documented, not shipped as `.mcp.json`)**: the de facto official server is
  [amazon-mq/mcp-server-rabbitmq](https://github.com/amazon-mq/mcp-server-rabbitmq)
  (`uvx amq-mcp-server-rabbitmq@latest`) — **read-only by default**: mutating tools are
  only registered when `--allow-mutative-tools` is passed, which we never do on client
  engagements. Broker connection arguments should be pinned against the current release
  during first use (same protocol as de-pulsar's snmcp) — then freeze the invocation in
  the client repo's `.mcp.json`.
  Inspection alternative: the official `rabbitmqadmin` v2 CLI works read-only against
  the management API with a monitoring-tagged user.
- **Skill** `rabbitmq-consulting-notes`: the assessment gotchas below.

## Per-project setup

1. `/plugin install de-rabbitmq@myagency --scope project`.
2. Ask the client for a management-API user with the `monitoring` tag (read-only) —
   never `administrator` for assessment work.
