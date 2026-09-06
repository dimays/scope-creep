---
id: work-033
title: A recurring level-set loop (periodic C-suite review + debt paydown)
type: feature
status: done
priority: medium
owner: chief-of-staff
spec: engineering-policy
created: 2026-09-05
updated: 2026-09-06
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

**Done (2026-09-06):** Added [[level-set]] (proper manifest matching [[decision]]'s
format, including `metadata.mode`). Cadence: every 15 tickets landed or 2 calendar
weeks since the last round, whichever comes first, plus ad hoc on Owner invitation.
Ties into [[ticket-cycle]] (accepted items become `work/` tickets) and widens beyond
debt per the Owner's reflection direction — mining the [[ledger]] (and, once populated,
`activity/*.ndjson`/[[work-036]]) for mistakes, reversals, and gate-catches, routing any
process-level finding through [[decision]] rather than silently patching it. Bakes in
the spawn-discipline lesson from [[resource-budget]] §2, citing the rate-limit
recurrence across [[ledger-027-level-set-round]], the incident that produced
[[resource-budget]], and again during tonight's [[ledger-036-overnight-crank]].
Acceptance dry-run recorded in [[ledger-038-level-set-dry-run]]: a single-hat (CoS-only,
zero-subagent) pass against the real repo state, producing a ranked plan and one new
ticket ([[work-043]]); Owner track-selection (loop step 5) correctly left pending, not
fabricated. **This is a new core loop — Owner-gated per [[invariants]] §I.4; the PR is
held open for Owner approval, not merged.**
