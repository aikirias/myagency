# Plane Integration

The team uses a local Plane instance as the ticketing system. When creating or updating tickets, use the Plane REST API.

## Connection details

- **Base URL**: `http://localhost:8090/api/v1`
- **Auth**: `X-Api-Key: $PLANE_TOKEN` header
- **Workspace**: `paramount`
- **Project**: `DE Pipelines` — ID `0328fdd9-7382-46b8-8044-ef282c846456`
- **UI**: http://localhost:8090/paramount/projects/0328fdd9-7382-46b8-8044-ef282c846456/issues/

## State IDs

| State | ID |
|---|---|
| Backlog | `f5ff9f14-be38-4d11-b2b1-c9d94fcbad61` |
| Todo | `c89a2a8a-0edc-43ff-be90-42ecb5ab08a4` |
| In Progress | `fa2be486-e60b-44f3-9ad2-28dd961cbd87` |
| Done | `44bb9ac4-3639-43db-ab08-29a4f2412479` |
| Cancelled | `2b054a9e-dbe6-4e60-9d1f-1ed15d74fc0a` |

## Priority values

`urgent` | `high` | `medium` | `low` | `none`

## When to create issues

Create a Plane issue whenever:
- A new pipeline, table, or data quality task is defined
- A backfill is planned
- An incident requires tracking
- A technical ticket is generated via `/project:generate-technical-ticket`

## Create issue

```bash
curl -s -X POST \
  "http://localhost:8090/api/v1/workspaces/paramount/projects/0328fdd9-7382-46b8-8044-ef282c846456/issues/" \
  -H "X-Api-Key: $PLANE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "<title>",
    "description_html": "<p>...</p>",
    "state": "<state_id>",
    "priority": "<priority>"
  }'
```

## Update issue

```bash
curl -s -X PATCH \
  "http://localhost:8090/api/v1/workspaces/paramount/projects/0328fdd9-7382-46b8-8044-ef282c846456/issues/<issue_id>/" \
  -H "X-Api-Key: $PLANE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"state": "<new_state_id>"}'
```

## Add comment to issue

```bash
curl -s -X POST \
  "http://localhost:8090/api/v1/workspaces/paramount/projects/0328fdd9-7382-46b8-8044-ef282c846456/issues/<issue_id>/comments/" \
  -H "X-Api-Key: $PLANE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"comment_html": "<p>...</p>"}'
```

## Token

The API token is stored in the `PLANE_TOKEN` environment variable. Never hardcode it in files.
For local work in this repo, keep it in the root `.env` file and load it into the shell before starting Claude if needed.
