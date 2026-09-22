---
name: ledger-069-board-hygiene-first-run-canary
description: Record of the first supervised board-hygiene run (2026-09-22) — the ADR-026 propose-only write-path canary (docs/owner-apply-board-hygiene-routine.md Step 2). The routine opened dimays/scope-creep#101 as the forced sandbox-proxy identity (dimays, confirmed via get_me — not @scope-creep-review), applying 2 mechanical status<->reality corrections (work-096, work-097 -> done) and surfacing 20 stale-proposed tickets for the Owner/CPO to disposition. Un-pause criteria 1 & 2 captured live (POST /git/refs -> 201; POST /pulls -> 201 as the proxy identity); criteria 4/6 were not tested here (the routine never attempts a merge, per its own propose-only mandate) and remain for the reviewer/merge step or a dedicated follow-up to observe. Outcome posted to the owning thread (scope-creep-thread:9) via the work-064 writers.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-22
---

# Ledger 069 — board-hygiene first run (ADR-026 write-path canary)

**Date:** 2026-09-22 · **Trigger:** scheduled `board-hygiene` cloud routine, first supervised run
· **PR:** [dimays/scope-creep#101](https://github.com/dimays/scope-creep/pull/101) — **holds for
`@scope-creep-review`; nothing merged by the routine.**

## What ran
Per [[board-hygiene]] and `docs/owner-apply-board-hygiene-routine.md` Step 2, this is the **first
supervised execution** of the [[adr-026]] propose-only write path — the smallest, most-reversible
change surface in the system, deliberately run before [[work-sweep]] is trusted with real builds.

**Setup:** `scope-creep-console` deps installed via `bun install`; `SCOPE_CREEP_HOME` exported to
the `scope-creep` checkout; ran read-only board diagnosis + the write step over REST via the
GitHub MCP tools (the sandbox's supplied auth — no token minted or presented).

## Diagnosis (read-only, against [[work-readme]] reality)
- **Status↔reality drift — 2 found, both applied:**
  - [[work-096]]: `active` → `done`. Its gating PR
    [#97](https://github.com/dimays/scope-creep/pull/97) (ADR-026) merged to `main`
    2026-09-21T23:53:06Z; the ticket's own text ties its `done` flip to that merge.
  - [[work-097]]: `review` → `done`. Its gating PR
    [#96](https://github.com/dimays/scope-creep/pull/96) (PM maturity: `review` state +
    board-hygiene loop) merged to `main` 2026-09-21T23:48:59Z.
  Both edits set `pr:` to the merged PR URL and bumped `updated: 2026-09-22`. No file was `rm`'d.
- **WIP-cap violations:** none — only 1 ticket was `active` (work-096, corrected above) against
  the cap of 2.
- **Stale `proposed` tickets (flagged, not touched):** 20 tickets unchanged since 2026-09-07/08
  (≥14 days) — work-067 through work-085 continuous, plus work-088. (Ticket `work-069` is one of
  the 20; unrelated to this ledger entry's own number 069 — a coincidental collision between two
  separate id spaces.) Surfaced in the PR body as a checklist for the Owner/CPO; hygiene never
  retires a ticket.
- **Schema faults:** none — `bun run work:check` → `99 work items OK` both before and after the
  edits (edits only changed `status`/`pr`/`updated` on 2 existing tickets).

## The write-path canary evidence
- **Criterion 1 (branch creates):** `POST /git/refs` for
  `board-hygiene/2026-09-22-status-reconciliation` off `main` → **201**.
- **Criterion 2 (PR opens as the proxy identity):** `POST /pulls` → **201**,
  `dimays/scope-creep#101`. `mcp__github__get_me` confirms the acting identity is **`dimays`**
  (the shared Claude GitHub App's forced login), **not** `@scope-creep-review` — matches
  [[adr-026]]'s predicted mechanism exactly. GitHub's own `mergeable_state` on the resulting PR
  already reads `"blocked"` (the required code-owner review is unsatisfied), consistent with
  criterion 4's expected outcome.
- **Criterion 4 (merge blocked):** **not directly exercised.** This run's mandate is
  propose-only — "open exactly ONE PR and STOP... never merge" — so no `PUT /pulls/101/merge`
  was attempted from the sandbox, even as a test. The `mergeable_state: "blocked"` observation
  above is suggestive but not a substitute for the documented criterion-4 probe; that probe (if
  wanted) belongs to a deliberately-scoped follow-up, not this routine.
- **Criterion 6 (honest degradation):** not exercised — no 403/permission error occurred on this
  run (grant is live, both REST calls succeeded cleanly). Nothing to report; would have produced
  a `needs-you` card naming the cause had it fired.
- **Net:** criteria 1 & 2 **PASS** with direct evidence; criterion 4 has strong indirect evidence
  (`mergeable_state: blocked`) but wasn't the documented direct probe; criterion 6 is untested
  (no failure occurred to exercise it). Falls short of a clean "all of 1/2/4/6 captured" — the
  Owner/CoS should treat the Tier-1 un-pause as **provisionally supported, not fully closed**,
  pending either a direct (mock or real) criterion-4 merge-attempt observation and a criterion-6
  failure-path check, or an explicit Owner call that criteria 1/2 plus the `blocked` state are
  sufficient.

## Outcome posted
Critical-update posted to the owning thread (thread 9, "Request: Planned Work Routine") via
the [[work-064]] writers (`work-sweep write-back`, run under Node/tsx per ADR-024), thread status
left at `needs-you` (unchanged — the thread already carried open Owner items). Body: run summary,
PR link, criteria-1/2 evidence, the stale-proposed count.

## Disposition
PR #101 **holds for `@scope-creep-review`** (off-sandbox, per [[adr-026]]). This routine's job
ends here — it does not merge, does not clear its own hold, and made no judgment calls on the 20
flagged tickets. See [[board-hygiene]], [[work-readme]], [[adr-026]],
`docs/owner-apply-board-hygiene-routine.md`, [[ledger-068-scheduled-execution-automation-cycle]].
