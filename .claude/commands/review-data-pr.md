# Command: /project:review-data-pr

Perform a full Data Engineering PR review using the `data-pr-review` skill.

## What Claude should do

1. Read the PR description and all changed files provided
2. Apply the checklist from `.claude/skills/data-pr-review/SKILL.md`
3. Review each file type: SQL, workflow code, DDL, config, docs
4. Assess data quality coverage, backfill requirements, and downstream impact
5. Produce blockers, warnings, suggestions, and a merge verdict

## Expected input

- PR title and description
- Changed files (pasted, open, or listed)
- Target environment (dev / staging / prod)

If the target environment is not specified, assume prod and apply the strictest review standard.

## Notes

- A PR with no data quality checks on a new production table is a WARNING minimum
- A PR with DDL breaking changes and no migration plan is a BLOCKER
- Do not flag code style issues as blockers — only data correctness and operational risk qualify
- If the PR description is absent, flag it as a WARNING (not BLOCKER) and proceed with the review
