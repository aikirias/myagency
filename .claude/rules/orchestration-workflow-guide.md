# Orchestration Workflow Guide

## Workflow definition

- One workflow definition per file or module unless platform constraints require otherwise
- Workflow identifiers must be stable and descriptive
- Scheduling must be deterministic; never derive it from "now"
- Replay behavior must be intentional and documented
- Add ownership and classification metadata for discoverability

## Retry and timeout boundaries

- Every production workflow must define retry policy explicitly
- Retry delay must avoid hammering recovering upstream systems
- Every long-running step must have a timeout boundary
- Every workflow must have a run-level timeout or equivalent guardrail where supported

## Idempotency and replay

- Every step must be safe to re-run for the same logical interval
- Write patterns must be safe under retry and partial failure
- File outputs should replace or version deterministically, not append blindly
- Replay and backfill behavior must be documented before enabling historical catch-up

## Dependencies and waiting

- Dependency edges must reflect actual data flow, not convenience
- Waiting tasks must define polling interval and timeout explicitly
- Cross-workflow dependencies must document how matching intervals are resolved
- Avoid self-blocking dependency patterns and hidden deadlocks

## Secrets and configuration

- Never hardcode passwords, tokens, or connection strings in workflow code
- Retrieve secrets from approved secret or configuration mechanisms
- Environment-specific configuration must be externalized

## Alerting and ownership

- Failure alerting must be configured for every production workflow
- Time-critical workflows must define SLA or freshness expectations
- Ownership metadata must identify who is responsible for operation and incident response

## Naming

- Step IDs must be descriptive and stable
- Group related steps logically when the platform supports grouping
- Avoid placeholder names like `task1`, `job2`, or `step_a`

## Replay hygiene

- Before enabling automatic replay, confirm the workflow is idempotent
- Reduce concurrency during large reprocessing windows unless there is a documented reason not to
- Validate the first batch or interval before continuing a wide replay
- Document the intended replay strategy in the workflow description or runbook
