# LikeC4 Guide

## What it is

LikeC4 is an architecture-as-code tool. Architecture is described in a DSL, version-controlled alongside the codebase, and rendered as interactive C4 diagrams.

- Docs: https://likec4.dev/docs
- Install: `make install-likec4`

## File locations

- Architecture files: `architecture/*.likec4`
- Exported static output: `docs/architecture/` (optional, for DRDs or wikis)
- Backstage catalog: `catalog-info.yaml` at repo root — must be kept in sync with every diagram change

## Element types

Declare all types you use in `specification {}`. Available types:

```likec4
specification {
  element actor       // person or external role
  element system      // external system or platform boundary
  element database    // storage layer
  element pipeline    // workflow, DAG, or transformation
  element queue       // event stream or message queue
  element tool        // developer or analyst tooling (SQL editors, portals)
}
```

## Description standard — required content per element type

Every element must have a `description` field. One-line descriptions are not acceptable for production diagrams. The required content by type:

### `actor`
- Role and responsibilities
- Which systems or layers they interact with
- Tools they use to access the platform

### `system` (external)
- Technology and version if known
- Base URL or endpoint pattern
- Authentication requirements (or explicit "no auth required")
- Rate limits or SLA (or explicit "no SLA")
- What data it provides: fields, format, granularity

### `system` (internal / platform boundary)
- Purpose of the boundary
- What it contains
- Access URLs and ports

### `pipeline`
- DAG or workflow identifier
- Ordered task list: `task_a → task_b → task_c`
- Schedule or trigger (cron expression + timezone)
- Retry config: retries, retry_delay, execution_timeout
- Idempotency mechanism (UNIQUE KEY, delete+insert, upsert)
- Key input and output tables

### `database`
- Medallion layer (Bronze / Silver / Gold) or equivalent
- Storage engine and version
- Key strategy and type (UNIQUE KEY, DUPLICATE KEY, PRIMARY KEY)
- Column types for critical fields (e.g. DECIMAL precision)
- Table list
- Access protocol and port
- Replication factor

### `tool`
- UI URL and port
- What it connects to and how (driver, protocol, port, credentials)
- Who uses it and for what purpose

### `queue`
- Technology and version
- Topic or stream name
- Schema or event format
- Consumer groups and DLQ strategy

## Relationship label standard

Every `->` must carry a label that describes:
- **What flows**: data type, event, or action
- **How**: protocol, method, or mechanism when not obvious

```likec4
// Good
coingecko -> dag_btc 'GET /simple/price?ids=bitcoin (price, market_cap, vol)'
airflow -> dag_btc 'schedules and retries (cron: 0 6 * * *)'
dag_btc -> db_stage 'upserts btc_price_daily (UNIQUE KEY on price_date)'

// Bad
coingecko -> dag_btc 'data'
airflow -> dag_btc 'triggers'
dag_btc -> db_stage 'writes'
```

## Completeness checklist

A diagram is not complete unless all of the following are present:

### Elements
- [ ] All actors who consume or operate the system
- [ ] All external source systems and APIs (including third-party APIs the platform calls)
- [ ] All orchestration tools (Airflow, etc.)
- [ ] All storage layers (every database tier that exists)
- [ ] All data quality components
- [ ] All developer and analyst tooling (SQL editors, developer portals)
- [ ] All queues or event streams if the system uses them

### Descriptions
- [ ] Every element has a rich description following the standard above
- [ ] No one-liner descriptions on pipelines, databases, or external systems

### Relationships
- [ ] Every `->` has a label describing what flows and how
- [ ] External API calls include the endpoint path and key parameters
- [ ] Storage writes include the write pattern (upsert, insert, replace)

### Views
- [ ] L1 Context view (actors + external systems + platform boundary)
- [ ] L2 Containers view (all internal components + external dependencies + actors)
- [ ] At least one domain flow view (medallion flow, pipeline flow, or integration view)

### Backstage sync
- [ ] `catalog-info.yaml` updated to match all elements in the diagram
- [ ] Every external API in the diagram is registered as `kind: API` in `catalog-info.yaml`
- [ ] Every pipeline is registered as `kind: Component` with `consumesApis` and `dependsOn`
- [ ] Every storage layer is registered as `kind: Resource`
- [ ] Every tool is registered as `kind: Resource` with `spec.type: tool`
- [ ] Updated `catalog-info.yaml` copied to Backstage container and catalog refresh triggered

## Backstage catalog mapping

| LikeC4 element type | Backstage kind | `spec.type` |
|---|---|---|
| `actor` | no entity needed (unless it's a team) | — |
| `system` (external API) | `API` | `rest` / `graphql` / `grpc` |
| `system` (internal platform) | `System` | — |
| `pipeline` | `Component` | `pipeline` |
| `database` | `Resource` | `database` |
| `tool` | `Resource` | `tool` |
| `queue` | `Resource` | `queue` |

Pipeline components must declare:
- `consumesApis` for every external API they call
- `dependsOn` for every storage resource they read from or write to

## C4 level guidelines

| Level | Element types | When to use |
|---|---|---|
| L1 Context | `actor`, `system` | Stakeholder communication, DRD overview |
| L2 Containers | `database`, `pipeline`, `queue`, `tool` | Pipeline design review, source-to-target |
| L3 Components | nested elements inside containers | Deep-dive into a single pipeline or service |

## DSL conventions

- Use `snake_case` for element identifiers
- Every element must have a human-readable label as its second argument
- Never use `include *` in production views — list elements explicitly
- One `.likec4` file per domain or pipeline family — do not create one giant file
- Every view must have a `title` attribute

## Medallion flow template

```likec4
specification {
  element actor
  element system
  element database
  element pipeline
  element tool
}

model {
  actor analyst 'Data Analyst' {
    description 'Queries curated and serving layer datasets via CloudBeaver.'
  }

  system source_api 'Source API' {
    description 'External REST API. Base URL: https://api.example.com. No auth required. No SLA. Returns daily snapshots of X.'
  }

  system data_platform 'Data Platform' {
    description 'Batch pipeline stack. Airflow for orchestration, StarRocks for storage.'

    pipeline dag_load 'load_daily' {
      description 'Fetches source_api daily → upserts db_stage.raw_table (UNIQUE KEY) → casts and loads db_data_model.fact_table → validates row count. Schedule: 0 6 * * * UTC. Retries: 3.'
    }

    database db_stage 'db_stage (Bronze)' {
      description 'Raw landing zone. UNIQUE KEY tables. Source field names and DOUBLE types preserved. Tables: raw_table. MySQL protocol port 9030.'
    }

    database db_data_model 'db_data_model (Silver)' {
      description 'Curated model layer. Explicit DECIMAL types, UNIQUE KEY deduplication. Tables: fact_table. MySQL protocol port 9030.'
    }

    database db_business_model 'db_business_model (Gold)' {
      description 'Serving layer. Business-facing aggregates. Only consumes from db_data_model. MySQL protocol port 9030.'
    }
  }

  tool cloudbeaver 'CloudBeaver' {
    description 'Web SQL editor. UI: http://localhost:8978. MySQL driver, port 9030.'
  }

  source_api -> dag_load 'GET /endpoint (field_a, field_b, field_c)'
  dag_load -> db_stage 'upserts raw_table (UNIQUE KEY on business_date)'
  dag_load -> db_data_model 'loads fact_table (DECIMAL casts)'
  db_stage -> db_data_model 'promoted by DAG transform step'
  db_data_model -> db_business_model 'aggregated by serving pipeline'
  analyst -> cloudbeaver 'writes and executes SQL'
  cloudbeaver -> db_data_model 'MySQL protocol port 9030'
}

views {
  view context {
    title "Data Platform — Context (L1)"
    include analyst, source_api, data_platform, cloudbeaver
  }

  view containers {
    title "Data Platform — Containers (L2)"
    include
      analyst,
      source_api,
      data_platform,
      data_platform.dag_load,
      data_platform.db_stage,
      data_platform.db_data_model,
      data_platform.db_business_model,
      cloudbeaver
  }

  view medallion_flow {
    title "Medallion Data Flow — Stage → Curated → Serving"
    include
      source_api,
      data_platform.dag_load,
      data_platform.db_stage,
      data_platform.db_data_model,
      data_platform.db_business_model,
      analyst,
      cloudbeaver
  }
}
```

## CLI commands

```bash
# Interactive preview (hot-reload)
likec4 serve architecture/platform.likec4

# Build static output
likec4 build architecture/platform.likec4 --output docs/architecture/

# Check DSL for errors
likec4 validate architecture/platform.likec4
```

## Post-generation checklist

After creating or updating any `.likec4` file, always complete:

1. Run completeness checklist above — do not skip
2. Update `catalog-info.yaml` to reflect all changes
3. Copy updated `catalog-info.yaml` to Backstage: `docker cp catalog-info.yaml local-backstage:/workspace/local-backstage/examples/de-pipelines.yaml`
4. Trigger catalog refresh via Backstage API or restart
5. Verify all new entities appear in the catalog before closing the task
