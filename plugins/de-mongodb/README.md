# de-mongodb

Thin stack pack for MongoDB engagements (MongoDB as a pipeline SOURCE or sink).
Schema-design/query/Atlas knowledge comes from MongoDB's official plugin
([survey](../../docs/stack-packs.md)) — this pack pins the read-only MCP posture and
ships the pipeline-consulting delta the vendor skills don't cover.

## What this pack provides

- **MCP access** (`.mcp.json`): the official
  [mongodb-mcp-server](https://github.com/mongodb-js/mongodb-mcp-server) pinned to
  **`--readOnly`** (restricts to read/connect/metadata operations). Do NOT remove the
  flag on client engagements; finer filtering is available via
  `MDB_MCP_DISABLED_TOOLS` if the client requires it.
- **Skill** `mongodb-consulting-notes`: change-stream CDC, extraction consistency, and
  sharded-cluster traps.

## Per-project setup

1. Add the vendor marketplace once:

   ```bash
   claude plugin marketplace add mongodb/agent-skills
   ```

2. `/plugin install de-mongodb@myagency --scope project` — auto-installs
   `mongodb@mongodb-plugins` (official skills; note it bundles its own MCP setup skill —
   our `.mcp.json` posture takes precedence on engagements).
3. Set `MDB_MCP_CONNECTION_STRING` (e.g. `mongodb+srv://user:pass@host/db`) in the
   project environment — never in files. Ask for a read-only database user.

Requires Node.js >= 22 on the machine running Claude Code.
