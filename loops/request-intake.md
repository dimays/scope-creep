---
name: request-intake
description: The Owner's request-intake loop — submit → triage → decide → respond. Feeds ticket-cycle.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-24
  mode: partially-autonomous
---

# Loop: request-intake

How an Owner request becomes a decision. Surfaced in the Console's **Work → Requests**
([[work-009]]); feeds [[ticket-cycle]]. Always terminal.

## Inputs
- A request thread: a title + body (the Owner's ask).

## Steps
1. **Intake** — the Owner submits; recorded as an `open` thread.
2. **Triage** (Chief of Staff) — route to the right executive; the
   [[chief-reality-officer]] sanity-checks the ask (feasible? rests on an unverified
   assumption?); the CPO weighs it against the roadmap.
3. **Decide** — exactly one of: **decline** (with a reason) · **propose** an
   alternative/modification · **accept** → create/modify tickets · **fold** into a
   PRD. New scope (a new PRD/ADR) is decided by the owning executive (the CPO by
   default) and ratified by the CoS ([[decision-rights]] v2) — the Owner already made
   the ask, so the org confirms the framing and writes it back as the "heard" line
   rather than asking again ([[adr-028]]). Only an "Owner holds" class (spend, a
   §III.7 action, credentials, the safety kernel) waits for the Owner.
4. **Respond** — write the outcome back to the thread and set its status
   (`accepted | declined | needs-info | done`). Record in the [[ledger]] if
   consequential.

## Termination
The thread reaches a terminal status (`accepted`/`declined`/`done`) or parks on the
Owner (`needs-info`).

## Notes
- **v1:** triage runs asynchronously in the operator session; responses are written
  back to the thread. **v2** (live in-app agent chat) shares the conversation
  primitive with, and folds into, the flagship [[work-001]].
