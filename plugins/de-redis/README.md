# de-redis

Thin stack pack for Redis in data-pipeline engagements (cache, feature store, dedup
store, occasionally a queue that shouldn't be one). Data-structure/search/clustering
knowledge comes from Redis Inc's official plugin ([survey](../../docs/stack-packs.md)) —
this pack ships the read-only posture the official MCP lacks, plus the pipeline delta.

## What this pack provides

- **MCP access** (`.mcp.json`): the official [redis/mcp-redis](https://github.com/redis/mcp-redis)
  server. **It has NO read-only flag** — read-only posture comes from the connection
  user's ACL, which is therefore MANDATORY on client engagements:

  ```text
  ACL SETUSER de_readonly on >SOMEPASSWORD ~* +@read +ping +info -@write -@dangerous
  ```

  Then set `REDIS_URL=redis://de_readonly:SOMEPASSWORD@host:6379/0`. Never connect the
  MCP as `default`.
- **Skill** `redis-consulting-notes`: persistence/eviction reality, pipeline idioms
  (dedup store), and the anti-patterns.

## Per-project setup

1. Add the vendor marketplace once:

   ```bash
   claude plugin marketplace add redis/agent-skills
   ```

2. `/plugin install de-redis@myagency --scope project` — auto-installs
   `redis-development@redis` (official 8-skill plugin).
3. Ask the client to create the read-only ACL user above; set `REDIS_URL` in the project
   environment — never in files.

Requires `uv` (Python) on the machine running Claude Code.
