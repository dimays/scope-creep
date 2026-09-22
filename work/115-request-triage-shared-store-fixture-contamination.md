---
id: work-115
title: request-triage sweep is contaminated by console test-fixture threads in the shared store
type: bug
status: review
priority: high
owner: cto
spec: adr-025
pr: https://github.com/dimays/scope-creep-console/pull/74
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

---

## Resolution (2026-09-22 — CTO fix, CRO-verified)

**Root cause (confirmed, not just plausible).** The console `db` singleton (`app/db/index.ts`)
resolves its connection **once at import** via `resolveDbConfig` (`app/db/config.ts`), which reads
`SCOPE_CREEP_DB_URL`/`SCOPE_CREEP_DB_AUTH_TOKEN` **before** `DATABASE_URL`/`DATABASE_AUTH_TOKEN`.
`vitest.config.ts` pinned **only** `DATABASE_URL=:memory:`, so an ambient
`SCOPE_CREEP_DB_URL=libsql://…turso.io` (a dev shell profile, or the `scope-creep-local` cloud env)
**silently shadowed** the `:memory:` intent → the test-time singleton connected to the **remote Turso
store** → tests calling `createThread(...)` (triage/threads/human-input `.server.test.ts`) wrote ~200
verbatim fixtures ("Add a dark mode toggle", …) into the shared store the hourly sweep reads. The CRO
reproduced the resolution outside vitest: `resolveDbConfig({SCOPE_CREEP_DB_URL:"libsql://fake…",
DATABASE_URL:":memory:"})` → `{remote:true}`.

**Fix — proposed in [scope-creep-console#74](https://github.com/dimays/scope-creep-console/pull/74)
(propose-only; not merged):**
1. **Leak closed at the source.** `vitest.config.ts` now pins **all four** db-selecting vars
   (`SCOPE_CREEP_DB_URL=:memory:`, both auth tokens `=""` → read as unset, `DATABASE_URL=:memory:`);
   plus a fail-closed guard (`test/guard-local-db.ts`, a vitest `setupFiles`) that aborts the run if
   `resolveDbConfig().remote` — the belt against a future pin regression. Verified: full suite
   **370/370 pass** on `:memory:`; guard **aborts** under a hostile ambient `SCOPE_CREEP_DB_URL`.
2. **Sweep hardened.** `listNewRequestThreads` now drops exact known-fixture title+body pairs
   (`isKnownFixtureThread`, defense-in-depth — the schema has no origin column, so exact-pair is the
   only safe predicate; secondary to #1).
3. **Store cleanup — SPECIFIED, NOT EXECUTED (Owner-gated delete).**
   `docs/owner-cleanup-work-115-fixture-threads.md` in the console repo: read-only identify+count
   query, **archive (reversible) recommended over delete**, transactional `UPDATE`, dry-run, backup.
   The exact live fixture count was **not** obtained (no remote creds in-session) — the ~200 is from
   #100/#104; the Owner runs Step 1 to get the real number.

**Un-pause gate (Owner-gated — request-triage `trig_01L1ZuWXmRE1quiLGP3mv9ni` stays paused until ALL hold):**
1. Leak closed — #74 merged (ADR-022 review: author ≠ merger; green gate).
2. Store clean — Owner runs the cleanup doc (Step 1 read-only count first; confirm it lands near ~200
   and contains nothing real — this also catches any *non-denylisted* leaked variant the sweep filter
   won't skip), then archives; confirms `not_yet_archived = 0`.
3. Then flip request-triage to active on **claude.ai** AND in `registry/routines.json` (a separate
   control-plane step), and confirm a canary sweep returns zero fixture titles.

`registry/routines.json` was **stale** (`status: active` while the routine was actually paused) —
corrected to `paused` in this change, pending the gate above.
