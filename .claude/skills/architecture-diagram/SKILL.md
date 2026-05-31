---
name: architecture-diagram
description: Creates or updates LikeC4 architecture diagrams for data pipelines, system integrations, and data flow documentation. Use when designing a new system, reviewing architecture, generating a DRD diagram, or when the user asks to diagram or document architecture as code.
---

When using this skill:

1. Identify the scope: full platform, specific pipeline, or component integration.
2. Choose the C4 level: context (L1 — systems and actors), containers (L2 — services and databases), or components (L3 — internal modules).
3. Read `.claude/rules/likec4-guide.md` — follow the description standard and completeness checklist exactly.
4. If updating an existing diagram, read the current `.likec4` file first. Identify which elements changed, apply only the necessary edits, and state what was added, removed, or modified.
5. Create or update the `.likec4` file in `architecture/`.
6. Run the completeness checklist from `.claude/rules/likec4-guide.md` before closing.
7. Update `catalog-info.yaml` and sync to Backstage — this is mandatory, not optional.
8. **Output the file path explicitly** — this is the handoff artifact for the Data Engineer: `architecture/<file>.likec4`.
9. Suggest `likec4 serve architecture/<file>.likec4` to preview.

## Description quality standard

Never write one-liner descriptions. Each element must contain:

| Element type | Required in description |
|---|---|
| External API / system | URL or endpoint, auth, rate limits, SLA, data provided |
| Internal pipeline / DAG | Task list in order, cron schedule, retry config, idempotency mechanism, key tables |
| Database | Layer (Bronze/Silver/Gold), engine, key type, critical column types, table list, access protocol and port |
| Tool | UI URL, connection details (driver/protocol/port/credentials), who uses it |
| Actor | Role, which layers they access, tools they use |

## Completeness checklist — run before closing

### Elements present
- [ ] All actors who consume or operate the system
- [ ] All external source systems and APIs (every third-party API the platform calls)
- [ ] All orchestration components
- [ ] All storage layers (every medallion tier)
- [ ] All data quality components
- [ ] All developer and analyst tooling

### Description quality
- [ ] Every element has a rich description — no one-liners on pipelines, databases, or external systems
- [ ] Every `->` label describes what flows and how (endpoint path, write pattern, protocol)

### Views
- [ ] L1 Context view exists
- [ ] L2 Containers view exists
- [ ] At least one domain flow view (medallion, pipeline, or integration)

### Backstage sync — mandatory
- [ ] `catalog-info.yaml` updated for all new or changed elements
- [ ] Every external API in the diagram registered as `kind: API` with OpenAPI definition
- [ ] Every pipeline registered as `kind: Component` with `consumesApis` and `dependsOn`
- [ ] Every storage layer registered as `kind: Resource` with `spec.type: database`
- [ ] Every tool registered as `kind: Resource` with `spec.type: tool`
- [ ] `catalog-info.yaml` copied to Backstage container and catalog refresh triggered
- [ ] New entities verified in Backstage catalog before closing

## Backstage sync commands

```bash
# Copy updated catalog to Backstage container
docker cp catalog-info.yaml local-backstage:/workspace/local-backstage/examples/de-pipelines.yaml

# Get guest token
TOKEN=$(curl -s -X POST http://localhost:7007/api/auth/guest/refresh \
  -H "Content-Type: application/json" -d '{}' | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('backstageIdentity',{}).get('token',''))")

# Trigger catalog refresh (replace LOCATION_REF with actual ref)
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  http://localhost:7007/api/catalog/refresh \
  -d '{"entityRef": "location:default/<LOCATION_REF>"}'

# Verify entities are indexed
curl -s -H "Authorization: Bearer $TOKEN" \
  "http://localhost:7007/api/catalog/entities?filter=spec.system=local-data-platform" | \
  python3 -c "import sys,json; [print(e['kind'], e['metadata']['name']) for e in json.load(sys.stdin)]"
```

## Diagram types for this workspace

| Diagram | When to use |
|---|---|
| Context (L1) | Stakeholder communication, DRD overview section |
| Container (L2) | Pipeline design, source-to-target review |
| Medallion flow | Data flow documentation (stage → data_model → business_model) |
| Integration | Single source-to-target pipeline with components |

## Handoff rules

- When producing a diagram as part of a new pipeline delivery, state the file path in the closing summary so the Data Engineer receives it explicitly.
- The diagram must always reflect the actual implemented state — never the original design intent if implementation diverged.
- A diagram with missing Backstage sync is not a completed deliverable.

## After generating

```bash
# Interactive preview (requires Node.js v20+)
likec4 serve architecture/<file>.likec4

# Export static output
likec4 build architecture/<file>.likec4 --output docs/architecture/
```

If the diagram is for a DRD, embed the exported SVG in the design document.
