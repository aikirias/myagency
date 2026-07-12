# Cases: install, marketplace, dependencies

### TC-01 — Marketplace structure validates

- **Type**: install · **Target**: marketplace.json + all plugins
- **Setup**: this repo
- **Steps**: `make validate`
- **Expected**:
  - [ ] Exit 0, all plugins listed, no structural errors

### TC-02 — Core install and namespacing

- **Type**: install · **Target**: de-core
- **Setup**: fresh sandbox project
- **Steps**: `claude plugin marketplace add <repo-path>`; `/plugin install de-core@myagency --scope project`; start a session
- **Expected**:
  - [ ] Install succeeds; skills appear namespaced (`/de-core:method-diagnosis`, ...)
  - [ ] All 22 skills discoverable; 4 agents available as subagent types
  - [ ] de-core hooks fire on a test Write (see TC-23)

### TC-03 — Dependency left unresolved without vendor marketplace

- **Type**: install · **Target**: de-airflow cross-marketplace dependency
- **Setup**: sandbox WITHOUT `astronomer` marketplace added
- **Steps**: `/plugin install de-airflow@myagency`; inspect `/plugin`
- **Expected**:
  - [ ] de-airflow installs; dependency `astronomer-data@astronomer` shows unresolved (no crash)
  - [ ] After `claude plugin marketplace add astronomer/agents` + re-install/update, dependency resolves and `astronomer-data` is installed

### TC-04 — Dependency auto-install when marketplace present

- **Type**: install · **Target**: de-clickhouse dependencies
- **Setup**: sandbox with `claude plugin marketplace add ClickHouse/agent-skills` done first
- **Steps**: `/plugin install de-clickhouse@myagency`
- **Expected**:
  - [ ] `clickhouse-best-practices` and `clickhouse-architecture-advisor` auto-install as dependencies
  - [ ] ClickHouse MCP server appears configured (read-only defaults; no write env flags set)

### TC-05 — research plugin standalone (non-data project)

- **Type**: install · **Target**: research plugin isolation
- **Setup**: sandbox that is NOT a data project (e.g. a web app repo), only `research` installed
- **Steps**: `/plugin install research@myagency`; ask: "help me decide between two logging libraries for this app"
- **Expected**:
  - [ ] `investigate` triggers without any de-core reference errors
  - [ ] Constraints phase reads THIS project's context (not DE practices)
  - [ ] RES record + INDEX created in `research/`
