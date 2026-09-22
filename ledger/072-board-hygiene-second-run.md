---
name: ledger-072-board-hygiene-second-run
description: Record of the second board-hygiene run (2026-09-22, daily cadence). Opened dimays/scope-creep#112 applying 5 mechanical status<->reality corrections (work-100..104 -> done, gated by scope-creep-console#72 which merged to main 2026-09-21) and surfacing a 5-ticket WIP-cap violation (work-105..109, cap is 2) plus the same 20 stale-proposed tickets from ledger-071 (still undispositioned) for the Owner/CPO. Schema faults: none (bun run work:check green, 116/116 before and after).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-22
---

# Ledger 072 — board-hygiene second run

**Date:** 2026-09-22 · **Trigger:** scheduled `board-hygiene` cloud routine (daily cadence,
`cron: 0 15 * * *`) · **PR:** [dimays/scope-creep#112](https://github.com/dimays/scope-creep/pull/112)
— **holds for `@scope-creep-review`; nothing merged by the routine.**

## What ran
Per [[board-hygiene]], set up `scope-creep-console` (`bun install`), exported
`SCOPE_CREEP_HOME` to the `scope-creep` checkout, pulled latest `main` (`7b78cf8`), and ran the
read-only board diagnosis before writing anything. The prior run's PR
([dimays/scope-creep#101](https://github.com/dimays/scope-creep/pull/101),
[[ledger-071-board-hygiene-first-run-canary]]) was
confirmed **merged** (2026-09-22T01:09:46Z), so this is a fresh diagnosis against current `main`,
not a re-opening of stale state.

## Diagnosis (read-only, against [[work-readme]] reality)
- **Status↔reality drift — 5 found, all applied:** [[work-100]] (umbrella), [[work-101]],
  [[work-102]], [[work-103]], [[work-104]] were all still `active`, but their gating PR
  [scope-creep-console#72](https://github.com/dimays/scope-creep-console/pull/72) — confirmed
  `merged: true` via the GitHub API — merged to `main` 2026-09-21T23:56:24Z and explicitly lists
  all five tickets as closed by it (its own "Tickets" section: "work-100 (umbrella), work-101
  (folder), work-102 (resume), work-103 (reopen), work-104 (design)"). Flipped all five to
  `done`, set `pr:` to that PR URL, bumped `updated: 2026-09-22`, and added a one-line dated note
  per [[work-readme]]. No file was `rm`'d. The PR's own follow-up tickets
  ([[work-105]]–[[work-109]]) are explicitly **not** closed by #72 (listed as separate follow-up
  work) and were left untouched.
- **WIP-cap violations — 1 found, flagged (not resolved):** before this run's correction, **10**
  tickets were `active` ([[work-100]]–[[work-109]]) against the [[ticket-cycle]] cap of **2**.
  After applying the mechanical drift correction above, **5** remain `active`
  ([[work-105]], [[work-106]], [[work-107]], [[work-108]], [[work-109]] — all Threads follow-ups,
  none carrying a `branch:`/`pr:`, i.e. none has code in flight yet) — still **3 over cap**.
  Surfaced in the PR body for the Owner/CPO to decide which stay active vs. yield; hygiene does
  not auto-resolve WIP-cap judgment calls.
- **Stale `proposed` tickets (flagged, not touched) — same 20 as
  [[ledger-071-board-hygiene-first-run-canary]]:** [[work-067]]
  through [[work-085]] (continuous, 19 tickets, unchanged since 2026-09-07) plus [[work-088]]
  (unchanged since 2026-09-08) — all now **≥15 days** untouched and still undispositioned since
  the prior run flagged them. Re-surfaced; hygiene never retires a ticket.
- **Schema faults:** none — `bun run work:check` → `116 work items OK` both before and after this
  run's edits (edits only changed `status`/`pr`/`updated` + a one-line note on 5 existing
  tickets).
- **Other statuses reviewed, left alone (out of the loop's mechanical scope):** [[work-060]] and
  [[work-093]] remain `blocked` — both are genuine side-states pending Owner/CPO judgment calls
  already recorded in their own bodies, not a merged-PR reconciliation; [[work-094]] and
  [[work-116]] remain `proposed` with open/related PRs, but both are explicitly Owner-applied
  gate-surface changes (not yet `active`, no code-complete PR against the ticket itself) — leaving
  them untouched avoids inventing a lifecycle transition the loop isn't chartered to make.

## Outcome
PR opened via REST as the forced sandbox-proxy identity (ADR-026; no token minted or presented —
the sandbox's supplied auth was used as-is). Holds for `@scope-creep-review`. Posted to the
owning thread via the [[work-064]] writers. See [[board-hygiene]], [[work-readme]], [[adr-026]],
[[ledger-071-board-hygiene-first-run-canary]].
