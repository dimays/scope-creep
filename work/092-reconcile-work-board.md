---
id: work-092
title: Reconcile the work board — flip completed tickets to done so the sweep reflects reality
type: chore
status: active
priority: high
owner: chief-knowledge-manager
spec: prd-autonomous-execution-loop
created: 2026-09-21
updated: 2026-09-21
---
> **In-flight — lands via PR #90; flips to `done` on merge.** The board reconciliation is staged
> (8 tickets flipped, `ledger/063-work-board-reconciliation`) and holds for review.
The first `work-sweep` run ([[ledger-062-work-sweep-first-run]]) surfaced a **stale work board**:
the sweep's ready set and the ticket-cycle WIP cap are computed from ticket `status`, and several
tickets carry `active`/`proposed` while their work is actually **done and merged**. Concretely the
run saw **4 `active` tickets against a WIP cap of 2** (`atCap: true`) so it (correctly) started
nothing:

- **work-086 / work-087** — merged (console #67, #70; scope-creep #87) but still `active`, never
  flipped to `done`.
- **work-058 / work-059** — old [[adr-022]] rails, `active` but effectively shipped / parked on
  Owner-manual steps.
- Others in the ready set (`work-063`, `work-064`, …) are `proposed` but belong to shipped work
  ([[prd-request-loop]]).

Until the board reflects reality, the autonomous loop either sits at the WIP cap or chases
already-done work.

**Build:** a reconciliation pass over `work/*.md` — flip every ticket whose work has landed to
`done` (with the merge PR + a one-line note, per [[work-readme]] lifecycle; never `rm`), and
correct any `active`/`proposed` that no longer matches reality. Cross-check against `main`'s merge
history and the [[ledger]]. Leave genuinely-open tickets as-is. This is the [[chief-knowledge-manager]]'s
doc/registry-freshness remit, extended to the work board (relates to the reconciliation pattern in
[[ledger-059-capstone-merge-and-reconciliation]]).

**Acceptance:** the sweep's ready set contains only genuinely-ready work; no `active` ticket is
already merged/done; the WIP-cap count reflects true in-flight work; a [[ledger]] note records the
reconciliation. See [[prd-autonomous-execution-loop]], [[work-093]].
