---
id: work-076
title: Suite-wide feedback aggregation architecture (proposed ADR)
type: chore
status: proposed
priority: low
owner: cto
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The architecture deep-dive from [[prd-end-user-feedback-at-scale]]. [[work-074]] and
[[work-075]] both need to **read across per-system stores** ([[adr-024]]: one DB per system).
This ticket's deliverable is a **`proposed` ADR** deciding the aggregation shape **before**
either builds on a guessed one.

**The question to decide:** how does suite-wide triage read many isolated stores **without**
breaching isolation or the singleton posture? Candidate shapes to weigh:
- a **read-only suite index** regenerated from each store (favored by [[doc-standards]] §2 —
  generated, deterministic), vs
- **federated read-time queries** across stores.

**Hard constraints (state them in the ADR):** no cross-app **write** reach and no shared
multi-app DB ([[invariants]] §9, the exact rule [[adr-024]] enforces); single-user, no tenancy
or auth surface ([[invariants]] §II); the default datastore is never production. Any hosted
instance / spend stays **Owner-gated** ([[adr-024]] activation).

**Acceptance:** an ADR authored at `status: proposed` (never self-accepted — [[invariants]]
§I.4 / core-gated) recommending one shape with tradeoffs as a table, unblocking [[work-074]]
and [[work-075]]. This ticket **writes a decision, not code**.

**Trigger:** **T1** (the 2nd app ships) — authored just-in-time, ahead of Phase 2 build.
Stays `proposed` until then.
