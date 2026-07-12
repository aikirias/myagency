# Test plan

Acceptance test suite for the marketplace. Cases are scenario-driven: each one states a
setup, a prompt (what you say to Claude in a sandbox project), and a verifiable expected
behavior. Execution is deferred until the suite is approved — this document is the
preparation.

## How to run

1. **Sandbox project**: create an empty dir OUTSIDE this repo (e.g. `~/tmp/test-engagement`),
   `git init`, and copy the overlay template
   (`plugins/de-core/skills/method-client-onboarding/templates/overlay-template.md`)
   into its `CLAUDE.md` filled with testbed values (StarRocks localhost:9030, Airflow
   localhost:8080, `DE_PROD_SCHEMAS="db_data_model db_business_model"`). TC-48 instead
   starts from an EMPTY repo and lets the onboarding skill generate it.
2. **Install**: `claude plugin marketplace add <path-to-this-repo>` then install the
   plugins the case needs (`--scope project`).
3. **Testbed** (integration cases only): `make testbed-up` in this repo;
   `./bootstrap-starrocks.sh` in `examples/local-stack/`.
4. Run the case's prompt in a FRESH Claude session in the sandbox; check every item of
   the Expected checklist; record the result in the tracking table below.

Case types: **install** (plugin mechanics), **unit** (prompt-only, no services),
**integration** (needs the testbed).

Rules for executing the suite:

- One case per fresh session unless the case says otherwise (avoids contamination from
  earlier context).
- A case PASSES only if every Expected item holds; partial = FAIL with notes.
- Failures become HUMAN-INTERVENTION items or skill fixes — record which.

## Coverage map

| Area | Cases | File |
| --- | --- | --- |
| Install / marketplace / dependencies | TC-01..05 | [cases/01-install.md](cases/01-install.md) |
| de-core method skills | TC-06..11, TC-48 | [cases/02-core-methods.md](cases/02-core-methods.md) |
| de-core practice skills | TC-12..19 | [cases/03-core-practices.md](cases/03-core-practices.md) |
| Deliverable contracts (e2e, testbed) | TC-20..22 | [cases/04-deliverables.md](cases/04-deliverables.md) |
| Hooks (core + airflow) | TC-23..26 | [cases/05-hooks.md](cases/05-hooks.md) |
| research plugin | TC-27..30 | [cases/06-research.md](cases/06-research.md) |
| Stack packs (wave 1) | TC-31..38 | [cases/07-stack-packs.md](cases/07-stack-packs.md) |
| Stack packs (wave 2: kafka, snowflake, lakehouse, dbt, mysql/mongo, es/redis/rabbitmq, bigquery, databricks) | TC-39..47 | [cases/07-stack-packs.md](cases/07-stack-packs.md) |

## Tracking

| Case | Type | Status | Notes |
| --- | --- | --- | --- |
| TC-01 | install | pending | |
| TC-02 | install | pending | |
| TC-03 | install | pending | |
| TC-04 | install | pending | |
| TC-05 | install | pending | |
| TC-06 | unit | pending | |
| TC-07 | integration | pending | |
| TC-08 | unit | pending | |
| TC-09 | unit | pending | |
| TC-10 | unit | pending | |
| TC-11 | unit | pending | |
| TC-12 | unit | pending | |
| TC-13 | unit | pending | |
| TC-14 | integration | pending | |
| TC-15 | unit | pending | |
| TC-16 | unit | pending | |
| TC-17 | unit | pending | |
| TC-18 | unit | pending | |
| TC-19 | unit | pending | |
| TC-20 | integration | pending | |
| TC-21 | integration | pending | |
| TC-22 | integration | pending | |
| TC-23 | unit | pending | |
| TC-24 | unit | pending | |
| TC-25 | unit | pending | |
| TC-26 | unit | pending | |
| TC-27 | unit | pending | |
| TC-28 | unit | pending | |
| TC-29 | unit | pending | |
| TC-30 | unit | pending | |
| TC-31 | integration | pending | |
| TC-32 | unit | pending | |
| TC-33 | unit | pending | |
| TC-34 | unit | pending | |
| TC-35 | unit | pending | |
| TC-36 | unit | pending | |
| TC-37 | unit | pending | |
| TC-38 | unit | pending | |
| TC-39 | unit | pending | |
| TC-40 | unit | pending | |
| TC-41 | unit | pending | |
| TC-42 | unit | pending | |
| TC-43 | unit | pending | |
| TC-44 | unit | pending | |
| TC-45 | unit | pending | |
| TC-46 | unit | pending | |
| TC-47 | unit | pending | |
| TC-48 | unit | pending | |
