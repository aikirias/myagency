# de-mysql

Thin stack pack for MySQL engagements (MySQL as an OLTP SOURCE you extract from).
General MySQL knowledge (schema, indexing, isolation, online DDL) comes from PlanetScale's
official `mysql` skill ([survey](../../docs/stack-packs.md)) — this pack ships the MCP
wiring and the one delta no vendor covers: MySQL as a CDC/extraction source.

## What this pack provides

- **MCP access** (`.mcp.json`): [benborla/mcp-server-mysql](https://github.com/benborla/mcp-server-mysql)
  — **read-only by default**; writes require explicit `ALLOW_INSERT_OPERATION` /
  `ALLOW_UPDATE_OPERATION` / `ALLOW_DELETE_OPERATION` env vars which this pack does NOT
  set. Never set them on client engagements. Back it with a `SELECT`-only MySQL user —
  the DB grant is the durable guarantee.
  AWS-heavy clients: `uvx awslabs.mysql-mcp-server@latest` (official, also read-only by
  default) is the drop-in alternative with RDS Data API / IAM auth.
- **Skill** `mysql-consulting-notes`: binlog/CDC posture, extraction consistency, and
  type-mapping traps.

## Per-project setup

1. `/plugin install de-mysql@myagency --scope project`.
2. Pull in PlanetScale's official MySQL skill (skill only — their plugin's hosted MCP is
   PlanetScale-cloud-specific, so we do not declare the whole plugin as a dependency):

   ```bash
   npx skills add planetscale/database-skills --skill mysql
   ```

3. Set `MYSQL_HOST/PORT/USER/PASS/DB` in the project environment — never in files. Ask
   for a read-only user and, when one exists, point at a replica (but read the replica-lag
   note in the skill first).

Requires Node.js on the machine running Claude Code.
