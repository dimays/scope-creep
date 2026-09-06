---
id: work-033
title: A recurring level-set loop (periodic C-suite review + debt paydown)
type: feature
status: proposed
priority: medium
owner: chief-of-staff
spec: engineering-policy
created: 2026-09-05
updated: 2026-09-05
---
From the Owner's org-design question + [[ledger-027-level-set-round]]. The level-set that
found the lying `/healthz`, the unratified RR8 bump, and the doc drift was run **ad hoc**.
Institutionalize it so the factory self-corrects on a cadence, not only when the Owner
notices something.

- Add `loops/level-set.md`: a recurring ritual — the C-suite (or a subset) each assesses
  its domain read-only, the CoS synthesizes a ranked paydown plan, the Owner picks the
  track. Triggered on a cadence (every N merged tickets, or a time interval) and always
  Owner-reviewable before execution.
- Define the trigger + the tie-in to the [[ticket-cycle]] (paydown items become tickets).
- **Reflection & evolution (Owner-directed 2026-09-06):** widen the loop's inputs beyond
  debt — mine the [[ledger]] (and, once it exists, the `activity/*.ndjson` log, [[work-036]])
  for **mistakes, reversals, and gate-catches** so the org learns from them, not only pays
  down debt. This is Theme 4 of the direction round; it extends this loop rather than adding
  a new one.
- Operational lesson to bake in: **stagger agent spawns / mix models** — the last dry run
  hit the session rate limit spawning five Opus agents at once.

**Acceptance:** a documented, repeatable level-set loop the CoS can run without bespoke
prompting; one dry-run through it produces a ranked, ticketed paydown plan.
See [[ledger-027-level-set-round]], [[engineering-policy]].
