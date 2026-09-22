---
id: work-113
title: Shared thread store (Turso) is contaminated with test-fixture threads
type: bug
status: proposed
priority: high
owner: cto
spec: adr-024
created: 2026-09-22
updated: 2026-09-22
---
Found by the first live [[request-triage]] hourly run (2026-09-22, [[ledger-072]]). The **real**
shared thread store (`libsql://scope-creep-console-maysidavid...`, the [[adr-024]] production
Turso DB) contains 350+ `conversations` rows whose titles and bodies are byte-for-byte matches to
fixtures in the console's own test suites (`app/lib/triage.server.test.ts`,
`app/lib/threads.server.test.ts`, `app/lib/work-sweep.server.test.ts`,
`app/routes/route-entrypoints.test.ts`) — e.g. `"Ship the queue"` / `"Please build the needs-you
queue."`, `"Add a dark mode toggle"` / `"Please add dark mode."`, `"Round-trip via route"` /
`"Archive then restore."` — repeated identically across ~6 near-consecutive batches spanning
2026-09-21T~23:14–23:32Z, plus 6 older rows (`"a work request"`, `created_at`/`updated_at`
frozen at the placeholder epoch `1700000000000`).

This matters because `vitest.config.ts` pins `DATABASE_URL=":memory:"` for test runs — so an
ordinary `bun test`/`npm test` invocation cannot be the direct cause. Something else (most likely
a manual QA/dry-run session — of this very triage feature or the Threads UI — invoked with the
real `DATABASE_URL`/`DATABASE_AUTH_TOKEN` in its environment, reusing the test suite's scenario
titles as a script) wrote real rows into the shared production store. Some contaminated rows
(e.g. thread 11) have `status = "working"` set directly, never via the [[work-064]] writers —
further evidence of direct DB manipulation rather than organic app usage.

**Impact:** [[request-triage]]'s `sweep` (`listNewRequestThreads`) returned 180+ of these as "new
owner request threads" on its first scheduled run. Triaging them as real asks would have
fabricated ~180 tickets/decisions from fixture noise — the routine correctly declined to do this
(see [[ledger-072]]) and parked the finding at `needs-you` instead of guessing.

## Scope
1. **Investigate the leak path** — identify what process/session ran against the real
   `DATABASE_URL` using test-suite-shaped data (a QA script? a manually-invoked test file that
   bypassed `vitest.config.ts`'s `env`? a dev-server QA session with prod creds exported?) and
   close it so test/QA runs cannot reach the shared production store again — e.g. a runtime guard
   in `db.server.ts`/`ensureSchema()` that refuses to run against the known prod Turso host unless
   an explicit `ALLOW_PROD_DB=1` escape hatch is set, or a distinct scratch Turso DB for manual QA.
2. **Cleanup — Owner-gated.** Purging the contaminated rows is a **delete** action
   ([[invariants]] §7 STOP gate) and is **not self-authorized** here. This ticket proposes the
   cleanup (a scoped `DELETE FROM conversations WHERE id IN (…)` / equivalent script, scripted and
   reviewable, run only with the Owner's explicit go-ahead at the moment of execution) but does not
   perform it.

## Acceptance
- A documented root cause for how test-fixture data reached the real Turso store.
- A guard that makes it structurally hard to repeat (env host-check, or a separate QA/scratch DB).
- A reviewed, Owner-approved cleanup script/PR that removes exactly the identified contaminated
  rows, run only under explicit Owner confirmation.
- A re-run of `request-triage sweep` returns only genuine Owner-initiated threads.

See [[adr-024]], [[adr-025]], [[request-triage]], [[ledger-072]].
