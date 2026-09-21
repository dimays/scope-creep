---
name: ledger-063-work-board-reconciliation
description: Reconciliation pass over the work board (work-092) after the work-sweep first run (ledger-062) surfaced a stale board — 4 active tickets against a WIP cap of 2, so the sweep correctly started nothing. Flips 8 landed-but-non-terminal tickets to done with concrete merge-PR evidence — the two ADR-022 gate rails (work-058 guard-gates via scope-creep #44, work-059 guard-writes + in-band deny via scope-creep #46, both verified live in .claude/hooks), the Request-Loop tickets marked proposed-but-shipped (work-063 console #54, work-064 console #53, work-065 console #57/#60, work-066 console #59 + scope-creep #72/#77), and the work-sweep loop (work-086 console #70 + scope-creep #78, work-087 console #67 + scope-creep #87). Records which non-terminal tickets were deliberately LEFT open and why (work-060 Owner branch-protection; work-088 Owner-only write-access provisioning; work-077 fix pending Owner-apply; work-090/091 filed-not-built; the 067-085 PRD-phase backlog). No ticket file deleted (INVARIANTS §III). Scope: work/* + this ledger append only.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-21
---

# Ledger 063 — Work-board reconciliation (work-092)

**Date:** 2026-09-21 · **Recorded by:** Chief Knowledge Manager · **Repo:** `dimays/scope-creep`
· **Trigger:** [[work-092]] (the board-reconciliation fix queued by [[ledger-062-work-sweep-first-run]]).

## Why
The work-sweep first run ([[ledger-062-work-sweep-first-run]]) found a **stale work board**: the
sweep computes its ready set and the [[ticket-cycle]] WIP cap from ticket `status`, and it saw
**4 `active` tickets against a WIP cap of 2** (`atCap: true`) — so it correctly started nothing.
Several tickets carried `active`/`proposed` while their work had already **landed and merged**.
This pass makes the board reflect reality, evidence-first: a ticket flips to `done` only with a
cited merge PR. **No ticket file was deleted** ([[invariants]] §III); every flip is a `status`
+ `updated` edit plus a one-line body note ([[work-readme]] lifecycle).

## Flipped to `done` (8) — with merge evidence

| id | was | now | evidence (merge PR) |
|----|-----|-----|---------------------|
| [[work-058]] | active | done | scope-creep **#44** — `guard-gates.sh` merge-gate; **verified live** this session (hook fired). Blanket-grant revoke is Owner-local belt-and-suspenders; forgeable-identity carried to [[adr-023]] (Phase 1 landed #86/#85). |
| [[work-059]] | active | done | scope-creep **#46** — `guard-writes.sh` + in-band `permissions.deny` in `settings.json`; both present/live. Forgeable-marker residual is [[adr-023]] scope, not this ticket's acceptance. |
| [[work-063]] | proposed | done | console **#54** — thread read-state, persistent unread badge, notification center. |
| [[work-064]] | proposed | done | console **#53** — org async write-back wired into threads (critical-update / needs-input cards). |
| [[work-065]] | proposed | done | console **#57** (remote libSQL store, ADR-024) + **#60** (HTTP transport). Live; DB write-back confirmed in [[ledger-062-work-sweep-first-run]]. |
| [[work-066]] | proposed | done | console **#59** (runner) + scope-creep **#72** (ADR-025 topology) + scope-creep **#77** (registered live). See [[ledger-058-phase2-request-loop-landing]]. |
| [[work-086]] | active | done | console **#70** (runner mechanics) + scope-creep **#78** (capstone proposal). Loop **behavior** landed and fired its first run ([[ledger-062-work-sweep-first-run]]); activation blocker is [[work-088]]/[[work-093]], not this ticket. |
| [[work-087]] | active | done | console **#67** (milestone predicate + `cadence-decision` protocol) + scope-creep **#87** (cadence seed + bounds policy). |

Net effect: the four stale `active` tickets ([[work-058]], [[work-059]], [[work-086]],
[[work-087]]) clear the WIP cap, and two `proposed`-but-shipped Request-Loop tickets
([[work-063]], [[work-064]]) leave the sweep's ready set. The ready set now reflects genuinely
open work.

## Deliberately LEFT non-terminal (evidence-based)

- **[[work-060]]** (`blocked`) — branch protection is an **Owner-side GitHub account action**; no
  ledger shows it landed. Kept `blocked` (already staged-for-Owner). Untouched.
- **[[work-088]]** (`proposed`) — **Owner-only** GitHub-write-access provisioning. The
  `owner-apply` checklist deliverable landed (scope-creep #79), but acceptance ("the routine can
  push a branch and open a PR") is unmet — the sandbox still `403`s ([[ledger-062-work-sweep-first-run]]).
  The ticket itself states status stays `proposed` until the Owner executes. Left as-is.
- **[[work-077]]** (`proposed`) — the activity write-path fix touches the locked `.claude/**` gate
  surface and is **Owner-applied out-of-band**. [[ledger-057-transparent-delegation-visibility-fix]]
  records the PR (ticket + owner-apply doc + ledger) landed but the **core-hook change is not live
  until the Owner re-applies + commits it** (verified not-persisted 2026-09-08). Acceptance unmet;
  left open.
- **[[work-090]]**, **[[work-091]]** (`proposed`) — scope-creep #84 only **filed** these follow-ups
  (commit "work: file hook-scoping + fail-closed-on-gate follow-ups"). The hook-scoping fix
  (Owner-applied `.claude/**` change) and the `engineering-policy` standard edit have **not**
  landed. Left open.
- **[[work-067]]–[[work-085]] backlog** (`proposed`) — genuinely open PRD-phase work with no
  implementation merge: request-loop follow-ups ([[work-067]] cadence governance, [[work-068]]
  consistency digest), console/docs uplift ([[work-069]], [[work-070]]), the feedback-at-scale
  deep-dives ([[work-071]]–[[work-076]], `prd-end-user-feedback-at-scale`), the org-activity
  moments ([[work-078]]–[[work-082]], `prd-org-activity-moments`), and the owner-action
  notifications ([[work-083]]–[[work-085]], `prd-owner-action-notifications`). Each traces to a
  landed **PRD** (its scaffolding PR) but not landed **implementation**. Left as-is.

## Method note
Cross-checked every non-terminal ticket (`active`/`proposed`/`blocked`) against `git log
origin/main`, `gh pr list --state merged` on both `scope-creep` and `scope-creep-console`, and
the `ledger/` record. Terminal statuses (`superseded`/`dropped`/`done`/`retired`) were left
untouched. This pass reconciled `work/*.md` and appended this ledger entry only. Board items
[[work-092]] and [[work-093]] (in-flight this checkpoint) were intentionally **not** touched — a
separate reconciliation PR handles them and the [[ledger-062-work-sweep-first-run]] correction.
See [[work-092]], [[ledger-062-work-sweep-first-run]], [[prd-autonomous-execution-loop]].
