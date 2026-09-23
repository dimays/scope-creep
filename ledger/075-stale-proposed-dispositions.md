---
name: ledger-075-stale-proposed-dispositions
description: Disposition pass (2026-09-23) over the 20 stale-proposed tickets board-hygiene has flagged since ledger-071 (work-067..085 + work-088). Owner-authorized end-to-end. Verified each against shipped reality; closed 3 and kept 17. Closes- work-067 → done (request-triage cadence-decision protocol is live + routines.json carries cadence_bounds); work-077 → done (both activity-hook fixes committed — the Task|Agent matcher in settings.json and the SCOPE_CREEP_HOME write-path convergence in log-activity.sh — plus the 63-event backfill); work-088 → superseded by ADR-026 + work-096 (the cloud routine's reconciled write access was delivered by the ADR-026 write-path redesign + ADR-023 Phase-2 identity and proven live in the canary, PR #119). Kept 17- five are intentionally trigger-gated feedback-at-scale tickets (work-072..076, awaiting a 2nd app / volume breach), twelve are valid unstarted backlog (work-068/069/070/071 + the org-activity-moments cluster work-078..082 + owner-action-notifications work-083..085). Finding- the age-based staleness flag mostly catches parked and unstarted-but-valid work, not rot; only 1 was truly obsolete. Delivered as a routine propose-only PR.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-23
---

# Ledger 075 — stale-proposed dispositions (the 20 board-hygiene flagged)

**Date:** 2026-09-23 · **Trigger:** Owner asked to disposition the 20 stale `proposed` tickets
board-hygiene has flagged since [[ledger-071-board-hygiene-first-run-canary]] · **Authority:**
Owner-authorized to decide and drive end-to-end · **Scope:** work-067…085 (continuous) + work-088.

## Headline

The 20-item "stale" list is **mostly not rot** — the board-hygiene flag is purely **age-based**,
so it re-catches (a) intentionally trigger-gated work and (b) genuine unstarted backlog. Of the
20: **3 closed** (2 already shipped, 1 superseded), **17 kept** (5 trigger-gated, 12 valid backlog).

## Closed (3)

| Ticket | New status | Evidence |
|---|---|---|
| [[work-067]] cadence governance | **done** | the [[request-triage]] loop emits a ledger `cadence-decision` block each run and `registry/routines.json` carries its `cadence_bounds` — the protocol this ticket specified is implemented |
| [[work-077]] activity write-path bug | **done** | both hook fixes are committed — the `Task\|Agent` matcher (`.claude/settings.json`) and the `SCOPE_CREEP_HOME` write-path convergence (`.claude/hooks/log-activity.sh`) — plus the 63-event backfill shipped; the worktree write↔read mismatch is resolved |
| [[work-088]] cloud-routine write access | **superseded** by [[adr-026]] + [[work-096]] | the reconciled write path (propose freely, cannot dispose a gate) was delivered by the ADR-026 redesign + [[adr-023]] Phase-2 identity and **proven live** in the supervised canary ([dimays/scope-creep#119](https://github.com/dimays/scope-creep/pull/119): branches/PRs open as the routine identity; a direct merge is refused 405; escalation holds) |

`docs/owner-apply-activity-write-path.md` refreshed to **applied** (its stale 2026-09-08 "first
patch didn't take" banner no longer reflects disk — both fixes are committed).

## Kept — trigger-gated, not stale (5)

All `prd-end-user-feedback-at-scale`; each explicitly *stays `proposed` until Tn fires* (a 2nd
app ships / a volume or duplicate-rate breach). Single-app today → correctly parked, not rot.

- [[work-072]] cross-thread dedup (T2/T3) · [[work-073]] parallel triage capacity (queue breach)
  · [[work-074]] cross-app feedback index (T1) · [[work-075]] cross-suite prioritization (T1) ·
  [[work-076]] suite-aggregation ADR (precedes 074/075).

## Kept — valid unstarted backlog (12)

Real, unbuilt, still tracing to a live PRD; none superseded (no `done` ticket exists in these
PRDs). [[work-071]] triage scale-telemetry (its gating [[work-066]] is **done** → ready to pick
up) · [[work-068]] consistency check + away-digest · [[work-069]] console markdown-rendering
uplift · [[work-070]] advisory docs:lint presentation signal · the org-activity-moments cluster
[[work-078]]/[[work-079]]/[[work-080]] (capture) + [[work-081]]/[[work-082]] (read-model +
surfacing) · the owner-action-notifications set [[work-083]]/[[work-084]]/[[work-085]].

## Process finding

The staleness flag mis-fires on trigger-gated + backlog tickets it can't distinguish from rot.
Options surfaced to the Owner (not applied here): give the trigger-gated five a `blocked`
side-state with a `blocked_reason` naming the trigger, or teach [[board-hygiene]] to exempt
tickets whose body declares a trigger.

## Disposition

Delivered as a **routine propose-only PR** (work/*.md `status` + a `docs/` refresh + this ledger
append = routine), Owner-authorized. `bun run work:check` green. See [[board-hygiene]],
[[work-readme]], [[ledger-071-board-hygiene-first-run-canary]], and the un-pause record
([dimays/scope-creep#119](https://github.com/dimays/scope-creep/pull/119)).
