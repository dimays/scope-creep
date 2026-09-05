---
name: ledger-016-work-001-split
description: Flagship work-001 split into a four-ticket epic with a real PRD + two ADRs — planned by the scheduled overnight run, reconstructed and pushed by the Owner's session.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 016 — work-001 split (flagship chatbot)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Provenance
The scheduled cloud run fired on time (08:35 UTC) and cold-reconstructed full state,
but had **no GitHub push credential** (git proxy rejected the push) — so per its
instructions it produced a **plan**, committed only in its ephemeral sandbox
(session `cse_0172MLusUpAQLA64JGKdTQyL`). The Owner directed this session to
reconstruct that plan as real artifacts and push them. Nothing here is executed code
— all planning docs are **proposed**, awaiting Owner acceptance.

## Delivered (this push)
- **[[prd-chatbot-extension]]** — the flagship's real spec. (The run's sharp catch:
  `work-001` had been tracing to [[prd-console-explore]], whose v1 excludes agent chat.)
- **[[adr-008]]** — shared conversation primitive (Work Requests v2 + chatbot).
- **[[adr-009]]** — sandboxed live preview + gated merge, **flagged as the first
  capability granting an agent live in-session write access → Owner sign-off required.**
- **work-001 → superseded**, split into **[[work-013]]** (shell), **[[work-014]]**
  (conversation primitive), **[[work-015]]** (live preview, gated), **[[work-016]]**
  (propose→merge, gated).

## Awaiting Owner
Accept/decline [[adr-008]] and — critically — **[[adr-009]]** (agent write access)
before `work-015`/`work-016` are built. `work-013`/`work-014` (shell + backend
primitive) can start without that sign-off.
