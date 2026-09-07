---
name: ledger-047-autonomous-merge-with-escalation
description: Records the PROPOSED governance change (ADR-022) moving the routine PR-merge gate from Owner-approval to independent org review, with a hard-line escalation checklist (financial / security / substantial-tradeoff / safety-rail-or-core) that holds a PR for the Owner. Includes the exact drafted INVARIANTS §10/§7 amendment for Owner ratification. Not yet ratified; needs an independent CRO pass and Owner sign-off on the invariant text.
metadata:
  type: project
  status: proposed
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 047 — Autonomous merge with escalation (PROPOSED)

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff (Owner-directed) · **Status:**
**PROPOSED — awaiting Owner ratification.** Not ratified; not merged.

## What this proposes
The Owner directed (2026-09-06) that the org merge routine code **without Owner
approval**, trusting independent reviews, reserving the Owner's attention for
high-risk PRs — and **authorized an INVARIANTS amendment** to do it. Drafted:
- **[[adr-022]]** (proposed): the **autonomous-merge-with-escalation** model. Routine
  periphery / non-core PRs land on **independent org review** (author ≠ merger;
  [[code-reviewer]] to [[cto]] standards; [[qa-tester]] proof; [[git-manager]] lands +
  records). Any of four **escalation triggers** HOLDS the PR for the Owner:
  **(a)** financial burden/spend, **(b)** security risk, **(c)** substantial tradeoff /
  C-suite concern, **(d)** a change to the safety rails or the core.
- **The exact drafted INVARIANTS §10 + §7 amendment** (version → 1.3.0) lives in
  [[adr-022]] as its core and in the PR body — **flagged PROPOSED**. `INVARIANTS.md`
  is deliberately **left untouched**: only the Owner amends it (§I.2); the Owner
  applies the exact text on ratification.
- Proposal-flagged edits (active on ratification) to: [[adr-014]] (superseded-in-part
  note), [[git-manager]] (merge on review-pass, not Owner-approval, except escalation),
  [[code-reviewer]] (owns the escalation checklist as a review step), [[dev-cycle]]
  (Stage 5 escalation gate + Stage 6 land paths), [[decision-rights]] (routine vs.
  escalated PR-landing rows).

## What does NOT change (reinforced)
- **[[invariants]] §7 is absolute and untouched.** `deploy` / spend / `delete` /
  publish require the Owner at the moment of action; the **`guard-gates` hook is
  UNCHANGED**; a **red gate is never waivable by an agent**. Merging code ≠ spending —
  but a PR that *enables/requires* spend escalates, and the spend action itself stays
  §7-hook-gated at execution regardless of how the code landed.
- **Core-upgrades still require explicit Owner approval** ([[invariants]] §I.4).
  Autonomous merge is **periphery / non-core only**; a core-touching PR escalates like
  an INVARIANTS change (trigger (d)).
- **The [[ceo]] cannot self-authorize a gate, a core-upgrade, or clear an escalation
  hold** ([[adr-018]]). A delegated role is never the Owner.

## Still needed before this lands
1. **Independent [[chief-reality-officer]] pass** on the model and the exact invariant
   text (this is the most load-bearing change in the system; a loophole is
   catastrophic). Pressure-test especially: trigger (d) coverage (can any safety-rail
   or core edit slip the checklist?), the routine-vs-core boundary, and whether the
   checklist should be enforced *mechanically* (a CI/hook pre-merge check) rather than
   by reviewer goodwill — flagged in [[adr-022]] Consequences as a CTO follow-up.
2. **Owner ratification of the exact INVARIANTS §10/§7 wording** ([[invariants]] §I.2).
   Only the Owner amends INVARIANTS. On sign-off, the Owner applies the drafted diff
   and the proposal-flagged doc edits flip to active.

## Note on this PR's own rule
Under the very model it proposes, **this PR is a safety-rail change (trigger (d)) and
is therefore non-self-mergeable** — it must go to the Owner. That is the rule working
as intended.
