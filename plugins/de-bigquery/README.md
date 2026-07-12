# de-bigquery

Thin stack pack for BigQuery engagements. Query/analytics mechanics come from Google's
official plugin ([survey](../../docs/stack-packs.md)) — this pack ships the enforced
read-only + cost-capped MCP posture (which the vendor prebuilt lacks) and the consulting
delta around the bytes-scanned cost model.

## What this pack provides

- **MCP posture** ([mcp/tools.yaml](mcp/tools.yaml)): a custom config for
  [MCP Toolbox](https://github.com/googleapis/mcp-toolbox) with `writeMode: blocked`
  (SELECT-only) and an `allowedDatasets` scope hook. The vendor `--prebuilt bigquery`
  config has **no read-only switch** — never use it bare on client engagements.
- **Skill** `bigquery-consulting-notes`: the cost model and pruning traps.

## Per-project setup

1. `/plugin install de-bigquery@myagency --scope project` — auto-installs
   `bigquery-data-analytics@claude-plugins-official` (Google's official skills; the
   official directory is normally already added).
2. Install the Toolbox binary (single Go binary, see the mcp-toolbox releases page),
   then register the MCP in the client repo:

   ```json
   {
     "bigquery": {
       "command": "/path/to/toolbox",
       "args": ["--tools-file", "<plugin>/mcp/tools.yaml", "--stdio"],
       "env": {
         "BIGQUERY_PROJECT": "${BIGQUERY_PROJECT}",
         "BIGQUERY_LOCATION": "${BIGQUERY_LOCATION}"
       }
     }
   }
   ```

3. Cost guardrail: also export `BIGQUERY_MAXIMUM_BYTES_BILLED` (the Toolbox default of
   0 = unlimited) — pick a per-query cap with the client (e.g. `1000000000000` = 1TB)
   and treat raising it as a decision, not a reflex.
4. IAM: ask for `roles/bigquery.dataViewer` + `roles/bigquery.jobUser` scoped to the
   engagement datasets — the IAM grant is the durable guarantee.
