---
id: work-134
title: board-hygiene and work-sweep close their own superseded propose-only PR before opening the next one
type: debt
status: proposed
priority: medium
owner: cto
spec: adr-021
created: 2026-11-01
updated: 2026-11-01
---

Both [[board-hygiene]] and [[work-sweep]] open a fresh propose-only PR every run, and neither
loop ever closes the one it opened the run before. Each new PR's branch starts from that day's
`main`, so once it lands, every still-open PR from an earlier run of the *same* routine goes
`mergeable_state: "behind"` — not because anything conflicts, but purely because a later,
superseding PR from the identical routine landed first. Nothing currently closes the stale one;
the queue only grows.

**Evidence (2026-11-01, second [[evolve]] round).** The `board-hygiene` propose-only queue on
`scope-creep` is **fourteen PRs deep** and growing by roughly one per run:
`#150`/`#157`/`#160`/`#166`/`#168`/`#171`/`#173`/`#176`/`#178`/`#182`/`#184`/`#186`/`#188`/`#190`
(2026-10-06 through 2026-10-30). The close-the-duplicates recommendation was first made in
[[ledger-111-board-hygiene-status-reconciliation]] (2026-10-22) and has now been **repeated by
every board-hygiene and work-sweep run since** — a **tenth** consecutive cycle per
[[ledger-125-work-sweep-twenty-first-cadenced-run]] and [[ledger-126-board-hygiene-status-reconciliation]]
— without anything ever acting on it, because closing a PR is outside both loops'
propose-only authority as currently scoped (board-hygiene: status-field edits only;
work-sweep: ticket execution only) and no one else's job either. Each later PR's own diagnosis
already supersedes the one before it (the content isn't lost), so the PRs sitting open add
nothing but queue depth and reviewer confusion about which one is current.

This is a **recurring manual procedure** (the Owner/reviewer being asked, mechanically, to close
the same kind of PR every single day) with no automated owner — exactly the class of pressure
[[evolve]]'s step 2 scans for, not existing-domain debt for [[level-set]]: the gap is in the two
loops' own write-contract, not in a backlog item either loop would otherwise pick up.

## Acceptance
- `loops/board-hygiene.md` and `loops/work-sweep.md` each state: before opening this run's
  propose-only PR, if the routine's own immediately-prior PR from the same loop is still open
  and this run's diagnosis supersedes it (no human comment/review added since, no merge), **close
  it** (not merge, not force-push, not touch any other routine's PR) with a one-line comment
  pointing at the new PR. Closing one's own unmerged, author-owned proposal is not a
  deploy/spend/delete/publish action under [[invariants]] — confirm this reading explicitly in
  the core-upgrade PR rather than assuming it, since it is new ground for a propose-only loop's
  write authority.
- The fix only ever touches a PR opened by the *same* routine identity on its *own* prior run; it
  must never close [[staffing-review]]'s or [[roadmap]]'s PRs, or the escalation-class `#140`.
- Backfill: the existing fourteen-deep queue is closed once, by the Owner/`@scope-creep-review` or
  by this change's first run — whichever is cheaper — citing this ticket.

## Notes
Surfaced by [[evolve]]'s second scheduled round ([[ledger-127-evolve-second-run]]), step 2
(recurring manual procedure → new procedure). Core change (edits two loop files) — routes through
[[core-upgrade]], Owner-approved, per [[adr-021]] §E. CRO-checked: verified need (fourteen
concrete PR numbers, a ten-cycle unactioned recommendation already on record in two independent
loops' own ledger entries), not speculative. Deliberately narrow: it does not touch the deeper
"why doesn't anything land" bottleneck (see [[ledger-127-evolve-second-run]] Owner flags) — that
is gate-adjacent ([[adr-026]]/[[adr-027]] merge-authority territory) and stays a [[decision]]-track
question, not something this ticket or evolve disposes of unilaterally.
