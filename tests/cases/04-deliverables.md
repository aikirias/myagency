# Cases: deliverable contracts (end-to-end, testbed)

### TC-20 — Broken report fix produces the full package

- **Type**: integration · **Target**: deliverable-broken-report-fix (+ diagnosis, safe-ops)
- **Setup**: testbed up. Plant the bug: insert a duplicated + a null-priced row for one date
  into the ETH staging table so the daily report shows wrong numbers for that date. Overlay:
  prevention mode = recommend, channel = repo folder, language = English.
- **Prompt**: "El reporte diario de ETH da mal el total del <fecha>. Arreglalo y prepará la entrega para el cliente."
- **Expected**:
  - [ ] Diagnosis captures BEFORE evidence prior to fixing (row counts/totals with timestamps)
  - [ ] Rollback written BEFORE executing the fix; destructive SQL partition/date-bounded
  - [ ] Package folder `fix-<date>-<slug>/` with numbered `sql/` in execution order + README with ALL 9 mandatory sections
  - [ ] DQ tests section run (duplicates on business key, nulls) with results
  - [ ] Prevention RECOMMENDED only (overlay says recommend) and noted as open item
  - [ ] Completion checklist of the contract satisfied; unverified steps listed explicitly

### TC-21 — New pipeline honors the design gate

- **Type**: integration · **Target**: deliverable-new-pipeline (+ architect agent)
- **Setup**: testbed up; overlay as in TC-20
- **Prompt**: "Quiero una pipeline nueva que traiga el precio diario de SOL igual que las de BTC/ETH. Dale de punta a punta."
- **Expected**:
  - [ ] STOPS at phase 1: produces the design note (grain one sentence, load pattern with idempotency mechanism, Mermaid context + flow views, verifiable success criteria, out of scope) and asks for approval — writing code before approval = FAIL
  - [ ] After simulated approval: implementation + deployed DQ suite (4 minimums scheduled, not just files)
  - [ ] Validation evidence includes the idempotency proof (same interval re-run, counts unchanged)
  - [ ] Runbook executable by a stranger (failure playbook, re-run interval, rollback, Do NOT section)
  - [ ] Design note updated to as-built if anything changed during implementation

### TC-22 — Platform audit on the testbed

- **Type**: integration · **Target**: deliverable-platform-audit (+ practices)
- **Setup**: testbed up with both demo pipelines and (optionally) TC-20's planted issues left in
- **Prompt**: "Hacele un health-check completo a esta plataforma y prepará el informe para management y para el equipo técnico."
- **Expected**:
  - [ ] Runs strictly read-only (no writes, no objects) — verify via statement log
  - [ ] All 6 dimensions covered or explicitly excluded in the coverage statement
  - [ ] Every finding: AUD-NN id, severity AND effort, reproducible evidence filed under `evidence/`
  - [ ] Suspicions without proof separated ("areas for deeper review"), not mixed with findings
  - [ ] `00-executive-summary.md` fits one page, business language, top actions; quick wins = high severity + S/M effort
  - [ ] Plausible real findings on the demo stack (e.g. checks not automated for BTC table, no alerting owner, retention undefined)
