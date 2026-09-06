---
id: work-010
title: Surface submitted feedback with lifecycle status
type: feature
status: superseded
priority: medium
owner: chief-product-officer
spec: prd-console-explore
created: 2026-09-04
updated: 2026-09-06
---
Show feedback submitted via the ext-feedback extension somewhere the Owner can see it
(CPO's call on placement — a Feedback view, or alongside Requests threads), each with
a **lifecycle status** connecting the feedback to the action taken — e.g. `submitted`
→ `in backlog` → `built` / `declined`.

**Acceptance:** submitted feedback is visible with its current status; the Owner can
see what happened to each piece. Source: the `feedback` table. See [[prd-work-intake]].

**Roadmap note (2026-09-05):** likely **folded into [[prd-cos-threads]] Phase 1** —
feedback-with-lifecycle-status is a thread carrying an intake outcome. Kept `proposed`;
supersede once the Threads direction is Owner-accepted ([[ledger-028-cos-threads-roadmap]]).

**Superseded (Owner-confirmed 2026-09-06):** Threads shipped ([[work-029]], [[work-030]])
and is the accepted intake loop, so feedback with lifecycle status is a thread carrying an
intake outcome — not a separate surface. Closed per the Owner's call during the overnight
crank ([[ledger-036-overnight-crank]]); the ext-feedback `feedback` table can be routed
into a thread if/when that wiring is prioritized.
