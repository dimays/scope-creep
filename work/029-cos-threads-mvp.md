---
id: work-029
title: CoS-Threads MVP — unify Chat + Requests onto the conversation primitive
type: feature
status: proposed
priority: high
owner: chief-product-officer
spec: prd-cos-threads
created: 2026-09-05
updated: 2026-09-05
---
Phase 1 of [[prd-cos-threads]] — the "refactor Chat/Requests the moment we start."
**Owner-gated direction:** awaiting acceptance of the Threads IA + a reconciling ADR
(see [[ledger-028-cos-threads-roadmap]] escalations).

- Migrate `requests`/`request_messages` → `conversations`/`conversation_messages`
  (the deferred [[adr-008]] migration), on the shared primitive ([[work-014]]).
- One **Threads** surface replacing the separate Chat tab + Work→Requests section.
- A thread carries an explicit **lifecycle/turn** (`needs-you | working | closed`) —
  the native fix for the [[work-011]] Requests whose-turn bug — and renders
  request-intake outcomes inline as typed cards.
- Triage stays **async in the operator session** (today's [[work-009]] mechanism; no
  new runtime).
- **Depends on:** [[work-025]] (Drizzle single-source) + [[work-026]] (tests for
  `conversation.server.ts`/`requests.server.ts`) — do not migrate the schema blind.

**Acceptance:** Chat + Requests are one Threads surface; a thread shows whose turn it
is and its intake outcomes; the Human-Input Log still reads cleanly over the
consolidated source. See [[prd-cos-threads]].
