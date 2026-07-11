---
name: practice-pii-handling
description: PII and sensitive data handling practice - classification, minimization, masking in evidence and deliverables, data boundaries, modeling implications of erasure rights. Use when a dataset may contain personal or sensitive data, when capturing evidence or samples, or when designing pipelines and models over personal data.
---

# Practice: PII handling

Assume nothing is anonymous until checked. As an external consultant, mishandling one
sample of personal data costs more than the entire engagement is worth.

## Classify early

At discovery, identify which involved datasets contain:

- **Direct identifiers**: names, emails, phone numbers, national IDs, exact addresses,
  payment data
- **Indirect identifiers**: combinations that re-identify (birthdate + zip + gender),
  device IDs, precise geolocation
- **Sensitive categories**: health, financial, biometric, minors — highest bar, client's
  compliance rules apply (GDPR/CCPA/local law is client-specific; record which applies in
  the project overlay)

## Handling rules

1. **Minimize.** Work with aggregates and the fewest columns possible. Do not pull PII
   columns you do not need for the task.
2. **PII never leaves the client boundary.** No personal data in local files, scratch
   notes, tickets, chat context, or anything that leaves their environment.
3. **Evidence is redacted by default.** Sample rows in deliverables and diagnosis notes
   mask or hash identifier columns; row counts and aggregates are almost always enough to
   prove a point. If a raw value is truly needed, one masked example.
4. **Non-production gets masked data.** Never copy production PII into dev/staging for
   testing; use masking, synthesis, or the client's approved anonymized sets.
5. **No new PII copies.** Every additional table holding PII is new attack surface and new
   compliance scope. Temporary objects containing PII (only with permission —
   `method-safe-operations`) are dropped immediately after use.

## Modeling implications

- **Document PII columns** in every model that carries them — downstream consumers inherit
  the obligation.
- **Erasure vs immutability tension**: "immutable raw / append-only" collides with
  right-to-erasure. If subjects can request deletion, the design needs an answer
  (tokenization with a deletable key map, partition-level purge, crypto-shredding) —
  flag this explicitly in any design over personal data.
- **Prefer pseudonymization at ingestion**: keep identifiers in a restricted lookup,
  propagate tokens downstream — analytics rarely needs the real identifier.
- Access to PII layers follows least privilege; serving layers expose the minimum needed.
