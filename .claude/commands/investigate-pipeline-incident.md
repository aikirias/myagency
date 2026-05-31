# Command: /project:investigate-pipeline-incident

Investigate a pipeline incident using the `incident-rca` skill.

## What Claude should do

1. Read the incident description provided
2. Apply the checklist from `.claude/skills/incident-rca/SKILL.md`
3. Scope the impact (tables, date ranges, row counts, consumers)
4. Generate read-only diagnostic queries
5. Propose ranked hypotheses with evidence
6. Recommend safe mitigations ordered from least to most invasive
7. Produce an RCA draft if the root cause is identified or strongly suspected

## Expected input

- Failure signal (alert, complaint, monitoring observation)
- Affected pipeline or table
- When the issue started
- Last known clean run
- Any recent changes (deploy, schema, upstream)

## Notes

- All diagnostic queries must be read-only (SELECT only)
- Any mitigation involving a production write must be explicitly flagged with a confirmation prompt before execution
- Do not assume the root cause — propose hypotheses with evidence
- Assess downstream impact even if the user did not ask for it
- If the incident is still active, prioritize safe mitigation over RCA speed
