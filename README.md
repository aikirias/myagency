# myagency — DE consulting toolkit

Personal Claude Code **plugin marketplace** for data engineering consulting. It packages
one consultant's working method, engineering practices, client deliverable contracts, and
per-technology knowledge into plugins that install per client engagement.

Design in one line: **`de-core` carries the stack-agnostic method; stack packs carry only
the per-technology delta; anything the ecosystem already maintains is reused, not
rewritten.**

## Plugins

| Plugin | Type | What it carries |
| --- | --- | --- |
| `de-core` | core (install always) | 22 skills — working method (discovery, diagnosis, safe operations, delivery, improvement plans, field capture), engineering practices (SQL, idempotency, incremental, DQ, backfills, modeling, architecture selection, lifecycle, governance, cost, PII), and 3 client deliverable contracts with templates — plus 4 specialist agents and 3 safety hooks |
| `de-clickhouse` | stack, thin | Official read-only MCP; depends on ClickHouse's vendor skills; consulting gotchas |
| `de-airflow` | stack, thin | Astronomer read-only MCP; depends on `astronomer-data`; consulting notes + DAG hooks |
| `de-postgres` | stack, thin | Postgres MCP Pro (restricted mode); depends on Timescale's `pg`; source-system notes |
| `de-starrocks` | stack, full | First-party idioms / diagnosis / operations (nothing curated exists upstream); official MCP |
| `research` | general | Domain-agnostic investigation method + RES-NNN decision records with implementation tracking |

Pending stack packs (full tier, built on demand): spark, flink, pulsar, mssql — see
[docs/stack-packs.md](docs/stack-packs.md) for the ecosystem survey behind the thin/full split.

## Install in a client engagement

```bash
# once per machine/project
claude plugin marketplace add aikirias/myagency

# always
/plugin install de-core@myagency --scope project

# per stack in use (vendor marketplaces first — dependencies auto-install from them)
claude plugin marketplace add ClickHouse/agent-skills      # if ClickHouse
claude plugin marketplace add astronomer/agents            # if Airflow
claude plugin marketplace add timescale/pg-aiguide         # if PostgreSQL
/plugin install de-clickhouse@myagency --scope project     # etc.

# optional, any project type
/plugin install research@myagency --scope project
```

Then copy [templates/client-project-overlay.md](templates/client-project-overlay.md) into
the client repo's `CLAUDE.md` and fill it in — deliverable language/channel, stack
endpoints, safety boundaries. The skills read their per-client configuration from there.

## Repo layout

```text
├── .claude-plugin/marketplace.json   # the catalog
├── plugins/                          # one directory per plugin
├── docs/
│   ├── DESIGN.md                     # decision log, layering rules, roadmap
│   └── stack-packs.md                # reuse-first ecosystem survey per stack
├── templates/client-project-overlay.md
├── examples/                         # demo/testbed (NOT part of the product)
│   └── local-stack/                  # Airflow + StarRocks + CloudBeaver via docker compose
├── scripts/validate_marketplace.py
└── HUMAN-INTERVENTION.md             # pending review items for the owner
```

## Development

- Read [docs/DESIGN.md](docs/DESIGN.md) first — decision log and the layering rules
  (core stays stack-agnostic; packs particularize, never redefine; reuse-first).
- `make validate` after touching any plugin.
- `make testbed-up` for a local StarRocks/Airflow to exercise pack content end-to-end.
- Pending items for the owner live in [HUMAN-INTERVENTION.md](HUMAN-INTERVENTION.md);
  every item carries a `Review focus:` line.
- The pre-rebuild scaffold is preserved on the `legacy-scaffold` branch.
