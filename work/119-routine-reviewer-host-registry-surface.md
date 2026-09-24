---
id: work-119
title: Routine-reviewer host — registry surface + operational close-out
type: chore
status: proposed
priority: high
owner: cto
spec: adr-027
created: 2026-09-24
updated: 2026-09-24
---

The [[adr-027]] routine-reviewer went live this session as an hourly GitHub Action in the
separate Owner-owned repo `dimays/scope-creep-reviewer` (ADR-027 Divergence ii), with
`heartbeat` + `liveness` reliability workflows. It is **the only system that merges unattended**,
yet it has **no first-class manifest anywhere** in this control plane: it is not a claude.ai
routine (so not in `registry/routines.json`) and not a loop (so not in `registry/loops.json`).
Surfaced by the 2026-09-24 system audit as a discoverability gap.

## Acceptance
- A discoverable record of the Action-hosted reviewer exists in the control plane — either a new
  registry surface for Action-hosted autonomy (distinct from claude.ai routines) or an explicit
  entry/pointer in `registry/routines.json` with a note that its system-of-record is the
  `scope-creep-reviewer` repo. `registry:check` stays green.
- [[ledger-078-routine-reviewer-action-host-live]] is landed on `main` (PR #134) and [[work-118]]
  is advanced to `done` (its final "scheduled unattended" leg is satisfied by the live Action).
- The reviewer's lockdown posture (discipline-only branch protection on a free-plan private repo)
  and its liveness/heartbeat monitoring are captured as ongoing operational facts, not just prose
  in the reviewer repo's README.

## Notes
Host + heartbeat + liveness were **built** this session (reviewer-repo PRs #1/#2); this ticket is
the control-plane-side close-out (discoverability + ledger + work-118 finalization). See
[[adr-027]] Amendment. Related: [[work-121]] (extend coverage to console/design).
