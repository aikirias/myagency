# Command: /project:review-data-eng-plan

Run a structured Data Engineering plan review using the `data-eng-plan-review` skill.

## What Claude should do

1. Read the plan or context provided in the message
2. Apply the full checklist from `.claude/skills/data-eng-plan-review/SKILL.md`
3. Identify blockers, warnings, suggestions, and open decisions
4. State assumptions clearly
5. Output a structured review using the defined format

## Expected input

The user will provide one of:
- A written plan document (pasted or in an open file)
- A brief verbal description of the pipeline
- A partial plan with explicit gaps

If input is missing critical sections, ask one clarifying question before proceeding. Do not block — produce the review with the available information and flag what is missing.

## Notes

- Prioritize operational risk over style issues
- Flag missing data quality coverage and backfill strategy explicitly — these are the most commonly skipped sections
- If the plan is for a production pipeline, treat every WARNING as important
