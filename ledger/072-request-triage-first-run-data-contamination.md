---
name: ledger-072-request-triage-first-run-data-contamination
description: First scheduled run of the request-triage hourly cloud routine (2026-09-22). Outcome — BLOCKED on triage, nothing fabricated. The sweep returned 180+ "new request" threads from the real ADR-024 shared Turso store, but every one of them is test-fixture data (titles/bodies matching the console's own vitest suites, repeated across ~6 near-identical batches) despite vitest.config.ts pinning test runs to DATABASE_URL=":memory:". Rather than triage fixture noise as real Owner asks, the routine declined all of them, filed work-113 (investigate the leak + propose Owner-gated cleanup), and posted a needs-input card to thread 9. No tickets were fabricated from the contaminated data, no deletes were attempted (STOP-gated), and no other write-backs were made.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-22
---

# Ledger 072 — request-triage first run (data-contamination finding)

**Date:** 2026-09-22 · **Trigger:** scheduled `request-triage` cloud routine
(`trig_01L1ZuWXmRE1quiLGP3mv9ni`, hourly `:17`), first live sweep since [[adr-025]]/[[work-066]]
registered it · **Outcome:** **BLOCKED on triage — nothing fabricated, nothing deleted.**

## What ran
Per [[request-triage]] Step 1, ran `npm run triage -- sweep` (Node/tsx, per [[adr-024]]) from the
`scope-creep-console` checkout against the real shared store
(`libsql://scope-creep-console-maysidavid.aws-us-east-1.turso.io`, [[adr-024]]/[[adr-025]]).

## What the sweep returned
180+ threads matching `kind = request`, `initiator = owner`, no `role = agent` reply, non-archived
— but on inspection every single one is test-fixture data, not a genuine Owner ask:

- **Exact title/body matches** to fixtures in `app/lib/triage.server.test.ts`,
  `app/lib/threads.server.test.ts`, `app/lib/work-sweep.server.test.ts`, and
  `app/routes/route-entrypoints.test.ts` — e.g. thread 12 `"Ship the queue"` /
  `"Please build the needs-you queue."`, thread 47 `"Add a dark mode toggle"` /
  `"Please add dark mode."`, thread 366 `"Round-trip via route"` / `"Archive then restore."`.
- **Repeated in ~6 near-identical batches** spanning roughly 2026-09-21T23:14–23:32Z (the same
  ~26 titles, same order, each batch a few seconds apart) — the signature of a script/test run
  re-executed repeatedly against the live store, not organic Owner activity.
- **6 older rows** (`"a work request"`, ids 11/67/123/200/256/312) frozen at the placeholder
  epoch `created_at = updated_at = 1700000000000`, also `status = "working"` set directly (never
  through the [[work-064]] writers) — further evidence of direct DB manipulation.
- **`vitest.config.ts` pins `DATABASE_URL=":memory:"`** for the console's own test runs, so an
  ordinary test invocation cannot explain this. Root cause is undetermined — most likely a manual
  QA/dry-run session (of this feature or the Threads UI) invoked with the real
  `DATABASE_URL`/`DATABASE_AUTH_TOKEN` exported, reusing the test suite's own scenario data as a
  script. Total store size: 365 conversations, 322 of them `kind=request, initiator=owner` — i.e.
  **the shared production store is now mostly test noise.**

## Decision (CRO + CPO lens, per request-intake Step 2)
Triaging 180+ fixture threads as real requests would have fabricated ~180 tickets/decisions from
noise — a far larger and more damaging scope explosion than doing nothing. **None of the swept
threads were triaged, declined, or ticketed as if genuine.** This is not the "no new requests"
case either (the sweep did return rows) — it's a data-integrity blocker the routine is not
positioned to guess through.

## What was done instead
1. **Filed [[work-113]]** (`proposed`, `owner: cto`, `priority: high`) — investigate the leak
   path and propose a guard (host-check or separate QA/scratch DB) plus a reviewed, Owner-gated
   cleanup script. The ticket explicitly does **not** perform any delete — purging contaminated
   rows is a STOP-gated action ([[invariants]] §7) reserved for the Owner at the moment of
   execution.
2. **Posted a `needs-input` card to thread 9** ("Request: Planned Work Routine" — the standing
   status thread other scheduled routines report into, e.g. [[ledger-062]], [[ledger-071]]),
   summarizing the finding and linking [[work-113]]. Thread 9 was already `needs-you` for
   unrelated open items; this write-back keeps it there.
3. **No write-backs were posted to the 180+ contaminated threads.** Marking fixture rows
   `declined`/`working` would only add more synthetic activity to an already-polluted store,
   and buys nothing — real cleanup is a delete, not a status change.

## Cadence
No `cadence-decision` block this run — the blocker is data integrity, not sweep frequency or
Owner-pull rate, so [[work-067]]'s self-tuning signal doesn't apply here. Cadence stays at the
registered hourly default (`registry/routines.json`); next run should return a clean sweep once
[[work-113]] lands, or the same contamination if it hasn't.

## Disposition
Parked on the Owner via [[work-113]] and the thread-9 card. This routine's job ends here — it did
not delete data, did not merge anything, and made no judgment calls on data it couldn't trust. See
[[request-triage]], [[request-intake]], [[adr-024]], [[adr-025]], [[adr-022]].
