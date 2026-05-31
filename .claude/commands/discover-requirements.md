# Command: /project:discover-requirements

Run the requirements discovery workflow using the `requirements-discovery` skill.

## What Claude should do

1. Read the stakeholder request or initial description
2. Identify what is clear and what is ambiguous
3. Generate discovery questions grouped by category, including impact and urgency
4. If there are already enough answers, produce a functional specification with impact context
5. Explicitly mark the questions that block technical design or prioritization

## Expected input

The user will paste one of the following:
- A vague business request
- An email or Slack message from the stakeholder
- Notes from a requirements meeting
- A partial specification that needs to be completed

## Behavior with incomplete input

If the request has fewer than two sentences of context, ask:
- Which area or team is making the request?
- Is there any deadline or urgency?

Do not block execution because of this — start discovery with the available context.

## Notes

- Never propose technical solutions during discovery
- Business terms must always be defined before closing the process
- Blocking questions must be clearly marked as such
- The output of this skill feeds directly into `/project:generate-technical-use-cases` and `/project:assess-priority`
