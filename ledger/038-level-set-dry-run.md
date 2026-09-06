---
name: ledger-038-level-set-dry-run
description: The acceptance dry-run for the new recurring level-set loop (work-033) — one genuine pass against the real current repo state, producing a ranked paydown-and-lessons plan. Track selection is Owner-gated and left pending, per the loop's own step 5.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 038 — Level-set dry run (acceptance pass for work-033)

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff, implementing [[work-033]].

## Why this round, and how it was run
[[work-033]]'s acceptance requires one genuine pass through the new [[level-set]] loop
before it can be marked done. This round is scoped light per the loop's `domain_hats`
input: a **single-hat pass (CoS only)**, not a full-C-suite convene — the loop's own
"Spawn discipline" section exists precisely because a full-roster fan-out has hit the
session rate limit three times this operating window ([[ledger-027-level-set-round]]'s
dry run, the incident [[resource-budget]] was written to prevent, and again during
tonight's [[ledger-036-overnight-crank]]). Consistent with that lesson, this
implementation pass ran with **zero subagent fan-out** — one CoS hat, reading the real
`work/`, `ledger/`, and `standards/` state directly, no spawns to stagger. A full
multi-hat round is still the loop's default; this is the honest minimum that exercises
steps 1–4 and 6–7 without repeating the mistake the loop is meant to catch.

## Assessment (read-only, against the real repo state at HEAD)

**Debt stream:**
- [[work-036]] (delegation event capture) sits `proposed`/gated — blocked on its own
  proof-of-hook spike ([[adr-013]]), not on neglect.
- [[work-037]] (delegation surface) and [[work-031]] (inline thread activity) are both
  correctly `proposed` and explicitly dependency-blocked on [[work-036]] — the chain is
  modeled right; nothing to re-rank.
- [[work-004]] (CI auto-heal) has sat `proposed` since 2026-09-04 — the oldest open
  ticket in the backlog — because it needs an agent runner with Claude auth in CI, an
  infra dependency nobody has staffed yet.

**Reflection stream (mistakes / reversals / gate-catches — mining the [[ledger]]):**
- **Gate-catch:** [[work-041]] is an Owner-gated shared-package palette/token-API
  change ([[decision-rights]]: "design system / shared tokens" row). It was flipped
  `proposed → done` by a plain bookkeeping commit (`f5aed21`, alongside work-018) with
  **no ledger entry** and **no Done note on the ticket itself** recording a CRO check or
  an explicit Owner sign-off — unlike [[work-034]] (also Owner-gated), which got a full
  [[ledger-037-decision-loop-sample]] record including a live CRO dissent. Same category
  of gap [[ledger-027-level-set-round]] finding #3 already named ("standards
  unenforced"), recurring in a new corner: an Owner-gate can still be satisfied *in
  substance* (the crank's blanket authorization covers it) while the *record* of that
  satisfaction goes missing. This is a **process gap**, not a one-ticket fix — per the
  [[level-set]] loop's own step 4, it belongs in front of [[decision]] next round, not
  quietly patched here.
- **Still-open gate:** [[decision-rights]]'s own banner and [[ledger-037-decision-loop-sample]]
  already flag that its `proposed → active` flip is **provisional**, pending the
  Owner's explicit confirm-or-rollback. Carrying it forward here rather than letting it
  go stale silently — exactly the kind of thing this loop exists to keep visible.
- **Lesson applied, not re-opened as debt:** the rate-limit recurrence (three times
  this window) is why [[resource-budget]] exists and why this loop's own "Spawn
  discipline" section cites it directly — no new ticket needed, the standard already
  answers it; this round is itself evidence the loop reads it before fanning out.

## Ranked paydown-and-lessons plan
1. **(Process, → [[decision]], not a ticket)** Tighten what "Owner-gated Done" requires
   — at minimum, a ticket flipped to `done` under an Owner-gate must carry either a Done
   note citing the gate satisfaction or a [[ledger]] entry, the way [[work-034]] and
   [[work-028]] did. Cheapest, highest-leverage item this round; recommended as the next
   [[decision]]-loop input, owned by CoS, CKM consulted (it's a doc-standards edge).
2. **[[work-036]]** — highest-leverage ticket in the queue once the Owner reviews the
   spike gate: unblocks two other tickets and this cycle's whole transparent-delegation
   thread. No status change; re-affirmed as the top pick once unblocked.
3. **[[work-037]] / [[work-031]]** — correctly queued behind work-036; no action.
4. **work-042 (new, filed this round)** — `[[work-042|Verify + close the --sc-success
   a11y follow-up deferred by work-027]]`: cheap, concrete, closes a real deferred item
   instead of leaving it silently unresolved after work-041 shipped the token.
5. **[[work-004]]** — real, but not cheap: needs a CI agent-runner spike staffed by CTO
   before it's actionable again; ranked lowest of the concrete items on cost, despite
   being the oldest open ticket.

## Track selection — Owner-gated, left pending (loop step 5)
Per the [[level-set]] loop's own design, this is where the round **stops** absent the
Owner: the plan above is a proposal, not an executed track. [[work-033]] itself is being
held open pending Owner approval for the same reason (a new core loop is Owner-gated) —
so this dry run intentionally does not presume a track. New: [[work-042]] (`proposed`,
low priority, cheap enough to queue normally). No other ticket status changed by this
round.

## Outcome
Demonstrates steps 1 (convene, scoped), 2 (assess: debt + reflection), 3 (CRO
spot-check: not invoked — no convergent finding rose to load-bearing this round, single
hat), 4 (synthesize: ranked plan above), 6 (tie-in: [[work-042]] filed), and 7 (this
entry, becoming `since` for the next cadence count). Step 5 (Owner track pick) is
correctly left open, not fabricated. Satisfies [[work-033]]'s acceptance: "one dry-run
through it produces a ranked, ticketed paydown plan."
