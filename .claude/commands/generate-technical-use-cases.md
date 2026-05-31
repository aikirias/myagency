# Command: /project:generate-technical-use-cases

Convert a functional specification into technical use cases and implementation tracks using the `technical-use-case-generation` skill.

## What Claude should do

1. Read the functional specification or requirement in enough detail
2. Identify the data entities, consumers, contracts, and operational expectations involved
3. Break the work into technical use cases and implementation components
4. Map dependencies between use cases
5. Estimate effort at rough-order-of-magnitude level
6. Produce the list of technical use cases with derived implementation tracks

## Expected input

- Functional specification (preferably produced by `/project:discover-requirements`)
- Or a business requirement with resolved definitions: metrics, dates, filters, grain, and consumers

If the input contains ambiguous undefined terms, point that out and ask for clarification before generating output.

## Notes

- The output of this command feeds directly into `/project:refine-ticket` and `/project:assess-priority`
- If the requirement is too vague, redirect to `/project:discover-requirements` first
- Always include data quality, observability, and operational ownership as explicit technical components
