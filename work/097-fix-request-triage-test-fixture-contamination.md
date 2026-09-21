---
id: work-097
title: Root-cause and remediate test-fixture contamination of the live shared thread store
type: bug
status: proposed
priority: high
owner: cto
spec: adr-024
created: 2026-09-21
updated: 2026-09-21
---
The 2026-09-21 [[request-triage]] scheduled run found the shared thread store's `conversations`
table (the live remote at `DATABASE_URL=libsql://scope-creep-console-maysidavid...`, [[adr-024]])
contains **289** unarchived `kind=request` / `initiator=owner` threads, of which at least 288 are
mechanically-duplicated test fixtures — not genuine Owner asks. See [[ledger-068-request-triage-sweep-db-contamination]]
for the full evidence (title histogram with 6–9x repeats, byte-identical message bodies across
repeats, titles/bodies matching `app/lib/triage.server.test.ts` / `app/lib/threads.server.test.ts`
in `scope-creep-console`, and a batch pinned to the literal placeholder timestamp `1700000000000`).

**Why this matters:** `vitest.config.ts` sets `DATABASE_URL: ":memory:"` for the `vitest run`
path, so an ordinary `npm test` should not be able to reach the live remote — something else
(a script or session invoking the same fixture-seeding helpers, or a test file run outside the
vitest harness, with the real `DATABASE_URL`/`DATABASE_AUTH_TOKEN` in its environment) wrote this
data directly into the **shared production store**. Until this is fixed, every hourly
`request-triage` run re-sweeps the same contaminated backlog (none of the fixture threads ever
gets an agent reply, so `listNewRequestThreads` never drops them), which wastes the routine's
runs and risks a future run mistakenly triaging fabricated content as a real Owner ask.

**Build:**
1. **Root-cause** the write path: audit anything that can construct a libSQL/Drizzle client
   against `process.env.DATABASE_URL` outside of `vitest run`'s `:memory:` override — e.g. a test
   file executed directly via `tsx`/`node` rather than through vitest, a script that imports
   `app/lib/triage.server.ts`/`threads.server.test.ts` fixture helpers, or a prior debugging
   session that ran the CLI/tests with the real remote env sourced. Confirm which one produced
   the 2026-09-21 batches (timestamps cluster into ~7 runs within a ~24-minute window).
2. **Close the hole** so no test/dev path can reach the live remote — e.g. a hard assertion in the
   db client factory that refuses a non-`:memory:`/non-`file:` `DATABASE_URL` unless an explicit
   `ALLOW_REMOTE_DB=1` (or similar) is set, or scoping the test fixtures to a helper that cannot be
   imported outside the vitest environment.
3. **Propose** (do not execute) a safe cleanup path for the 288 polluted rows — most likely
   archiving them (`archivedAt`, already reversible by design, [[adr-024]] schema) rather than
   deleting. Archiving/deleting shared-store data is not self-executed by any routine; this ticket
   only proposes the mechanism (a reviewed script or console admin action) for the Owner/CTO to
   run. **Do not build this as something `request-triage` or any autonomous routine invokes
   itself** — it touches live shared data and reads as delete-adjacent.
4. Consider whether `listNewRequestThreads`/`request-triage` should detect an anomalously large or
   templated sweep and degrade loudly (refuse to triage, surface an error) rather than silently
   proceeding — mirroring the store-outage posture [[adr-024]]/[[adr-025]] already require.

**Acceptance:** the write path that let fixture/test data reach the live remote is identified and
closed; a reviewed (not self-executed) cleanup proposal exists for the 288 polluted rows; the
2026-09-21 incident is cross-referenced from [[ledger-068-request-triage-sweep-db-contamination]].
See [[adr-024]], [[adr-025]], [[request-triage]].
