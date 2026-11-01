---
id: work-134
title: Close the scope-creep propose-only duplicate PR queue and fix the pattern that keeps regrowing it
type: debt
status: proposed
priority: high
owner: git-manager
spec: adr-021
created: 2026-11-01
updated: 2026-11-01
---

`scope-creep` currently has **17 open PRs**, almost all daily `board-hygiene`/`staffing-review`
housekeeping output: `#142`/`#150`/`#157`/`#159`/`#160`/`#166`/`#168`/`#171`/`#173`/`#176`/
`#178`/`#181`/`#182`/`#184`/`#186`/`#188`/`#190`. Each goes `mergeable_state: behind` the day
after it opens, because the next day's run opens a fresh PR off a fresh branch instead of
updating the existing one. `work-sweep`'s own diagnosis ([[ledger-125-work-sweep-twenty-first-cadenced-run]])
confirms the [[adr-027]] routine-reviewer **is** running hourly against these PRs and approving
them — it cannot merge them only because they're stale against `main` by the time it looks.
The close-and-consolidate recommendation has been repeated for **ten consecutive** board-hygiene
cycles and **twenty-one consecutive** work-sweep cycles with no action.

This is a double problem: (1) the existing 17 PRs need disposing, and (2) whatever opens the
next one will recreate the pile tomorrow unless the pattern itself changes.

## Acceptance
- The 17 named PRs are each either merged (if still current and safe) or closed as superseded
  by a later entry — zero left open with `mergeable_state: behind` and no path to land.
- `board-hygiene` (and any sibling daily-PR routine) is changed to **update one open PR per
  loop** (push new commits to the existing branch) rather than opening a new PR each run, so
  the queue cannot regrow this way. This is a change to routine/loop mechanics —
  [[git-manager]] scopes it; if it touches a `loops/*.md` file or `registry/routines.json`,
  route that piece through [[core-upgrade]], Owner-approved, per [[adr-021]] §E.
- A ledger entry records the cleanup (count closed/merged, before/after queue depth).

## Notes
Surfaced repeatedly by [[work-sweep]] (ledger-088 through ledger-125) and `board-hygiene`
(ledger-124/126), never actioned because "cadence changes are Owner-gated" and no one had
scoped the fix as a ticket. Named in [[roadmap-003]] Theme 0 as a precondition for any new
theme work being staffed.
