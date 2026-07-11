# Fix: <report/query name>

**Client**: <client>
**Date**: <YYYY-MM-DD>
**Author**: <name>
**Status**: Delivered | Pending execution | Executed and verified

## 1. Summary

<One paragraph: what was broken, what was done, current status.>

## 2. Symptom

- **What was observed**: <what the client saw>
- **Since**: <date/time the issue started, if known>
- **Business impact**: <who/what was affected and how>

## 3. Diagnosis and root cause

<Causal chain, from symptom to root cause. Reference the diagnosis queries.>

| Evidence | File | Observed result |
| --- | --- | --- |
| <what it shows> | `sql/01_<...>.sql` | <captured output summary> |

**Root cause**: <one clear sentence.>

## 4. Fix steps

Run in this exact order. Do not skip the validation step.

| Step | File | Command | Expected effect |
| --- | --- | --- | --- |
| 1 | `sql/02_<...>.sql` | <how to run it> | <e.g. updates ~N rows in schema.table> |
| 2 | `sql/03_<...>.sql` | <how to run it> | <...> |

## 5. Validation evidence (before / after)

Captured on <timestamp before> and <timestamp after>.

| Check | Before | After | Expected |
| --- | --- | --- | --- |
| <row count / key total / sample> | <value> | <value> | <value> |

## 6. Data quality tests

| Test | File / query | Result |
| --- | --- | --- |
| Duplicates on <business key> | `sql/NN_validation.sql` | PASS/FAIL + detail |
| Nulls on required fields | ... | ... |
| Reconciliation vs source | ... | ... |

## 7. Rollback plan

<Defined BEFORE executing the fix. Exact steps to undo, or explicit statement that rollback
is impossible and what the mitigation is.>

## 8. Prevention

Mode: implemented | recommended (per client agreement)

| Check / alert | What it catches | Status |
| --- | --- | --- |
| <e.g. freshness check on X> | <this incident, earlier> | implemented in <file> / recommended |

## 9. References

- <docs, tickets, dashboards, source-system documentation>
