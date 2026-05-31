---
name: architecture-diagram
description: Creates or updates LikeC4 architecture diagrams for data pipelines, system integrations, and data flow documentation. Use when designing a new system, reviewing architecture, generating a DRD diagram, or when the user asks to diagram or document architecture as code.
---

When using this skill:

1. Identify the scope: full platform, specific pipeline, or component integration.
2. Choose the C4 level: context (L1 — systems and actors), containers (L2 — services and databases), or components (L3 — internal modules).
3. Create or update `.likec4` files following `.claude/rules/likec4-guide.md`.
4. Place files in the `architecture/` directory at the repo root.
5. After generating, suggest `likec4 serve architecture/<file>.likec4` to preview.
6. Use `.claude/rules/engineering-workflow.md` to align the diagram with the surrounding discovery or delivery phase.

## Diagram types for this workspace

| Diagram | When to use |
|---|---|
| Context (L1) | Stakeholder communication, DRD overview section |
| Container (L2) | Pipeline design, source-to-target review |
| Pipeline flow | Medallion layer documentation (stage → data_model → business_model) |
| Integration | Single source-to-target pipeline with components |

## Output format

Generate a valid `.likec4` file. Skeleton:

```likec4
specification {
  element actor
  element system
  element database
  element pipeline
  element queue
}

model {
  // Define elements, then relationships with ->
}

views {
  view index {
    title "Data Platform — Context"
    include *
  }
}
```

Rules:
- Every element must have a human-readable label.
- Replace `include *` with explicit element lists in production diagrams.
- Use `->` with a short label on every relationship: `airflow -> starrocks 'writes fact_orders'`.
- Keep one `.likec4` file per domain or pipeline family; avoid one giant file.

## After generating

- Run `likec4 serve architecture/<file>.likec4` to open the interactive preview.
- Export static output with `likec4 build architecture/<file>.likec4 --output docs/`.
- If the diagram is for a DRD, embed the exported SVG in the design document.
