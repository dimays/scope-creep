---
id: work-109
title: Restore test env vars in try/finally, not end-of-body
type: debt
status: review
priority: low
owner: cto
spec: prd-cos-threads
branch: work-109-env-restore-try-finally
pr: https://github.com/dimays/scope-creep-console/pull/81
created: 2026-09-21
updated: 2026-10-03
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

> **[2026-10-03] work-sweep:** `proposed → review` — wrapped the `route-entrypoints.test.ts` launch-intent test body in `try/finally` so `CLAUDE_PROJECTS_DIR`/`SCOPE_CREEP_HOME` restore even on a mid-test throw, matching the existing `claude-sessions.server.test.ts` precedent. Other files using the same env-var pattern already restore in `afterAll`/`afterEach`, which is already failure-safe — left untouched. Console suite green (354/354; the touched test file itself can't load in this sandbox due to the pre-existing missing `@scope-creep/design` optional dep, same gap as every prior run). PR open, held for `@scope-creep-review`. See [[ledger-086-work-sweep-fifth-cadenced-run]].
