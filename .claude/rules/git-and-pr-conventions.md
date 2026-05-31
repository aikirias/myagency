# Git And PR Conventions

Use these conventions when preparing commits, branches, and pull requests.

## Commit messages

Prefer Conventional Commits:

```text
<type>(<optional scope>): <description>
```

Examples:

- `feat(pipelines): add daily revenue load`
- `fix(sql): prevent duplicate rows on retry`
- `docs(readme): clarify local stack workflow`
- `ops(ci): add validation step for .claude surface`

### Allowed commit types

- `feat` for user-facing or consumer-visible additions
- `fix` for bug fixes or correctness fixes
- `refactor` for code restructuring without behavior change
- `perf` for performance-focused refactors
- `style` for formatting-only changes
- `test` for test additions or fixes
- `docs` for documentation-only changes
- `build` for build tooling, dependency, or packaging changes
- `ops` for operational changes such as CI/CD, deployment, infrastructure, monitoring, recovery, or environment automation
- `chore` for repository maintenance tasks that do not fit the categories above

### Commit message rules

- Use the imperative present tense
- Do not capitalize the first letter of the description
- Do not end the description with a period
- Keep the subject concise
- Use an optional scope only when it adds real context
- Do not use issue identifiers as the scope

### Breaking changes

- Mark breaking changes with `!` before the `:`
- Example: `feat(api)!: remove legacy status endpoint`
- If the change is breaking, explain it in the footer with `BREAKING CHANGE:`

### Body and footer

- Use the body to explain motivation and behavior change
- Use the footer for issue references and breaking-change notes
- Example footer references: `Closes #123`, `Fixes DE-456`

## Pull requests

Every non-trivial PR should clearly explain:

- what changed
- why it changed
- operational or consumer impact
- validation performed
- rollout, backfill, or migration notes when applicable

### PR assembly rules

- Keep PRs focused and reasonably small
- Do not mix unrelated refactors with functional changes
- Group related changes in the description
- Call out deleted or renamed files when relevant
- State assumptions explicitly if the PR depends on unclear context

### Validation notes

- Document the checks that were actually run
- If full end-to-end validation was not possible, say exactly what remains unverified and why
- If rollout, migration, or backfill is required, state the safe execution plan clearly

### Data Engineering emphasis

PRs should call out these risks explicitly when present:

- schema or contract changes
- backfill requirements
- idempotency assumptions
- downstream consumer impact
- data quality coverage
- operational ownership, retries, alerts, and rollback expectations
