---
id: work-132
title: Wire level-set to an actual cadence trigger (it has never fired on schedule)
type: bug
status: proposed
priority: high
owner: cto
spec: adr-021
created: 2026-10-01
updated: 2026-10-01
---

[[level-set]]'s own "When this loop fires" section says its cadence is **mechanical, not a
judgment call**: every 15 tickets landed `done`, or 2 calendar weeks, whichever comes first.
Unlike [[staffing-review]], [[roadmap]], and [[evolve]] ([[ledger-046-loops-scheduled]]),
**level-set was never wired to a scheduled cloud routine or any other automatic trigger** — there
is no entry for it in `registry/routines.json` and nothing else counts `done` tickets against its
last ledger entry on a cadence. The count is only ever run by whoever happens to think to do it.

**Evidence (2026-10-01, first [[evolve]] round):** the last completed level-set activity is
[[ledger-038-level-set-dry-run]], dated **2026-09-06** — itself an acceptance dry-run that, per
the loop's own design, stopped short of a real round ("parks here until the Owner selects a
track"). Since then: **81 of 125 work tickets** have landed `status: done` (5.4x the 15-ticket
trigger) and **25 days** have elapsed (1.8x the 2-week trigger). The trigger condition has been
true, by a wide margin, for most of the org's life, and the loop has not run once in that window
— not because nothing was due, but because nothing ever checks.

This is the mechanical sibling of [[work-122]] (cadence-*decision* blocks aren't being emitted):
here the loop doesn't even get a chance to decide, because nothing invokes it at all.

## Acceptance
- level-set's trigger condition (15 done-tickets-since-`since` OR 2 weeks-since-`since`) is
  checked automatically, not left to a human or agent noticing — either (a) a dedicated
  lightweight scheduled routine mirroring the [[roadmap]]/[[staffing-review]]/[[evolve]] pattern
  (self-gating cron + `registry/routines.json` entry), or (b) piggybacked onto an existing daily
  routine that already reads `work/*.md` (**[[board-hygiene]]** is the natural host — it already
  counts/reconciles the board daily) emitting a "level-set is due" signal/ticket when the
  condition trips. Pick whichever is cheaper to build and lower blast-radius; a 7th standing cron
  is not obviously better than extending one that already runs.
- Once wired, a real level-set round actually executes end-to-end (past the dry-run's stopping
  point) and lands a ledger entry.
- `loops/level-set.md`'s "When this loop fires" section is trued up to describe the actual
  mechanism, not an aspirational one.

## Notes
Surfaced by [[evolve]]'s first scheduled round ([[ledger-083-evolve-first-run]]), step 3
(scheduled-loop portfolio review) — verdict for level-set: **missing automation**, not a cadence
value to retune (`retune-live` doesn't apply; level-set has no live-retune path per its own
manifest). Registering a new/changed routine and `registry/routines.json` entry is a core change
— route through [[core-upgrade]], Owner-approved, per [[adr-021]] §E. CRO-checked: verified need
(measured counts above), not speculative.
