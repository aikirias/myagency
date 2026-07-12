# Client project overlay — pointer

The canonical template now lives inside the onboarding skill (so it ships with
`de-core` into client repos):

[plugins/de-core/skills/method-client-onboarding/templates/overlay-template.md](../plugins/de-core/skills/method-client-onboarding/templates/overlay-template.md)

Preferred flow: run `method-client-onboarding` in the client repo — it inspects the
repo, interviews for problem/scope (must-do vs can-do vs out-of-scope + deliverable +
acceptance criteria), and generates the filled overlay. Manual copy of the template is
the fallback.
