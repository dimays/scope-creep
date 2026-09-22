---
name: ledger-069-request-triage-sweep-fixture-pollution
description: First real request-triage sweep (loops/request-triage.md) against the live shared thread store. scripts/triage.ts sweep returned 289 "new" owner-request threads, but content review found all 289 are pre-existing UI/QA test-fixture threads (dark mode toggle, archive/round-trip, launch flow, notifications, branching, etc. — repeated 6-9x in tight-timestamp batches, ids 11-366) created directly against the remote Turso store, not real Owner asks. Zero genuine new requests this run; no triage/write-back/tickets/PRs executed against the fixtures. One pre-existing genuine thread (scope-creep-thread:9) was correctly excluded by the sweep (already answered, parked needs-you since ledger-068). Flags the fixture pollution as a data-hygiene finding for CoS/Owner disposition rather than self-actioning (archive/delete) it.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-22
---

# Ledger 069 — request-triage sweep: fixture pollution in the shared thread store

**Date:** 2026-09-22 · **Loop:** [[request-triage]] (hourly scheduled sweep) · **Run:** first
sweep to actually execute end-to-end against the live remote store (`DATABASE_URL` = the
`scope-creep-console-maysidavid` Turso instance, per [[adr-025]]).

## What happened

Ran the loop mechanically per [[request-triage]] / [[adr-025]]: `bun install` in the console
checkout, then `npm run triage -- sweep` (Node/tsx path, per the CLI's own doc comment — `bun
run` is dropped by the cloud egress proxy). The sweep returned **289** threads matching `kind =
request`, `initiator = owner`, `archivedAt IS NULL`, no `role = agent` reply yet.

Before triaging 289 "requests" in one run, applied the CRO/CPO sanity-check [[request-intake]]
step 2 calls for. Read the full title+first-body-message for a representative of every distinct
title (46 distinct titles across the 289 rows) directly from `conversations` /
`conversation_messages`. Result: **every one of the 289 is a UI/feature test fixture**, not a
real Owner ask — bodies like `"a work request"`, `"Please add dark mode."` / `"Please build the
needs-you queue."` / `"Archive then restore."` / `"No branches here."` / `"test"` / `"1"` / `"2"`
/ `"…"`, ids in tight sequential clusters (~5-300ms apart) forming 6-9 repeated batches
(consistent with the same QA/exercise pass run 6-9 times against the **live** store with no
cleanup), plus a literal placeholder-epoch timestamp (`1700000000000`) reused across 6 rows all
titled `"a work request"`. `app/db/config.ts` defaults to a local file DB and `vitest.config.ts`
already isolates the unit-test run (`DATABASE_URL: ":memory:"`), so this did **not** come from
the project's own `vitest` suite — it reads as a manual/scripted exercise of the Console's thread
UI (archive/restore, branching, launch, notifications, badges, dark-mode) run straight against
the shared remote DB.

The one **real** pre-existing thread, `scope-creep-thread:9` ("Request: Planned Work Routine" —
the Owner directive already covered by [[ledger-068-scheduled-execution-automation-cycle]]), was
correctly **excluded** by the sweep's own filter: it already carries three `role = agent`
messages (two `needs-input`, one `critical-update`) and sits at `status: needs-you`. Nothing
about it changed this run — its disposition is still the Owner's, unchanged from ledger-068's
hand-off.

## Decision — no triage executed against the 289

Writing a `critical-update`/`needs-input` card, a decline, or a `work/NNN` ticket+PR against 289
QA-fixture rows would be actively wrong: it would fabricate triage outcomes for asks nobody made,
pollute the shared store the Owner-facing Console reads from with hundreds more synthetic cards,
and (for repeated bodies like "Please add dark mode.") could spawn duplicate tickets/PRs for a
feature no one is actually asking for right now. **Zero write-backs, zero tickets, zero PRs this
run.** This is the loop's own [[invariants]] posture applied honestly — data provenance is part of
"is this feasible / does it rest on an unverified assumption," and it didn't survive the check.

## Flagged, not actioned

The fixture rows themselves are a data-hygiene problem worth fixing (they will keep re-appearing
in every future hourly sweep, at real token/compute cost, until something clears them), but
**cleaning them up is out of this loop's charter** — `request-triage` triages *requests*, it does
not curate the thread store — and even a reversible action (archiving them) is a call this loop
was not asked to make. Surfacing for Owner/CoS disposition rather than self-authorizing:

1. **Root-cause the source.** Something (a manual QA pass, a smoke-test script, an agent
   exercising the Console's thread routes) is writing test threads straight at the **shared**
   `DATABASE_URL` instead of a local/isolated one. Worth finding and pointing at
   `file:./data/app.db` (the documented local default) or an ephemeral DB.
2. **Clear the existing 289.** Archiving (reversible, `archivedAt`) is the low-blast-radius option
   over deleting; either way it's a call for whoever owns the thread store's hygiene, not this
   loop, unattended.
3. **Consider hardening the sweep** — `listNewRequestThreads` (`app/lib/triage.server.ts`) has no
   way to distinguish a real Owner ask from a test-fixture row with `initiator = "owner"`; that's
   a legitimate limitation of "owner-initiated" as a proxy for "the Owner actually asked this,"
   worth a CTO/CPO look if fixture pollution recurs.

## Net for the loop

`request-triage` ran mechanically clean (sweep succeeded, no store outage, no dry-run needed) but
found **no genuine new requests** this cycle. Cadence unaffected — this is an empty-sweep-in-
substance outcome, not a runner failure. Next run should re-sweep; if the 289 fixture rows are
still present and still unanswered, they will reappear and cost the same triage-judgment pass
again until cleared.

See [[request-triage]], [[request-intake]], [[adr-025]], [[adr-024]],
[[ledger-068-scheduled-execution-automation-cycle]].
