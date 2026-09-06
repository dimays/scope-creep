---
name: ledger-032-cos-threads-accepted
description: Owner accepted the CoS-Threads direction (2026-09-06) and resolved the five escalations from ledger-028 — top-level Threads nav replacing Chat, ADR-first sequencing (adr-012 authored), outcomes stay human-gated proposals, CoS-initiated threads + in-app needs-you queue approved, Threads MVP slotted before the flagship. prd-cos-threads → accepted; work-029 → active.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 032 — CoS-Threads accepted (escalations resolved)

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff (Owner-directed)

The Owner resumed in the `scope-creep` control-plane repo, validated the Human-Input
loop end-to-end (backfill of the prior `datamays` session is complete; the live
`UserPromptSubmit` hook is capturing this session and the Console renders it — see
[[adr-011]]), then directed us to start the Threads work. The five decisions
[[ledger-028-cos-threads-roadmap]] escalated are now resolved.

## Resolved escalations
1. **Information architecture — accepted.** Unify Chat + Requests into **one Threads
   surface, top-level, replacing the Chat tab** (Requests folds in). Not nested under
   Work. Recorded in [[adr-012]] (decision 2).
2. **CoS-initiated threads + notification — approved (Phase 2).** The org may open a
   thread / post a followup when it needs the Owner; an in-app **"needs-you" queue** is
   sufficient for now. Push/email stays out (a separate decision against the local-first,
   no-auth posture, [[adr-003]] / INVARIANTS §II). Ticketed as [[work-030]] — not part of
   the MVP.
3. **Outcome boundary — ratified.** Every thread outcome stays a **human-gated
   proposal**; Threads never bypasses INVARIANTS §III gates. Recorded in [[adr-012]]
   (decision 5).
4. **Reconciling ADR — authored first.** The Owner chose ADR-first sequencing.
   [[adr-012]] is written and accepted; it supersedes [[adr-008]]'s Requests-v2 framing
   and the Work Requests half of [[prd-work-intake]] (Work History stands).
5. **Priority vs. stabilize-first — confirmed.** The stabilize track ([[work-023]]–028)
   is **done**, so the [[work-025]]/[[work-026]] prerequisites for the migration are met.
   Threads MVP ([[work-029]]) slots **now**, ahead of the flagship [[work-017]]; Phase 5
   (live in-app replies) converges onto 017's runtime later.

## State changes
- **[[prd-cos-threads]]** → `accepted` (v1.0.0).
- **[[work-029]]** → `active`; [[work-030]]/[[work-031]]/[[work-032]] remain `proposed`
  (future phases).
- **[[adr-012]]** recorded (`accepted`).

## Next
Build [[work-029]] in the Console (`scope-creep-console`) on a branch, behind a gated
PR: migrate `requests`→`conversations`, stand up the top-level Threads surface with an
explicit lifecycle/turn, render intake outcomes inline, and re-point the Human-Input Log
at the single consolidated owner-message source. Triage stays **async in the operator
session** (today's [[work-009]] mechanism; no new runtime).
