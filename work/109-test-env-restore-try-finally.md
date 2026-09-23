---
id: work-109
title: Restore test env vars in try/finally, not end-of-body
type: debt
status: proposed
priority: low
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-23
---
Optional tidy noted in the [[work-100]] Threads fix re-review. `route-entrypoints.test.ts` (and the
pre-existing `CLAUDE_PROJECTS_DIR` pattern it follows) saves and restores env vars (`SCOPE_CREEP_HOME`,
`CLAUDE_PROJECTS_DIR`) at the **end of the test body** rather than in a `try/finally`. If an
assertion throws mid-test, the env isn't restored and can leak into later tests. Not a blocker;
the hermetic fix is correct as landed.

## Scope
Move the env save/restore into `try/finally` (or a `beforeEach`/`afterEach` fixture) in the console
test(s) using this pattern so a mid-test failure can't leak env. Pre-existing pattern — converge it.

## Acceptance
Env save/restore is failure-safe (try/finally or fixture); console tests green. See [[work-100]].

> **[2026-09-23] board reconcile:** `active → proposed` — un-started follow-up (no branch/PR); returned to To-do to clear the WIP-cap. work-sweep will re-activate it within the ≤2 cap. See [[ledger-074-board-reconciliation]].
