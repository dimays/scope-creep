---
name: ledger-028-cos-threads-roadmap
description: Owner feedback (one CoS-Threads interface replacing Chat + Requests) delegated to the CPO; drafted prd-cos-threads (proposed) + phase tickets work-029–032; roadmap revised. Awaits Owner acceptance + a reconciling ADR.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 028 — CoS-Threads roadmap

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Owner feedback
The Owner doesn't want separate **Chat** and **Requests** windows. He wants **one chat
interface with his Chief of Staff**, organized into discrete **threads** he can open,
follow up, branch, and close — carrying intermediate triggers/outcomes (generated
feature requests, actions, decisions), with the **CoS able to start threads**, and with
**C-suite spin-ups / delegations / confers visible inline**. This is the **primary
human-input loop** he wants. Mature it over phases; refactor Chat/Requests when Threads
work begins; revise outstanding roadmap items accordingly.

## Delegated to the CPO
The CoS delegated the roadmap work to the CPO (a spawned dry-run). The CPO drafted
[[prd-cos-threads]] and the revisions below; the CoS ratified them as **proposed**.

## Recorded (proposed)
- **[[prd-cos-threads]]** — the thread model (lifecycle `open → needs-you|working →
  closed`, followup, branch), how it subsumes Chat + Requests onto the one conversation
  primitive ([[work-014]], [[adr-008]]), its reconciliation with the Human-Input Log
  (Threads is the live read-write front of the same loop the Log renders read-only), and
  a 5-phase rollout.
- **Phase tickets:** [[work-029]] MVP (unify + `requests`→`conversations` migration),
  [[work-030]] CoS-initiated threads + needs-you queue, [[work-031]] inline agent
  activity (ledger-projected), [[work-032]] branching + generated-request cards.
  (Phase 5 live in-app replies fold into the flagship [[work-017]] — not ticketed.)

## Roadmap revisions
- **[[work-010]]** (surface feedback) — likely folded into Threads Phase 1; note added,
  status held at `proposed` pending acceptance.
- **[[work-011]]** (app-state polish) — the Requests whose-turn **bug is superseded** by
  the Threads lifecycle ([[work-029]]); the app-wide loading/interrupted work **stays**.
- **[[prd-work-intake]]** — its Work Requests half is superseded by [[prd-cos-threads]];
  Work History stands.
- **[[work-017]]** (flagship) and **[[work-022]]** (consistency) — **kept**; Threads
  Phase 5 rides 017's runtime, and consolidating input sources slightly helps 022.

## Sequencing (CPO rec, CoS concurs)
1. Finish the **stabilize-first** track ([[work-023]]–027). **[[work-025]]** (schema
   single-source) + **[[work-026]]** (tests for the conversation/requests modules) are
   hard prerequisites for the work-029 migration — do not migrate blind.
2. **Threads MVP ([[work-029]])** next, ahead of the flagship — it's the Owner's stated
   primary loop, is mostly periphery (no new runtime), and retires work-010 + the
   work-011 bug as it lands.
3. **[[work-017]]** remains the flagship; Threads Phase 5 converges onto its runtime.

## Escalate to Owner (decisions before work-029)
1. **Information architecture** — confirm collapsing Chat + Requests into one **Threads**
   surface, and whether it lives top-level (replacing Chat) or under Work.
2. **CoS-initiated threads + notification** — confirm the org may open threads unprompted,
   and that an in-app "needs-you" queue is enough (push/email needs a separate decision
   against the local-first, no-auth posture, [[adr-003]] / INVARIANTS §II).
3. **Outcome boundary** — ratify that every thread outcome stays a **human-gated
   proposal**; Threads never bypasses INVARIANTS §III gates.
4. **A reconciling ADR before work-029** — this reshapes core surfaces (Chat, Requests,
   request-intake) and must reconcile with the Human-Input Log; authorize an ADR
   (superseding the Requests half of [[prd-work-intake]] and ADR-008's Requests-v2 framing).
5. **Priority vs. stabilize-first** — confirm Threads MVP slots **after** work-023–027 and
   **before** the flagship [[work-017]].
