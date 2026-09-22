---
id: work-115
title: request-triage sweep is contaminated by console test-fixture threads in the shared store
type: bug
status: proposed
priority: high
owner: cto
spec: adr-025
created: 2026-09-22
updated: 2026-09-22
---
The scheduled request-triage cloud routine's sweep returns ~200 threads that are verbatim
**console test fixtures** (app/lib/triage.server.test.ts, threads.server.test.ts,
human-input.server.test.ts) rather than genuine Owner requests — titles/bodies match test
scenarios exactly (e.g. "Add a dark mode toggle"). Every hourly sweep re-processed this junk,
**burning budget** and obscuring real requests. The routine found it over two runs (the now-closed
autonomous PRs #100 and #104, which this ticket consolidates). request-triage is **paused**
(2026-09-22) until this is fixed.

**Likely cause:** console test helpers run against the remote Turso store (DATABASE_URL) instead
of the :memory: db that vitest.config.ts scopes tests to, so fixtures persist to the shared store
the routine reads.

**Acceptance:**
1. Root-cause the leak — tests must never write to the remote store; pin the test db to :memory:
   (or a disposable file) + a guard so a test run cannot target DATABASE_URL.
2. Clean the shared store of the ~200 fixture threads (an Owner-gated delete/archive — the routine
   only flags; it never deletes).
3. Harden the sweep to ignore fixture-shaped threads defensively.
4. Un-pause request-triage once the store is clean and the leak is closed.

Consolidates the autonomous findings in closed PRs #100 / #104. Traces to adr-025 and the request-loop PRD.
