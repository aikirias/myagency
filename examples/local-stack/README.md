# Local Stack

A minimal local environment for testing Data Engineering workflows with:

- Apache Airflow standalone
- local StarRocks as a logical single-node setup (`1 FE + 1 BE`)
- CloudBeaver as a web SQL editor
- Backstage for local developer portal exploration

## Services

- `airflow` → `http://localhost:8080`
- `starrocks-fe` → `http://localhost:8030`
- `starrocks-be-http` → `http://localhost:8040`
- `starrocks-mysql` → `localhost:9030`
- `sql-editor` → `http://localhost:8978`
- `backstage-frontend` → `http://localhost:3000`
- `backstage-backend` → `http://localhost:7007`

## Local credentials

- Airflow
  - username: `airflow`
  - password: `airflow`
- StarRocks
  - username: `root`
  - password: empty

## What the StarRocks bootstrap includes

The bootstrap script creates these databases:

- `db_stage` → Bronze / raw
- `db_data_model` → Silver / curated
- `db_business_model` → Gold / modeled
- `db_report` → reporting, logs, and audit

It also loads a few demo tables to explore the stack.

Included demo tables:

- `db_stage.orders_raw`
- `db_stage.btc_price_daily`
- `db_data_model.orders_curated`
- `db_business_model.daily_sales`
- `db_report.pipeline_run_log`

## Commands

```bash
cd local-stack
docker compose up -d --build
docker compose ps
docker compose logs -f airflow
docker compose logs -f backstage
./bootstrap-starrocks.sh
docker compose down
```

## First use

### 1. Start the stack

```bash
cd local-stack
docker compose up -d --build
```

### 2. Bootstrap StarRocks

```bash
./bootstrap-starrocks.sh
```

This creates the demo databases and tables from `starrocks/init/00-bootstrap.sql`.

### 3. Open CloudBeaver

Open:

```text
http://localhost:8978
```

On first access, CloudBeaver will ask you to create the admin user for the web editor.

Then create a new connection with these settings:

- Driver: `MySQL`
- Host: `starrocks`
- Port: `9030`
- User: `root`
- Password: empty

You can open `db_stage`, `db_data_model`, `db_business_model`, or `db_report` directly.

### 4. Open Airflow

Open:

```text
http://localhost:8080
```

Login:

- username: `airflow`
- password: `airflow`

### 5. Open Backstage

Open:

```text
http://localhost:3000
```

Notes:

- The first Backstage startup takes longer than the other services because it bootstraps a fresh local app and installs dependencies into its Docker volume.
- The generated app is stored in the `backstage_workspace` Docker volume, so later restarts are much faster.
- The frontend runs on `3000` and the backend API on `7007`.

## Notes

- This stack is for local exploration, not production.
- StarRocks runs as separate `FE + BE` services to avoid issues with the `allin1` container.
- If you recreate the StarRocks containers, run `./bootstrap-starrocks.sh` again.
- The demo DAGs that should appear in Airflow are `btc_price_daily` and `local_company_heartbeat`.
- This stack also serves as the local backend for the `starrocks` and `airflow` MCPs defined in [`.mcp.json`](/home/akwiek/doc/claudio/data-eng-claude-workspace/.mcp.json:1).
- Backstage is bootstrapped from the official `@backstage/create-app` flow inside the container on first run and uses its default local-development setup.
