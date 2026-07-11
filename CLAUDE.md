# myagency — toolkit development guide

This repo IS the product: a Claude Code plugin marketplace for DE consulting
(`de-core` + stack packs + `research`). Working here means authoring/maintaining the
toolkit — client engagement work happens in client repos with these plugins installed.

## Source of truth

- `docs/DESIGN.md` — decision log (#1-9), architecture, layering rules, roadmap. Read it
  before structural changes; record new structural decisions in it.
- `docs/stack-packs.md` — reuse-first survey; which stacks are thin vs full tier and why.
- `HUMAN-INTERVENTION.md` — pending items for Aikirias. Check it at session start for
  inline answers. Every new item MUST end with a `Review focus:` line stating exactly
  what deserves his attention.

## Hard rules

- **`de-core` stays stack-agnostic**: no engine names, vendor SQL, ports, or tool
  specifics in core skills — that content belongs in the matching stack pack.
- **Reuse-first for stacks**: survey existing vendor/community plugins, skills, and MCP
  servers before authoring; where good assets exist, declare them as cross-marketplace
  dependencies and ship only the consulting delta.
- **No empty plugins in `marketplace.json`** — list a plugin only once it has real content.
- **Skills are the only entry point** (no `commands/` — deprecated). Skill dirs are flat,
  prefixed by family: `method-*`, `practice-*`, `deliverable-*` in de-core.
- All framework content in **English**. Conversation with the user in Spanish.
- **Never commit or push without an explicit request** from Aikirias.
- Judgment calls made on his behalf (defaults, thresholds) get a HUMAN-INTERVENTION item.

## Validation

```bash
make validate     # marketplace + plugin structure (manifests, skills frontmatter, hooks, deps)
make testbed-up   # local StarRocks/Airflow stack in examples/local-stack for e2e checks
```

Run `make validate` after touching any plugin. New skills need frontmatter `name` +
`description` (the description is the trigger — write it for matching, not prose).

## Commit conventions

Conventional Commits: `<type>(<scope>): <description>` — imperative, lowercase, no
trailing period. Types: feat, fix, refactor, docs, ops, chore, test, build. Breaking
changes: `!` + `BREAKING CHANGE:` footer.

## Pending cleanup

`.claude/hooks/` + `.claude/settings.json` are the last legacy remnants — they stay until
a session where their PreToolUse hooks are not loaded (deleting them mid-session breaks
Write calls). Remove them + this note in a fresh session; everything else legacy lives on
the `legacy-scaffold` branch.
