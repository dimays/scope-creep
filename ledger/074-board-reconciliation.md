---
name: ledger-074-board-reconciliation
description: Board-state reconciliation (2026-09-23) applied after work-sweep was un-paused — brings the work board honest and within the ticket-cycle WIP cap (≤2 active). Two mechanical drift corrections and one Owner-delegated WIP-cap resolution- work-100..104 (the Threads UX umbrella + its 4 child defects) flip active → done (landed via scope-creep-console#72, merged 2026-09-21, per the board-hygiene run-2 diagnosis in #112); work-105..109 (un-started Threads follow-up debt/chore, none carrying a branch or PR) flip active → proposed, returning them to To-do so the now-live work-sweep re-activates them within the ≤2 cap. Net- active count 10 → 0 (cap satisfied). Owner-delegated this run (David Mays asked to reconcile the board); delivered as a routine propose-only PR held for @scope-creep-review, superseding the stale/incomplete #112. Nothing retired (no rm, no dropped/superseded); 20 stale-proposed pruning candidates remain an open Owner/CPO call as first flagged in ledger-071.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-23
---

# Ledger 074 — board reconciliation (post-un-pause WIP-cap clear)

**Date:** 2026-09-23 · **Trigger:** Owner asked to reconcile the work board right after
un-pausing [[work-sweep]] · **Model:** the [[board-hygiene]] board-state-correction (this is the
manual form of that routine's pass) · **Supersedes:** the stale/incomplete
[dimays/scope-creep#112](https://github.com/dimays/scope-creep/pull/112).

## Why now

[[work-sweep]] was un-paused live at its claude.ai `manage_url` (2026-09-23) after the ADR-026
canary passed ([[ledger-073-work-sweep-first-run-canary]]). The board it un-paused onto carried
**10 tickets in `active`** (work-100…109) against the [[ticket-cycle]] WIP cap of **≤2** — 5× the
cap. A cadenced sweep should start from an honest, within-cap board, so the Owner asked for a
reconciliation pass.

## Applied — mechanical status↔reality drift (5 tickets: `active → done`)

The Threads-UX umbrella + its four child defects landed via
[scope-creep-console#72](https://github.com/dimays/scope-creep-console/pull/72) (merged
2026-09-21; verified in the board-hygiene run-2 diagnosis, [[work-readme]] `review → done` on
merge):

| Ticket | Was | Now | Landed by |
|---|---|---|---|
| [[work-100]] | `active` | `done` | console#72 (umbrella) |
| [[work-101]] | `active` | `done` | console#72 (default-folder fix) |
| [[work-102]] | `active` | `done` | console#72 (resume-existing fix) |
| [[work-103]] | `active` | `done` | console#72 (reopen-ongoing verify) |
| [[work-104]] | `active` | `done` | console#72 (design polish) |

Each: `pr:` set to console#72, `updated: 2026-09-23`, a one-line dated note added. Nothing `rm`'d.

## Applied — WIP-cap resolution (5 tickets: `active → proposed`) — Owner-delegated

work-105…109 are **un-started follow-up debt/chore** spun off the Threads fix. None carries a
`branch:` or `pr:` — per [[work-readme]], `active` means "being built on a branch," so labelling
them `active` was inaccurate. Returned to `proposed` (To-do); the now-live [[work-sweep]] will
re-activate them within the ≤2 cap as it picks them up:

| Ticket | Was | Now | Note |
|---|---|---|---|
| [[work-105]] | `active` | `proposed` | remove dead `openRepoLink` field |
| [[work-106]] | `active` | `proposed` | extract shared CommandRow/CopyButton primitive |
| [[work-107]] | `active` | `proposed` | dedup control-plane-home env resolver |
| [[work-108]] | `active` | `proposed` | harden `buildCliCommand` shell-escaping |
| [[work-109]] | `active` | `proposed` | test env restore in try/finally |

This is the [[board-hygiene]] "judgment call" the routine *flags but does not auto-resolve*; here
the Owner explicitly delegated the call this run. Reversible — nothing retired.

## Net

**Active count 10 → 0** — within the ≤2 WIP cap. Board is honest: 5 done, 5 back in To-do.

## Left for the Owner/CPO (unchanged, not actioned)

- **20 stale `proposed` pruning candidates** (work-067…085 + work-088, ≥15 days untouched) — first
  flagged in [[ledger-071-board-hygiene-first-run-canary]], still an open `dropped`/`superseded`/keep
  call. Hygiene never retires a ticket.

## Disposition

Delivered as a **routine propose-only PR** (work/*.md `status` + this ledger append = routine),
held for `@scope-creep-review`. `bun run work:check` green. Nothing merged by this session's
sandbox identity (it cannot — [[ledger-073-work-sweep-first-run-canary]]); the Owner disposes
(review as `@scope-creep-review` + merge) off-sandbox. The stale #112 is closed as superseded.
See [[board-hygiene]], [[ticket-cycle]], [[work-readme]], [[ledger-073-work-sweep-first-run-canary]].
