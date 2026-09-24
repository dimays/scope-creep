---
id: work-122
title: Emit machine-readable cadence-decision blocks (close the work-067 done-vs-reality gap)
type: bug
status: proposed
priority: medium
owner: chief-of-staff
spec: adr-021
created: 2026-09-24
updated: 2026-09-24
---

The self-tuning-cadence design (documented across `registry/routines.json`'s note,
`standards/staffing.md`, and every scheduled loop's "Cadence" section) says the **live** cadence is
read from the most recent `cadence-decision` block (`ran_at`, `trigger`, `next_cadence_days`,
`reason`) in the [[ledger]]. The 2026-09-24 audit found **zero** machine-readable `cadence-decision`
blocks on disk — only protocol descriptions ([[ledger-043-staffing-cadence-self-tuning]], [[ledger-044-staffing-loop-automated]]) and one prose mention
([[ledger-062-work-sweep-first-run]]). So **every routine is effectively still on its seed cron**, not a self-tuned
value — yet [[work-067]] is marked `done` ("request-triage cadence-decision protocol is live"). A
done-vs-reality gap.

## Acceptance
- Scheduled routines emit a real, parseable `cadence-decision` block per run (or the mechanism is
  corrected so they do), and at least one live block exists per active routine.
- Whatever is decided, `work/067` and the loops' "Cadence" prose are trued up to match reality
  (either the mechanism is fixed, or the docs stop claiming a live mechanism that isn't emitting).

## Notes
Surfaced by the autonomy-layer audit. Owner: CoS (owns the loop/cadence system). Low user-visible
impact today (seed crons are sane), but it means the advertised self-tuning is not actually running.
