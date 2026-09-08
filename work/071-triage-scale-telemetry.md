---
id: work-071
title: Emit triage scale-telemetry to the ledger
type: feature
status: proposed
priority: high
owner: chief-of-staff
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The only near-term build in [[prd-end-user-feedback-at-scale]]: make the scaling **triggers
measurable** so later phases turn on from real signal, not a hunch. Folds into the
[[request-triage]] sweep build ([[work-066]]) — **no separate system**, just extra fields on
the `cadence-decision` block the sweep already appends to the [[ledger]] ([[work-067]]).

**Signals to emit each sweep** (alongside the existing cadence signals):
- `open_threads` — concurrent open/`needs-you`/`working` threads at sweep time.
- `new_threads_this_sweep` — count triaged this run.
- `dedup_merges` / `dedup_misses` — asks converged vs duplicate tickets later caught (seed at 0 until [[work-072]] lands; the field exists so the trend is visible from day one).
- `per_app` — the same counts keyed by system, so cross-app volume is visible the moment app #2 ships.

**Acceptance:** the [[request-triage]] ledger block carries the fields above; a reader can
evaluate triggers **T2/T3/T4** from [[prd-end-user-feedback-at-scale]] directly from ledger
history with no new tooling. Purely additive to an existing ledger write — no new store, no
STOP-gate surface.

**Trigger:** now — sequenced to land **with** [[work-066]] so telemetry exists before volume does.
