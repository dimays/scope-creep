---
name: prd-request-loop
description: The Request Loop — submit-and-forget request handling. Autonomous triage into the roadmap, the thread as the async system of record, and in-app notifications so the Owner is pulled back only when a call is theirs. Supersedes request-intake v1.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-07
---

# PRD — The Request Loop

> **Owner-approved 2026-09-07** (dispositions recorded below). The flagship feature of
> the September cycle. Turns [[request-intake]] v1 (async-in-operator-session, no
> trigger, no write-back) into a closed loop the Owner can walk away from.

## The problem — it isn't missing pieces, it's unconnected ones

The rails already exist. [[request-intake]] specs the triage. The org's thread writers
(`createOrgThread` / `orgFollowup` / `addGeneratedRequest` in `threads.server.ts`) are
fully implemented. The scheduling substrate — claude.ai Code Routines — already runs
[[roadmap]], [[staffing-review]], [[evolve]]. Nothing wires them into a loop, so the
burden of closing it lands on the Owner:

1. **The org can't reply without the Owner opening Claude.** A thread's assistant side
   lives only inside a launched Claude session, projected read-only ([[adr-016]]). There
   is no async write-back — "check the thread later" always means "launch a session
   first."
2. **The write-back path is built but never called.** The org *can* post an update and
   flip a thread to `needs-you`; zero production code invokes it.
3. **Triage has no trigger.** [[request-intake]] is "v1 async in an operator session" — a
   human runs Claude, an agent hand-authors ticket files.
4. **"Something needs you" only shows if you look.** The single signal is the `needs-you`
   status, counted on load of `/` and `/threads`. No unread state, no persistent badge.

## The experience

Three moves, in the Owner's words — each closes a gap above.

- **Submit & forget.** The Owner posts a request; the org picks it up on its own, sizes
  it, and slots it against the live roadmap — declining, counter-proposing, or turning it
  into tickets. Simple things just get done.
- **The thread is the record.** Every decision and status change lands in the thread as a
  real message — not trapped in a terminal session. One thread shows what happened and
  exactly where the Owner's call is needed.
- **It reaches out.** A persistent unread badge, a notification center, and an away-digest
  of what shipped. The Owner stops polling; the loop surfaces what's on their plate.

## The loop

`submit → sweep → triage ([[request-intake]]) → decide → execute ([[ticket-cycle]],
merge gated by [[adr-022]]) → write the outcome back to the thread → notify → pull the
Owner in only when the call is theirs`. The one net-new runner is the scheduled
[[request-triage]] sweep; everything else is existing rails, connected.

## Owner dispositions (2026-09-07)

- **Q1 — Email/push: in-app only this cycle.** No reversal of INVARIANTS §II; the badge,
  notification center and away-digest are enough for now. Email revisits as its own
  decision in a later cycle.
- **Q2 — Shared thread store: approved.** A cloud-writable conversations DB ([[adr-024]]).
  Single database, single user — **not** tenancy or auth; §II preserved.
- **Q3 — Auto-merge simple accepts from day one.** Periphery work merges under [[adr-022]]
  without a checkpoint; the org parks genuine judgment calls at `needs-you`; the
  deploy/spend/delete/publish/core STOP gates still hard-stop regardless.
- **Q4 — Hourly, self-tuning.** The sweep runs hourly to start, and a Chief-of-Staff-owned
  function tunes that frequency on real signal, recording changes in the [[ledger]] as the
  other scheduled routines do ([[work-067]]).

## Scope (tickets)

- [[work-063]] — thread read-state, persistent unread badge, notification center.
- [[work-064]] — wire the org's async write-back; critical-update / needs-input types.
- [[work-065]] — the shared remote thread store ([[adr-024]]).
- [[work-066]] — the `request-triage` routine.
- [[work-067]] — cadence governance for the sweep.
- [[work-068]] — loop consistency check + away-digest.

## Non-goals (this cycle)

Multi-user accounts, roles or tenancy (the singleton posture stays); emailed/push alerts
(deferred, Q1); a local server-side scheduler daemon (scheduling stays on cloud routines);
replacing the launched-session deep-dive (it remains for interactive work); auto-merging
past the STOP gates; new scope without an Owner-gated PRD/ADR.

## Relationship to the flagship chatbot

[[request-intake]]'s v2 ("live in-app agent chat") folds into [[work-001]]. The Request
Loop is the **async** intake application: it produces backlog + thread changes on a
schedule, not a live conversation. It shares the thread primitive ([[adr-012]]) with the
chatbot and needs no in-app agent runtime — the triage agent runs in the cloud routine.

## Success

The Owner offloads a request in seconds, closes the tab, and trusts it's triaged — coming
back only when the notification says a call is theirs, and finding the whole story in the
thread when they do.
