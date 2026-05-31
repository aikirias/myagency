---
name: data-quality-review
description: Designs or reviews data quality checks for datasets and pipelines. Use when adding quality checks, validating coverage, investigating false positives, or when the user asks to review or generate data quality checks.
---

When using this skill:

1. Read the dataset, pipeline, SLA, uniqueness definition, and any existing checks.
2. Map coverage across the core categories:
   - freshness
   - volume or drift
   - duplicates
   - nulls on critical fields
   - source-to-target reconciliation
   - business-rule validation
3. Require a threshold, severity, owner, and alert path for each meaningful check.
4. Generate missing checks when needed.
5. Flag checks that are too loose, too strict, noisy, or operationally unclear.

Prefer checks that are:

- actionable
- calibrated to the SLA
- easy to operate
- specific to the dataset grain and business rules

For detailed standards, use:

- `.claude/rules/data-quality-standards.md`
- `.claude/rules/data-engineering-principles.md`

Output format:

```text
## Data Quality Review: [dataset_name]

### Coverage Summary
- Freshness: ...
- Volume: ...

### Findings
[BLOCKER] ...
[WARNING] ...
[SUGGESTION] ...

### Generated Checks
SQL:
-- check here
```
