# Cases: research plugin

### TC-27 — Full investigation produces a compliant RES record

- **Type**: unit · **Target**: research investigate
- **Setup**: sandbox with research + de-core; overlay declares stack + a couple of binding conventions
- **Prompt**: "Investigá qué herramienta de CDC nos conviene para replicar Postgres hacia el warehouse en este proyecto."
- **Expected**:
  - [ ] Frames FIRST: decision question, success criteria, constraints table citing sources (overlay, de-core practices) — before any search
  - [ ] ≥2 real alternatives, each with "how it would be implemented HERE" and in-context pros/cons
  - [ ] References annotated (which claim, tier, access date); important claims version-flagged
  - [ ] `research/RES-001-*.md` created with TL;DR at top + registered in INDEX.md
  - [ ] Conversation ends with the summary (alternatives, choice, why, links)

### TC-28 — Direct conflict escalates instead of self-resolving

- **Type**: unit · **Target**: research investigate — blocking escalation gate
- **Setup**: sandbox whose overlay states a hard decision that clashes with mainstream guidance (e.g. "this platform is batch-only; no streaming components allowed")
- **Prompt**: "Investigá la mejor forma de alimentar el tablero de fraude que el cliente quiere con latencia de segundos."
- **Expected**:
  - [ ] Detects the frontal conflict (batch-only constraint vs sub-minute requirement)
  - [ ] Does NOT conclude in either direction — presents the decision package (constraint + source, opposing evidence + tier, stakes both ways, options incl. scoped exception, labeled recommendation)
  - [ ] Record stays in-progress with the Escalations block; resolution recorded verbatim after the user answers

### TC-29 — Review pass detects every planted problem

- **Type**: unit · **Target**: research review
- **Setup**: sandbox; copy `tests/fixtures/stale-research/` to `research/`
- **Prompt**: "Hacé una pasada de mantenimiento sobre research/."
- **Expected** (5 planted problems, all found):
  - [ ] RES-004 unresolved escalation surfaced FIRST
  - [ ] RES-001 stale in-progress (no journal since March) flagged
  - [ ] RES-002 concluded >90d unimplemented flagged
  - [ ] RES-002 vs RES-003 contradiction without supersede flagged
  - [ ] RES-005 missing from INDEX caught (reconciliation)
  - [ ] Mechanical fixes applied to INDEX; meaning-changing status changes only PROPOSED, grouped by the human decision needed

### TC-30 — No real alternatives → labeled a verification

- **Type**: unit · **Target**: research investigate — honesty rule
- **Prompt**: "Investigá si la librería estándar del lenguaje soporta X" (something with a single factual answer)
- **Expected**:
  - [ ] Labels the work a VERIFICATION, not an investigation; no forced fake alternatives
  - [ ] Still records it (labeled) if worth keeping, with references
