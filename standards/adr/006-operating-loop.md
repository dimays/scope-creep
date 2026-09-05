---
name: adr-006
description: Adopt the ticket-cycle operating loop — retro-driven, governed, terminating — with CPO + CTO revisions.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# ADR-006: The operating loop (ticket-cycle)

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** Owner (proposed the loop), CPO + CTO (reviewed), Chief of Staff (ratified)
- **Owner-gated:** yes

## Context
The Owner proposed a fundamental loop: after each ticket, review the work → create/
delete/modify/reprioritize tickets → continue until human input or a blocker (e.g.
token limits). The CoS convened the CPO (lifecycle/priority) and CTO (safety/
resumability) to evaluate it. As proposed it was directionally right but violated
two invariants and had safety gaps.

## Decision
Adopt the loop as [[ticket-cycle]] with these binding revisions:

1. **"Delete" → supersede.** Never `rm` a work record (trips the §III delete gate,
   breaks replay). Terminal states: `done | superseded | dropped`, with a ledger note.
2. **Machine-checkable termination** ([[invariants]] §IV.12): priority floor +
   ticket/commit budget + a **backlog-growth alarm** (created > closed for N cycles
   → halt + escalate).
3. **New scope is human-gated.** Agents create only tickets that trace to an
   existing `spec`; anything implying a new PRD/ADR is a proposal to the Owner.
4. **Definition of Done** = acceptance met + green gate + honest tests + PR links
   the spec. Done is a gate state, not an assertion.
5. **WIP cap** (≤ 2 active workstreams); `proposed` is an inbox; evidence-gated
   reprioritization with hysteresis (anti-thrash).
6. **Resumability from records:** every start/stop/finish commits `work/` + `ledger/`
   state; add an optional `branch:` field; `spec` becomes required in `work:check`.
7. **Two run modes:** propose-PR (Owner merges) now; gated-autonomous after
   `work-003` (branch protection + widened `guard-gates.sh` + core-path Write-fence).

## Consequences
- The loop is safe to run semi-autonomously and resumes cleanly after a hard stop.
- Backlog ranking ratified: **003 → 005 → 006 → 001 → 004 → 007**; `work-003` raised
  to high as the precondition for gated-autonomous mode.
- Full STOP checklist and per-iteration protocol live in [[ticket-cycle]].

## Alternatives considered
- **Run the loop as literally proposed** — rejected: no termination, `rm`-deletes,
  and "never merge red" riding on agent goodwill (which [[tech-sops]] §5 forbids).
- **Fully autonomous from day one** — rejected: unsafe until branch protection makes
  the gate mechanical. Propose-PR mode bridges the gap.
