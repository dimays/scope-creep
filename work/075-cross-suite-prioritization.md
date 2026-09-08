---
id: work-075
title: Cross-suite prioritization board and per-app routing
type: feature
status: proposed
priority: medium
owner: chief-product-officer
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The prioritization deep-dive from [[prd-end-user-feedback-at-scale]]. [[request-triage]] today
decides each ask against "the live roadmap" **in isolation**; with many concurrent asks across
apps this is effectively FIFO and there is no single "what's on the Owner's plate" view.

**The ask:**
- **Cross-suite ranking** — one ordered plate of open asks across **all** apps against a single
  roadmap ([[roadmap-001]]), so triage prioritizes globally, not per-thread.
- **Per-app routing** — an ask routes to the **owning executive/lead for that app**, not a
  single global triager; pairs with the routing that [[work-073]]'s capacity model needs.
- **Batching** — related accepted asks roll into coherent work rather than scattered tickets
  (consumes [[work-072]]'s clusters).

**Acceptance:** the Owner sees one ranked, suite-wide plate; a new ask lands in the right app's
backlog at the right rank without a per-app hunt; prioritization changes respect the
[[ticket-cycle]] hysteresis rule (no flip-flop, ≤1 priority flip per N completions without the
Owner). New scope stays Owner-gated ([[invariants]] §I).

**Trigger:** **T1** (the 2nd app ships). Stays `proposed` until then.
