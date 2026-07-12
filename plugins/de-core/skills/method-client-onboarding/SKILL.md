---
name: method-client-onboarding
description: Client engagement onboarding - inspect the repo, interview for problem and scope, agree must-do vs can-do vs out-of-scope and the deliverable, then generate the complete CLAUDE.md overlay (stack, conventions, language, channel, prevention agreement) plus the day-one access request list. Use at the start of a new engagement, in a new client repo, or when asked to set up or kick off a project.
---

# Client onboarding

Runs ONCE at the start of an engagement. Two outputs, in this order: an **agreed scope**
(approved by the user before any technical work), and a **filled overlay** (the client
repo's `CLAUDE.md` block every de-core skill reads) plus the day-one access list.

## Step 0 — evidence before questions

Inspect before interviewing; never ask what the repo already answers:

- READMEs, docs, existing `CLAUDE.md`/`CLAUDE.local.md`
- Stack fingerprints: `dbt_project.yml`, `dags/`, docker-compose/terraform/helm,
  `requirements*.txt`/`pyproject.toml`, SQL dialect in existing queries, CI configs
- Conventions already in force: naming patterns, migrations tooling, git history style

Pre-fill everything derivable; the interview covers only the gaps.

## Step 1 — problem and scope (the gate)

Interview in this order (echoes `method-discovery`, which goes deeper later):

1. **The problem**: what hurts, who is affected, since when, cadence/deadline, audience
   (C-level vs analyst — it changes every deliverable).
2. **Must do** — the engagement fails without these. Few and concrete.
3. **Can do** — valuable if time/access allows. Explicitly second-class: a can-do never
   displaces a must-do without re-agreement.
4. **Out of scope** — named exclusions. The fence protects both sides.
5. **The deliverable**: map to a contract — `deliverable-broken-report-fix`,
   `deliverable-new-pipeline`, `deliverable-platform-audit` — or define a custom package
   explicitly (what files, what format, delivered where).
6. **Acceptance criteria**: verifiable statements ("report X matches source Y for
   period Z", "pipeline reruns idempotently for any date"), not vibes.

**Approval gate**: read the scope block back; the user approves it BEFORE technical work
starts (same discipline as `method-improvement-plan`'s plan gate). Later scope changes
are re-agreed and recorded in the overlay — never absorbed silently.

## Step 2 — stack, packs, and day-one access

- Confirm detected stacks; propose the matching `de-<stack>` packs and the vendor
  marketplaces their dependencies need (each pack README has the exact commands).
- Compile the **day-one access request list** from the installed packs' READMEs: every
  pack states what to ask for (read-only roles, `SELECT` on system/usage tables,
  monitoring-tagged users, API keys with read scopes). Requesting these on day one is
  the single highest-leverage onboarding act — access latency gates everything.

## Step 3 — conventions, language, channel, prevention

Ask only what Step 0 couldn't derive:

- Deliverable **language** and **delivery channel** (per client — repo folder, PR, wiki).
- **Layer naming** used in THIS repo (Decision 3 house rule: medallion is the
  conceptual vocabulary; dbt repos use staging/intermediate/marts physically).
- **Approval boundaries** (who approves prod DDL, deploys, backfills), deploy/freeze
  windows, data boundary (what may not leave client systems; PII owner).
- **Prevention agreement** (broken-report-fix contract): does the client want
  preventive measures implemented, or recommended only?
- Client git conventions if they bind our PRs.

## Step 4 — generate the overlay

- Fill [templates/overlay-template.md](templates/overlay-template.md) with everything
  gathered. Target: the client repo's `CLAUDE.md`; if one already exists, add the block
  to `CLAUDE.local.md` or merge under an `# Engagement` section — never overwrite
  client content.
- Anything still unknown becomes an `OPEN:` marker inside the overlay AND a line in the
  engagement's `HUMAN-INTERVENTION.md` (with its Review focus) — assumptions are not
  fill material.
- Close by listing: approved scope summary, packs installed, access requests sent, and
  the OPEN items.

## Anti-patterns

- Technical work before the scope gate — diagnosis findings will reshape scope through
  RE-agreement, not replace having one.
- Overlay fields filled with plausible assumptions instead of `OPEN:` markers.
- A can-do quietly promoted to must-do mid-engagement (that is scope drift — re-agree).
- Asking the client for information the repo already contains.
