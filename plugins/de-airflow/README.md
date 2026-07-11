# de-airflow

Thin stack pack for Airflow engagements. General Airflow knowledge comes from Astronomer's
vendor-maintained plugin ([survey](../../docs/stack-packs.md)) — this pack ships
connectivity, pointers, the consulting delta, and DAG-file safety hooks.

## What this pack provides

- **MCP access** (`.mcp.json`): Astronomer's `astro-airflow-mcp` (PyPI; auto-detects
  Airflow 2.x/3.x). **`AF_READ_ONLY` defaults to `true` here** — keep it that way on
  client engagements; triggering/pausing DAGs is the client's action to approve
  (`method-safe-operations` rule 7). Token auth alternative: set `AIRFLOW_AUTH_TOKEN`
  instead of user/password in the project env.
- **Skill** `airflow-consulting-notes`: engagement gotchas mapped to the de-core method.
- **Hooks**: `check-dag.sh` — warns on the classic DAG-file mistakes (dynamic
  `start_date`, `catchup=True`, `print()` in DAG files) after Write/Edit.

## Per-project setup

1. Add the vendor marketplace once (a formal dependency — see below — cannot auto-add
   marketplaces, only auto-install plugins from added ones):

   ```bash
   claude plugin marketplace add astronomer/agents
   ```

2. `/plugin install de-airflow@myagency --scope project` — this **auto-installs
   `astronomer-data@astronomer`** (~30 vendor-maintained skills + their MCP) as a declared
   dependency. If you skipped step 1, the dependency shows as unresolved in `/plugin`
   until the marketplace is added.
3. Set in the project environment: `AIRFLOW_API_URL`, `AIRFLOW_USERNAME`/`AIRFLOW_PASSWORD`
   (or `AIRFLOW_AUTH_TOKEN`). Leave `AF_READ_ONLY` unset (defaults to true).

Requires `uv` (Python) on the machine running Claude Code.
