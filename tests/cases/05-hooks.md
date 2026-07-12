# Cases: hooks (de-core + de-airflow)

All hook cases run in the sandbox with the relevant plugin installed; the trigger is
asking Claude to WRITE the file (hooks fire PostToolUse on Write|Edit).

### TC-23 — check-sql warns on risky SQL

- **Type**: unit · **Target**: de-core `check-sql.sh`
- **Steps**: ask Claude to create a `.sql` file with a `SELECT *` and a `DELETE FROM t;` (no WHERE), e.g. by copying `tests/fixtures/bad_query.sql`
- **Expected**:
  - [ ] Warnings surface after the write (SELECT *, DELETE without WHERE, TRUNCATE/DROP if present)
  - [ ] Write is NOT blocked (warn-only); Claude reacts to the feedback (fixes or justifies)
  - [ ] Writing a clean `.sql` file produces no warnings; non-SQL files untouched

### TC-24 — check-prod-ddl respects DE_PROD_SCHEMAS

- **Type**: unit · **Target**: de-core `check-prod-ddl.sh`
- **Setup**: `export DE_PROD_SCHEMAS="db_data_model core_dw"` in the sandbox env
- **Steps**: ask Claude to write a migration containing `ALTER TABLE db_data_model.fact_x ADD COLUMN ...` and another file targeting `staging.tmp_y`
- **Expected**:
  - [ ] Warning fires for `db_data_model.*` DDL referencing the approval rule
  - [ ] No warning for the `staging.*` file
  - [ ] With DE_PROD_SCHEMAS unset, defaults (`prod production dw dwh gold mart`) apply

### TC-25 — check-python blocks syntax errors, warns on secrets

- **Type**: unit · **Target**: de-core `check-python.sh`
- **Steps**: (a) ask for a `.py` with a deliberate syntax error (e.g. missing paren — instruct Claude to write it verbatim); (b) a `.py` containing `password = "hunter2secret"`
- **Expected**:
  - [ ] (a) Hook exits 2 → Claude receives blocking feedback and fixes the file
  - [ ] (b) Hardcoded-secret warning appears; write not blocked

### TC-26 — de-airflow check-dag only fires on DAG files

- **Type**: unit · **Target**: de-airflow `check-dag.sh`
- **Steps**: (a) copy `tests/fixtures/blind_append_dag.py` in via Claude; (b) write a plain `.py` utility with `print()` and no airflow imports
- **Expected**:
  - [ ] (a) Three warnings: dynamic `start_date=datetime.now()`, `catchup=True`, `print()` in DAG file
  - [ ] (b) Silent — non-DAG python files are not nagged
