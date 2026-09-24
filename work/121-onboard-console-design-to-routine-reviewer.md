---
id: work-121
title: Onboard scope-creep-console & scope-creep-design to the routine-reviewer (Stage 1/2)
type: feature
status: proposed
priority: medium
owner: cto
spec: adr-027
created: 2026-09-24
updated: 2026-09-24
---

The [[adr-027]] routine-reviewer is live but **targets `dimays/scope-creep@main` only**
(`scripts/routine-reviewer.sh` origin-must-match-`--repo` guard). Most *routine* PRs actually land
in the **console** repo (e.g. `scope-creep-console#72`), so the highest-volume periphery is not yet
covered. Extending coverage to `scope-creep-console` and `scope-creep-design` is the logical next
stage. Surfaced by the 2026-09-24 audit.

## Acceptance
Per ADR-027's own staging, each repo onboarded only after it has, and passes:
- its own `scripts/escalation-check.sh` (or equivalent rail) + `.github/CODEOWNERS` escalation set,
- branch protection appropriate to that repo,
- a **supervised first run** + Chief-Reality-Officer sign-off (the same bar ADR-027 held itself to),
- then a scheduled unattended host (extend the `scope-creep-reviewer` Action, or a per-repo host).

## Notes
Explicitly **out of scope** for the initial host build (recorded in ADR-027 as a later Stage 1/2).
Console is the priority given PR volume. Depends on [[work-119]] (host operationalized first).
A true monorepo consolidation is **parked** — it would violate [[invariants]] §6.
