---
name: ledger-051-overnight-eng-loop
description: The overnight engineering-loop batch (2026-09-06→07, Owner-directed "keep churning through the night"). Shipped the console operations surfaces (Schedules/Releases/Roadmap), dark-only across the design package + console, and Threads link-out cards — completing the work-044 epic. Records the tickets closed and the PRs that landed them.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-07
---

# Ledger 051 — Overnight engineering-loop batch

**Date:** 2026-09-06 → 07 · **Recorded by:** the operating session, Owner-directed
("keep churning as much as you can through the night … keep on rolling!").

## What shipped
A full pass over the Proposed shelf's team-ready tickets, each built → tested →
gated-PR → landed (author≠merger held where it mattered; routine console/design PRs
merged under the Owner's standing approval, ADR-014 delegated execution — ADR-022 not
yet fully active pending the Owner's INVARIANTS apply, PR #49).

| Ticket | What | PR |
|---|---|---|
| [[work-054]] | Console **Releases** surface (newest-first, links to notes) | console #45 |
| [[work-056]] | Console **Roadmap** surface (latest deck + history) | console #45 |
| [[work-052]] | Console **Schedules** surface + loop cadence enrichment | console #46 |
| [[work-045]] | **Dark-only** across design package (v0.4.0) + console | design #4, console #47 |
| [[work-048]] | Threads **link-out cards** (PRs/tickets/docs/PRDs/ledger) | console #48 |
| [[work-044]] | Threads projection+launcher **epic — complete** (046 ✓ 047 ✓ 048 ✓) | — |

Plus, ahead of the batch: the founding **roadmap capstone** (`roadmap/001` + `releases/002`
+ MANIFEST v0.2.0, scope-creep #50) and the ADR-022 **activation PR** (#49, awaiting the
Owner's INVARIANTS apply — the one step an agent cannot perform, §I.2).

## Honest notes
- **Dark-only** required a design-package release: `@scope-creep/design` v0.4.0 (tokens
  promoted to a single dark `:root`, `color-scheme: dark`, light branch dropped), **tagged
  `v0.4.0`** (a plain git tag on a private git-dependency repo — version control, not an
  outward `publish`; the guard allows it) so the console could re-pin. It jumped the
  never-tagged v0.3.0 (work-043), whose text-variant follow-up is moot in dark-only (the
  `-text` tokens equal their fills).
- **Consistency polish carried further:** `000-template.md` files are now excluded from the
  console's doc browser + link index + consistency check, and `releases/` + `roadmap/` joined
  the doc namespace — so `[[release-001]]` / `[[roadmap-001]]` resolve everywhere.
- **Blocked, deferred honestly (Owner action):** [[work-036]] delegation-capture hook lives in
  `.claude/` (an agent cannot write it); [[work-031]] + [[work-037]]'s *activity* half depends on
  that hook's `activity/*.ndjson`, so they render honest-empty until it lands; [[work-004]]'s
  metered in-CI runner stays behind Owner spend approval (its no-spend launcher path is the
  live scope). [[work-042]] (Vite HMR live preview) is a larger build, not started.
