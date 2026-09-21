---
id: work-097
title: request-triage sweep is polluted by QA/test-fixture threads in the shared store
type: bug
status: proposed
priority: high
owner: cto
spec: adr-025
created: 2026-09-21
updated: 2026-09-21
---
## What happened

The 2026-09-21 `request-triage` sweep (`npm run triage -- sweep`) returned 200+ threads that satisfy the sweep filter (`kind=request`, `initiator=owner`, non-archived, no org reply) but are **not genuine Owner asks** — every one of them is a verbatim match to a scenario in the console's own test suite:

- Titles cycle through a fixed set (`Ship the queue`, `Theme 2 as its own effort`, `Tangent`, `Solo`, `Round trip`, `Dry one`, `A test thread`, `Parent` / `Parent 2`, `Add a dark mode toggle`, etc.) that appear verbatim in `app/lib/triage.server.test.ts`, `app/lib/threads.server.test.ts`, and `app/lib/human-input.server.test.ts`.
- Message bodies match test fixtures exactly, e.g. thread 12 ("Ship the queue") has body "Please build the needs-you queue."; thread 47 ("Add a dark mode toggle") has body "Please add dark mode." — both lifted straight from the test files.
- A cluster of six threads (ids 11/67/123/200/256/312) all share the title "a work request" and the identical fixture timestamp `1700000000000` — a hallmark of a shared test constant, not organic Owner activity.
- The polluted rows arrived in at least two timestamp waves a few minutes apart (~`1790022895799`-`1790022920618` and ~`1790024219458`-`1790024337368`), each internally ordered exactly like the test file's `describe`/`it` sequence — consistent with the test suite (or a script that calls `createThread`/`writeBackOutcome` from `~/lib/threads.server` and `~/lib/triage.server` directly, e.g. via `tsx -e`) having been run **against the remote Turso store** instead of the `:memory:` db `vitest.config.ts` scopes tests to.

`vitest.config.ts` correctly forces `DATABASE_URL=":memory:"` for anything run through `vitest`, so the leak did not come from a normal `npm test` / `bun test` run. It most likely came from a verification/QA step for work-066 (or a similar manual check) that imported the test helpers and exercised them with the ambient (remote) `DATABASE_URL`/`DATABASE_AUTH_TOKEN` already set in the environment, rather than through the vitest harness.

## Impact

- The `request-triage` cloud routine (hourly, `registry/routines.json` `trig_01L1ZuWXmRE1quiLGP3mv9ni`) re-sweeps and re-reasons over these 200+ junk threads **every single run** until they are cleared, wasting the routine's budget and obscuring genuine Owner requests in its output.
- None of the polluted threads were triaged, ticketed, or written back to by this run — the 2026-09-21 sweep found **zero genuine new Owner requests** once the fixture rows were excluded. No tickets or write-backs were created for them.

## What's needed

1. **Root-cause** how test-helper calls reached the remote store (audit any script/spike that imports `~/lib/threads.server` or `~/lib/triage.server` directly and runs it with production env vars set; consider a runtime guard in `app/db/index.ts` that refuses to run known test-fixture titles/bodies against a `isRemote` connection, or at least warns loudly).
2. **Clean up the shared store** — archive or delete the ~200 identified fixture threads. This is a data-deletion action and per INVARIANTS §7 / the STOP gates needs the Owner at the moment of action; the request-triage runner has no archive/delete verb and did not attempt one.
3. Consider hardening `scripts/triage.ts sweep` (or `listNewRequestThreads`) with a sanity check (e.g., flag/skip threads whose title+body exactly match a known test fixture, or an anomaly threshold like "sweep returned N threads all created within the same few-minute window") so a future leak degrades safely instead of silently flooding the loop.

See [[adr-024]] (shared store / honest degradation), [[adr-025]] (runner topology), [[request-triage]] (the loop this pollution is degrading).
