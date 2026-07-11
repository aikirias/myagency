---
name: method-delivery
description: Closing method for an engagement - validate at the safe boundary, assemble the package under the matching deliverable contract, state what remains unverified, and hand off. Use when a fix, pipeline, or analysis is ready to be packaged and delivered to the client.
---

# Method: delivery

Work is not done when the fix works — it is done when the client holds a package they can
re-run, audit, and learn from without you in the room.

## Steps

1. **Validate to the safe boundary.** Run the most relevant checks that
   `method-safe-operations` allows in this environment. What could not be validated safely
   is listed explicitly — never silently assumed.
2. **Pick the contract.** Find the `deliverable-*` skill matching the engagement type
   (broken report fix, new pipeline, platform audit, …) and assemble exactly what it
   mandates. If no contract exists for this engagement type, flag it — that is a gap in the
   toolkit, and the package is assembled ad-hoc following the closest contract's spirit.
3. **Apply the client overlay.** Delivery channel, language, and prevention mode come from
   the client project's configuration; if missing, ask rather than assume.
4. **Run the contract's completion checklist** before calling it delivered.
5. **Hand off.** Walk the client through the README top to bottom; every open item,
   assumption, and unverified point is on the table, not in your head.

## Rules

- Deliverables state facts about what was validated and what was not. No "should work".
- Recommendations beyond the engagement scope (improvements spotted during diagnosis) go in
  a clearly separated section — visible, but not mixed with the delivered work.
- The package must survive the channel: whatever the overlay says (repo, wiki, zip), the
  package is self-contained.

## Reflect before closing

Before considering the engagement done, run `method-field-capture`: did we hit a gotcha,
failure pattern, or technique the toolkit didn't already carry? If so, capture it
(generalized and de-identified) as a toolkit candidate — this is how the skills improve
from real work rather than staying doc-derived.
