---
name: ledger-076-board-hygiene-status-reconciliation
description: Scheduled board-hygiene run (2026-09-23) — the Tier-1 canary's first cadenced run since un-pause. Diagnosed the board (117 items) against main's merge history on both repos; applied 3 mechanical status<->reality drift corrections (work-094 proposed->done via scope-creep#114; work-098 proposed->done via scope-creep#96/#101/#103; work-117 blocked->done via scope-creep#110/#114/#119/#116) — all evidenced by merged PRs, none `rm`'d. WIP cap clean (0 active against cap 2, no violation). No newly-stale proposed tickets flagged: the 17 old-proposed candidates (work-068..085 minus already-closed) were reviewed and dispositioned by the Owner THIS SAME DAY in ledger-075, so re-flagging them would duplicate that pass. Two judgment-call items surfaced, not auto-resolved: work-060 (branch protection) has strong textual corroboration of being live (main protection confirmed in work-117's body, itself now evidenced-done) but no PR to cite and no in-sandbox tool to read GitHub branch-protection state directly — flagged for an Owner/local confirm-and-close, not applied. work-093 self-declares "superseded by work-096" in its own body while status stays `blocked` — flagged as a retirement judgment call (hygiene never moves a ticket to a terminal status), not applied. Schema clean (`bun run work:check` -> 117 OK, before and after). Delivered as a routine propose-only PR, holds for @scope-creep-review.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-23
---

# Ledger 076 — board-hygiene status reconciliation (2026-09-23 scheduled run)

**Date:** 2026-09-23 · **Trigger:** scheduled `board-hygiene` cloud routine (cron `0 15 * * *`,
`trig_014FAeeQ6aEMEpZF4ACQt9KL`) · **PR:** holds for `@scope-creep-review`; nothing merged by this
session's sandbox identity (proven unable to by the ADR-026 canary, [#119](https://github.com/dimays/scope-creep/pull/119)).

## What ran

Per [[board-hygiene]]: `scope-creep-console` deps installed (`bun install`), `SCOPE_CREEP_HOME`
exported to the `scope-creep` checkout, board read via `work/*.md` + `work-sweep sweep` (Node/tsx),
diagnosis cross-checked against `git log` on both repos' `main` and the [[ledger]].

## Diagnosis

**Status↔reality drift — 3 found, all applied** (each evidenced by a merged PR, `pr:` + a
one-line note added per [[work-readme]]; nothing `rm`'d):

| Ticket | Was | Now | Evidence |
|---|---|---|---|
| [[work-094]] | `proposed` | `done` | [scope-creep#114](https://github.com/dimays/scope-creep/pull/114) — the `.github/CODEOWNERS` case landed in `is_escalation()`, merged to `main`. The ticket's own status never advanced past `proposed` even though the fix shipped. |
| [[work-098]] | `proposed` | `done` | Manifest via [scope-creep#96](https://github.com/dimays/scope-creep/pull/96); the canary run opened+merged [scope-creep#101](https://github.com/dimays/scope-creep/pull/101) ([[ledger-071-board-hygiene-first-run-canary]]); registered + un-paused via [scope-creep#103](https://github.com/dimays/scope-creep/pull/103). All three acceptance legs (manifest, registration, a real merged canary PR) are on `main`. |
| [[work-117]] | `blocked` | `done` | All four of its own stated acceptance conditions are on `main`: ADR-023 Phase-2 CODEOWNERS split ([#110](https://github.com/dimays/scope-creep/pull/110)), the escalation-check CODEOWNERS-gap fix ([#114](https://github.com/dimays/scope-creep/pull/114), work-094), the ADR-026 supervised canary PASS ([#119](https://github.com/dimays/scope-creep/pull/119), [[ledger-073-work-sweep-first-run-canary]]), and the control-plane PR flipping `work-sweep` `paused → active` ([#116](https://github.com/dimays/scope-creep/pull/116)). `registry/routines.json`'s own `work-sweep` entry corroborates: "Marked active only as the last step of the work-117 un-pause." |

**WIP-cap violations:** none — `activeCount: 0` against `wipCap: 2` (`work-sweep sweep` output).
The board is clean since [[ledger-074-board-reconciliation]] cleared the post-un-pause 10-ticket
overshoot.

**Stale `proposed` tickets — flagged, NOT re-flagged today:** 17 tickets (work-068…076,
work-078…085) are ≥16 days untouched (`updated: 2026-09-07`), which would ordinarily cross the
staleness window. But [[ledger-075-stale-proposed-dispositions]], dated **today** (2026-09-23,
earlier this same day), already reviewed this exact set Owner-authorized end-to-end and kept all
17 with documented reasons (5 trigger-gated per `prd-end-user-feedback-at-scale`, 12 valid
unstarted backlog) — closing the other 3 (work-067, work-077, work-088) that *were* rot. Re-flagging
the same 17 hours later would duplicate a disposition the Owner just made, so this run does not
re-surface them. The staleness signal is purely age-based and cannot itself detect "reviewed
today, intentionally kept" — see ledger-075's own process finding. If the Owner wants trigger-gated
tickets exempted from future staleness flags (a `blocked` side-state or a body-declared-trigger
exemption), that's an open [[board-hygiene]] enhancement, not applied here.

**Schema faults:** none — `bun run work:check` → `117 work items OK`, before and after this run's
3 edits (which only touched `status`/`pr`/`updated` + a one-line note on 3 existing tickets).

## Surfaced, NOT auto-resolved (judgment calls for `@scope-creep-review` / Owner)

- [ ] **[[work-060]]** (`blocked` — branch protection). [[work-117]]'s own body (now itself
  evidenced-done, see above) states, dated 2026-09-22: "main protection LIVE both repos
  (`require_code_owner_reviews`, `require_last_push_approval`, escalation-check is a required
  status check, `enforce_admins` true)" — which appears to satisfy work-060's acceptance
  ("direct push to `main` is blocked; a PR needs the required checks green"). This run does
  **not** apply that correction: it's an Owner-side GitHub security-settings action with no PR to
  cite, and this session has no tool to independently read live branch-protection state (the
  GitHub MCP server here exposes no branch-protection/rulesets read). [[ledger-063-work-board-reconciliation]]
  deliberately left it `blocked` for the same reason. Recommend the Owner (or `@scope-creep-review`
  reviewing this PR) confirm branch protection directly on GitHub and close work-060 if so —
  hygiene flags, never retires.
- [ ] **[[work-093]]** (`blocked` — harden work-sweep cloud routine, first-run findings). The
  ticket's own body already states "Superseded by the [[work-096]] write-path redesign; do not act
  on the credential instructions below" (written 2026-09-21) — but `status` was never advanced to
  a terminal state. Per [[board-hygiene]]'s guardrail ("reconcile, never retire"), moving a ticket
  to `superseded`/`dropped` is the Owner's/CPO's call, not this routine's, even when the ticket's
  own prose already says so. Surfaced for disposition, not applied.

## Disposition

Delivered as a **routine propose-only PR** (`work/*.md` `status`/`pr`/`updated` edits + this
ledger entry = the routine's scope), held for `@scope-creep-review`. `bun run work:check` green
before and after. Nothing merged by this session's sandbox identity — proven structurally blocked
by [[adr-026]] ([#119](https://github.com/dimays/scope-creep/pull/119)); the Owner disposes
(review + merge) off-sandbox. See [[board-hygiene]], [[work-readme]], [[ledger-074-board-reconciliation]],
[[ledger-075-stale-proposed-dispositions]].
