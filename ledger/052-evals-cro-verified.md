---
name: ledger-052-evals-cro-verified
description: ADR-015 (agent-eval criteria) was independently verified by the Chief Reality Officer (Owner-directed "verify evals", 2026-09-07). Verdict ACCEPT-WITH-FIXES; the CRO caught a real coverage gap (the code-reviewer, a live standing function, had no eval criteria). All five fixes are applied; the ADR is ready for CoS ratification, held for the Owner's go per the recorded readiness caveat.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-reality-officer
  last_verified: 2026-09-07
---

# Ledger 052 — Evals (ADR-015) CRO-verified, fixes applied

**Date:** 2026-09-07 · **Recorded by:** the operating session, Owner-directed ("verify evals").

## What
The Owner asked the org to **verify evals**. The [[chief-reality-officer]] independently
verified [[adr-015]] (per-role agent-eval criteria) — the gating prerequisite for [[work-007]]
("no score claimed until the criteria exist as an accepted ADR"). **Verdict: ACCEPT-WITH-FIXES.**

## The catch that mattered
The CRO found a real **coverage gap**: ADR-015 evaluated "the two standing functional agents
(qa-tester, git-manager)" — but there are **three**. The [[code-reviewer]] ([[glossary]],
[[adr-021]]) is a live `kind: function` agent with a domain distinct from both (ready-judgments,
the escalation checklist, the review→QA→debug cycle) and had **no definition of "good."** A
live core role with no criteria means work-007's gate was only *mostly* met, not met. The CRO
also flagged the CEO scoping (six vs seven), an absence-signal/clickthrough tension, a stale
INVARIANTS §III.8 citation, and a volume-gaming seam. It independently confirmed the strongest
parts hold: the "never fabricate" hard line, real (not proxy) signals, and honest handling of
the empty activity log.

## Fixes applied (adr-015 → v1.1.0)
1. **code-reviewer criteria added** (§A) — a third standing function with its own "good."
2. **CEO explicitly scoped out** (§A) — it holds Owner-delegated direction and is judged by the
   Owner; an org-eval of it would invert that line.
3. **Absence-signals reconciled with clickthrough** (§B.4) — non-events are qualitative context,
   never a clickable "0-as-earned" score.
4. **§III.8 mis-citation corrected** (§Context) — the ban is grounded in recorded-real-action +
   the CRO mandate, not a verbatim invariant (noted [[adr-013]] carries the same loose cite).
5. **Volume-gaming caveat added** (§C) — counts are quantity not quality; provenance + CRO
   validation are the backstop.

## Status + the honest caveat
ADR-015 is **ready for CoS ratification** but held for the Owner's go. The CRO recorded — and
this entry preserves — a **readiness caveat**: ADR-015's "not Owner-gated" classification rests
on [[decision-rights]], which is itself only *provisionally* ratified with a standing CRO
dissent awaiting the Owner's sign-off on whether a `standards/` file is a §I.4 core record-set.
CoS ratification here does **not** close that Owner question; it is reasonable only because this
ADR changes no core behavior, **computes no score**, and is reversible. **No eval score is
computed or surfaced** until the ADR is accepted — unchanged.
