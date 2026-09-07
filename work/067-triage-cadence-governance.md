---
id: work-067
title: Triage cadence governance — self-tuning sweep frequency, ledger-tracked
type: feature
status: proposed
priority: medium
owner: chief-of-staff
spec: prd-request-loop
created: 2026-09-07
updated: 2026-09-07
---
The [[request-triage]] sweep starts hourly, but per the Owner's direction ([[prd-request-loop]]
Q4) the frequency should **not stay a hard-coded guess** — it should self-tune on real
signal, the way [[staffing-review]], [[roadmap]], and [[evolve]] already do. This ticket
makes a standing function accountable for that frequency.

Build:
- A **`cadence-decision` protocol** for [[request-triage]]: on each run, weigh the signal —
  empty sweeps (too frequent), backlog latency (too slow), how often the Owner is pulled in
  — and emit a `cadence-decision` block to the [[ledger]] (`ran_at`, `trigger`,
  `next_cadence`, `reason`).
- `cadence_bounds` so tuning stays inside a sane range; the live cadence is read from the
  most recent ledger block, not duplicated elsewhere.
- Once the routine is registered on claude.ai, its `registry/routines.json` entry carries
  `cadence_bounds_days` alongside the other scheduled routines.

**Acceptance:** every `request-triage` run records a `cadence-decision` block; the sweep
frequency moves within bounds in response to real signal (not manual edits); the routines.json
entry (once registered) lists `cadence_bounds`. See [[prd-request-loop]], [[request-triage]],
[[staffing-review]].
