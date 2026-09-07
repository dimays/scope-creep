---
name: ledger-043-staffing-cadence-self-tuning
description: The Chief of Staff made the staffing-review cadence automated and self-tuning — seed 14 days, bounds 7–42, with the live interval tracked per run in the ledger and the CoS dialing it down on empty runs / up when an ad-hoc run beat the schedule. The schedule is now a staff-driven decision, not a fixed config the Owner edits. Lands via PR under Owner approval.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 043 — Self-tuning staffing-review cadence

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff

## Why
The Owner asked for the [[staffing-review]] loop to run **automatically** *and* be
**self-tuning**, with the cadence owned by the CoS as a staff-driven decision rather than a
fixed cron the Owner hand-edits: "if the loop kicks off too frequently, the CoS should pick up
on that signal and dial it down; if the CoS determines it needs to run ahead of its scheduled
time, it should reflect and consider dialing the frequency up." The loop previously carried a
**fixed 3-week** time interval — a config, not a decision.

## What changed
- **New "Cadence (self-tuning, CoS-owned)" section** in [[staffing-review]] defining the
  home, the seed, the protocol, and the reschedule contract.
- **Two homes, split by what moves:**
  - **Policy (stable, core-gated):** `metadata.cadence` (seed) + `metadata.cadence_bounds`
    (min..max) + the protocol live in the loop manifest. Changing the mechanism is a
    [[core-upgrade]].
  - **State (live, self-tuned):** the current interval is the most recent staffing-review
    ledger entry's `next_cadence_days`. Moving it is ordinary loop output (a ledger append),
    so self-tuning needs **no core edit and no gate** — automated without routing around
    [[invariants]] §I.4. The manifest seed only serves the first run.
- **Initial cadence: 14 days (2 weeks)**, plus the unchanged event triggers (10 spin-ups/
  retirements; post-template-land; post-model-catalog change). Tighter than the old fixed
  3 weeks because the roster is young and churning ([[adr-020]] just seeded 13 templates);
  self-tuning is expected to relax it as the roster settles.
- **Bounds: 7–42 days.** Floor stops thrash; ceiling stops dormancy. All computed intervals
  are clamped and rounded to whole days.
- **Self-tuning protocol (new step 7 of every run):**
  - **Too frequent → dial DOWN:** last **2 consecutive scheduled runs empty** → `× 1.5`
    (clamped to max).
  - **Too slow → dial UP:** **≥1 ad-hoc run since the last scheduled run** → `÷ 1.5`;
    **≥2 ad-hoc runs → `÷ 2`** (clamped to min). Ad-hoc runs are logged (a `cadence-decision`
    block marked `trigger: ad-hoc`) so they can be counted — the Owner's named "it ran ahead
    of schedule" signal.
  - **Neither → hold.** If both fire, **too-slow wins** (responsiveness beats economy).
    The CoS may override the default with a recorded one-line reason; bounds are never
    overridable.
- **Reschedule contract:** every run appends a `cadence-decision` YAML block (trigger,
  signals, decision, `next_cadence_days`, reason) to its ledger entry. The operating session's
  recurring trigger reads the **most recent** entry's `next_cadence_days` and sets its next
  fire that many days out. One moving value, explicit and simple.
- **Cross-doc:** [[staffing]] §6 now points at the self-tuning cadence; the loop's Steps
  (added step 7 "Tune the cadence", renumbered Record → step 8), Inputs (`cadence_days`),
  Outputs, and Termination were updated to match. Loop `version` → 1.1.0, standard → 1.0.1.

## Registry / gates
- **No harvested field changed.** `registry/loops.json` harvests only name/kind/status/
  description/owner_agent/path; `metadata.cadence` is not harvested, so the registry stays in
  sync (regenerated to confirm — no diff). Green: `docs:lint`, `registry:check`, `work:check`.

## Governance
- **CoS-owned decision.** The cadence is the CoS's to set and revise per its staffing mandate
  ([[adr-018]], [[adr-020]], [[staffing]]); this records that the *mechanism* is now in place.
- **Owner-gated landing.** Touches a core loop manifest + a standard; **lands via PR under
  Owner approval** ([[invariants]] §I.4 / [[adr-014]]). The CoS opened the PR; the Owner
  disposes by merging. Not merged by an agent.
- **Reversible** (§III.10): the whole change is one diff.

## Follow-up (operating session, not this repo)
- Wire an actual recurring trigger (scheduled task) that fires [[staffing-review]] and reads
  the latest ledger entry's `next_cadence_days` to set its interval; seed the first fire at
  **14 days**.
