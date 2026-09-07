---
name: ledger-048-autonomous-merge-cro-and-decision
description: The independent CRO pass on ADR-022 (autonomous merge) returned RATIFY-WITH-FIXES — the design is textually sound but ~100% reviewer-judgment with no mechanical backstop, making the "org merges a change to its own gates" case reachable today. The Owner chose "ratify direction, build the gates, then activate." Records the verdict, the decision, and the 5 activation-precondition tickets. INVARIANTS unchanged; merges stay Owner-gated until the rails ship + QA-verify.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 048 — Autonomous merge: CRO verdict + Owner decision

**Date:** 2026-09-06 · **Recorded by:** the operating session.

## The catch (the system working)
The [[chief-reality-officer]] ran an adversarial loophole-hunt on [[adr-022]] and returned
**RATIFY-WITH-FIXES**: the written model relaxes only merge and preserves every §7 hard
line word-for-word, but its net-new safety is **~100% reviewer judgment with no mechanical
backstop** — and today `gh pr merge` is pre-granted, `main` has no branch protection, agents
can Edit the gate files, and the strongest permission grants live in a gitignored file the
escalation checklist can't see. So the catastrophic case — the org autonomously merging a
change that **weakens its own gates** — is **currently reachable**. "Escalation is a promise,
not a gate" until mechanical enforcement exists.

## The decision (Owner)
The Owner chose **"ratify the direction, build the gates, then activate."** So:
- The DIRECTION of [[adr-022]] is **accepted**; the model is the target.
- The INVARIANTS §10/§7 amendment is **NOT applied**; **merges stay Owner-gated** exactly
  as [[adr-014]] has them, until the mechanical rails ship and are QA-verified.
- Applied the CRO's doc fixes to [[adr-022]] (`.github/workflows/**` + infra manifests added
  to trigger (d); routine ledger-append carved out; the Activation gate section added).

## Activation preconditions (filed as tickets)
[[work-057]] path-based auto-escalation CI check (floor) · [[work-058]] gate `gh pr merge`
+ revoke the blanket grant (floor) · [[work-059]] block Edit/Write to the gate surface +
bring `settings.local.json` in-band · [[work-060]] branch protection on all repos ·
[[work-061]] QA spike proving author≠merger + the path-check blocks. Rails 057/058 are the
floor; then the Owner applies the exact invariant text and flips [[adr-022]] active.

## Note
This is exactly why the org runs an independent skeptic before a load-bearing change:
the CoS designed a sound model, the CRO caught that it wasn't safe to *turn on* yet, and
the Owner sequenced it safely. The DevOps + Security employee templates ([[adr-021]]) are
the intended staff for the rails.
