---
name: ledger-046-loops-scheduled
description: The roadmap and evolve loops (ADR-021) are now automated as scheduled cloud routines, joining the staffing-review routine. Records the three recurring runners, their cadences, and the self-gating mechanism. dev-cycle stays event-driven (no routine).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 046 — Roadmap + evolve loops scheduled

**Date:** 2026-09-06 · **Recorded by:** the operating session, Owner-directed.

## What
The two time-scheduled loops from [[adr-021]] now have automated recurring runners
(scheduled cloud routines, `claude-sonnet-5`, source `github.com/dimays/scope-creep`),
joining the [[staffing-review]] routine ([[ledger-044-staffing-loop-automated]]):

| Routine | id | Cron (floor) | Self-gates to | First run |
|---|---|---|---|---|
| Staffing review | `trig_01D3wGKgqvTAwEV7Y5avk7tf` | weekly | 7–42d (its own live value) | 2026-09-07 |
| Roadmap planning | `trig_017Pa47QSG5qmb9gtQxfEbDR` | 1st & 15th | 14–90d | 2026-09-15 |
| Org evolve | `trig_01JviGNe4nFX63ZLoMWucMT6` | 1st monthly | 30–90d | 2026-10-01 |

**[[dev-cycle]] stays event-driven** (request batch / chosen track / Owner kickoff) — no
routine.

## Mechanism (same as staffing-review)
Each routine's cron is the cadence *floor*; each fire **self-gates** — reads the loop's most
recent ledger cadence value and runs the full loop only when due (`last run + cadence ≤
today`), else exits in seconds. So the *effective* cadence self-tunes within bounds while the
cron stays fixed. [[evolve]] owns the cadence *policy/bounds* for all scheduled loops (a
[[core-upgrade]]) and the live value for loops that don't self-tune; [[staffing-review]] owns
its own live value. On a due run each routine audits/plans, **tickets/ADRs its findings, and
opens a proposal PR** — never merges/deploys/spends (human-gated, INVARIANTS §III; the [[ceo]]
cannot approve a core-upgrade, [[adr-018]]).

## Build follow-ups (from the ADR-021 TODO, for the board / the loops to generate)
The loop *mechanics* still need building as tickets: the code-review cycle (review budget +
standards checklist + PR-push trigger), release-notes generation, the roadmap "since-last"
data harvest, and extending `metadata.mode`/`cadence` → registry wiring to the new loops.
The Console surfaces for viewing all this are [[prd-console-operations]] ([[work-051]]–056).

## Manage
All three routines: https://claude.ai/code/routines
