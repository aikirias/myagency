# LikeC4 Guide

## What it is

LikeC4 is an architecture-as-code tool. Architecture is described in a DSL, version-controlled alongside the codebase, and rendered as interactive C4 diagrams.

- Docs: https://likec4.dev/docs
- Install: `make install-likec4`

## File locations

- Architecture files: `architecture/*.likec4`
- Exported static output: `docs/architecture/` (optional, for DRDs or wikis)

## DSL basics

```likec4
specification {
  element actor       // person or external role
  element system      // external system boundary
  element database    // storage
  element pipeline    // data transformation or workflow
  element queue       // event stream or message queue
}

model {
  actor analyst 'Data Analyst'

  system source_crm 'CRM (Salesforce)' {
    description 'Source of customer and opportunity records'
  }

  system data_platform 'Data Platform' {
    database starrocks 'StarRocks' {
      description 'Primary analytical database'
    }
    pipeline airflow 'Airflow' {
      description 'Batch orchestration'
    }
  }

  analyst -> starrocks 'queries'
  source_crm -> airflow 'feeds raw events'
  airflow -> starrocks 'loads transformed data'
}

views {
  view context {
    title "Data Platform — Context (L1)"
    include analyst, source_crm, data_platform
  }

  view containers {
    title "Data Platform — Containers (L2)"
    include data_platform.*
  }
}
```

## C4 level guidelines

| Level | Element types to use | When to use |
|---|---|---|
| L1 Context | `actor`, `system` | Stakeholder communication, DRD overview |
| L2 Containers | `database`, `pipeline`, `queue` | Pipeline design review, source-to-target |
| L3 Components | nested elements inside containers | Deep-dive into a single pipeline |

## Conventions

- Use `snake_case` for element identifiers.
- Every element must have a human-readable label as its second argument.
- Every relationship `->` must include a short label: `airflow -> starrocks 'loads fact_orders'`.
- Never use `include *` in production views — list elements explicitly.
- One `.likec4` file per domain or pipeline family. Avoid one large file.
- Views must have a `title` attribute.

## Medallion flow template

```likec4
model {
  database db_stage 'db_stage' { description 'Raw landing zone' }
  database db_data_model 'db_data_model' { description 'Curated models' }
  database db_business_model 'db_business_model' { description 'Business-facing' }

  db_stage -> db_data_model 'transforms via Airflow'
  db_data_model -> db_business_model 'aggregates and serves'
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
