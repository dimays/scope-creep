---
id: work-098
title: Create and register the board-hygiene loop — the propose-only board janitor / write-path canary
type: feature
status: proposed
priority: medium
owner: chief-of-staff
spec: prd-autonomous-execution-loop
created: 2026-09-21
updated: 2026-09-21
---
**User problem.** Nothing keeps the work board honest on a cadence. The [[work-092]]
reconciliation was a one-off, but `status` drifts continuously as PRs land — and stale labels
break [[work-sweep]]'s ready set and WIP-cap accounting (that run saw 4 `active` tickets against
a cap of 2 and correctly started nothing). Board hygiene is the standing job that reconciles
`status↔reality`, flags WIP-cap violations, and surfaces stale `proposed` tickets for pruning —
part of running the roadmap autonomously ([[prd-autonomous-execution-loop]]).

**What this ticket delivers.** Stand up the [[board-hygiene]] loop as a scheduled, **propose-only**
claude.ai Code Routine. The manifest is **staged in this PR** ([[work-097]]); this ticket tracks
its **creation → registration → activation** as a routine, which is Owner-gated and PAUSED under
the write-path criteria below.

- **Propose-only, lowest blast radius.** It reads `work/*.md` and opens a single
  `board-state-correction` PR (apply mechanical `status↔reality` drift; flag WIP-cap violations
  and stale-`proposed` pruning for a human/local reviewer). It **never builds, never merges,
  never retires a ticket** — its only writes are `status` fields.
- **The write-path canary.** Because it is the smallest, most-reversible change surface in the
  system, it is the **ideal routine to un-pause first** once the cloud write path is granted —
  proving the propose-only path (routine opens PR → human/local merges) end-to-end **before**
  [[work-sweep]] drives real builds. It un-pauses under the **same criteria as [[work-sweep]]**:
  the [[work-096]] write-path redesign / a forthcoming **ADR-026**
  ([[ledger-066-cloud-sandbox-proxy-identity-wall]]).
- **Cadence proposal (Owner-gated):** seed `1 day`, `cadence_bounds_days [0.5, 7]` — uniform
  with [[work-sweep]]; self-tunes on drift rate + board churn.
- **Registration is Owner-gated ([[adr-021]]).** The claude.ai routine (`trigger_id` + `cron` in
  `registry/routines.json`) is registered by the Owner/CoS after this lands and the write path
  clears. This ticket does **not** fabricate a `routines.json` entry.

**Gate class — Owner-gated core-upgrade / escalation ([[adr-021]]).** Creating a new scheduled
core loop and registering a routine is Owner-gated; this holds for the Owner and is not
self-authorized.

**Acceptance:** the [[board-hygiene]] manifest is registry-valid and appears in
`registry/loops.json`; the routine is registered by the Owner and, once the write path clears,
un-paused as the canary and observed to open a real `board-state-correction` PR that a
human/local reviewer merges — with no ticket retired autonomously and no STOP gate crossed. See
[[prd-autonomous-execution-loop]], [[board-hygiene]], [[work-sweep]], [[work-096]].
