---
name: method-field-capture
description: Capture reusable lessons from real engagements and route them into the toolkit - generalized, de-identified, promoted on recurrence, never applied silently. Use when a novel gotcha, failure pattern, or technique surfaces during client work, and at engagement close to reflect on what was learned.
---

# Method: field capture

The toolkit's skills are drafted from documentation; their real value comes from field
experience. This is the loop that turns "we just hit something the pack didn't warn us
about" into a durable improvement — without leaking client data and without silently
rewriting the skills.

Fires two ways: opportunistically (something surprising happens mid-engagement) and at
engagement close (hooks into `method-delivery`: "did we learn something reusable?").

## Two boundaries this must respect

1. **Repo boundary**: gotchas are discovered in a CLIENT repo, but the skills live in the
   toolkit (marketplace) repo, installed read-only from cache. You never edit the
   installed pack from inside an engagement. Capture in the client project; promote in the
   toolkit repo.
2. **Confidentiality boundary**: anything destined for a reusable skill must be
   **generalized and de-identified** — no client names, data, schemas, or specifics
   (same discipline as `practice-pii-handling`). If a lesson can't be stated without
   client specifics, it isn't ready to promote.

## Capture (inside the engagement)

When a reusable lesson surfaces:

1. **Generalize it on the spot**: state it as a pattern, not an anecdote — "MVs on an
   eventually-deduped source double-count", not "ACME's summary table was wrong".
2. **Classify recurrence** (the promotion gate):
   - **candidate** — seen once. Real but unproven as a pattern; provisional.
   - **confirmed** — seen in ≥2 independent engagements/contexts. Earns promotion.
   A single striking case can be logged as a candidate, never promoted straight to
   confirmed on one sighting (that's how docs-lore masquerades as field wisdom).
3. **Route it**: which skill would own it? A stack pack (engine gotcha), a de-core
   practice (cross-stack principle), or — if it's a whole missing area — a new skill/pack.
4. **Record it** in the client project's pending file (`HUMAN-INTERVENTION.md` or a
   research candidate note), tagged `toolkit-candidate`, with: the generalized lesson,
   recurrence class, target skill, and a one-line evidence note (de-identified).

## Promote (back in the toolkit repo)

Confirmed candidates are reviewed and proposed as edits to the target skill:

- **Propose, never auto-apply** — the edit goes through the same review discipline as
  everything else (surface it, the owner approves). New confirmed gotchas that change a
  skill land as a `HUMAN-INTERVENTION` item with a Review focus line.
- Mark provenance: a promoted lesson notes it came from field experience (vs the
  doc-derived baseline), so the two are distinguishable.
- If a candidate contradicts existing skill content, that's a conflict — resolve it
  explicitly (the field usually wins over docs, but say so), don't just append.

## Candidate vs confirmed in skill files

Skills may carry a clearly labeled section for **unconfirmed candidates** (doc-derived or
single-sighting) separate from confirmed, field-validated content. This keeps the skill
useful now while being honest about what's proven — and gives the promotion step an
obvious place to move items from.

## Anti-goals

- Don't capture one-offs as if recurring — the recurrence gate exists for a reason.
- Don't let capture become a dumping ground: a lesson that isn't generalized, routed, and
  classified isn't captured, it's a note.
- Don't edit installed packs in client repos — capture there, promote here.
