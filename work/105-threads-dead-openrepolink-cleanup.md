---
id: work-105
title: Remove dead ThreadProjection.openRepoLink field + update server tests
type: debt
status: active
priority: low
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
Follow-up from the [[work-100]] Threads UX fix. The launcher fix removed the render path that
consumed `ThreadProjection.openRepoLink` (the "Open the repo in Claude Code" new-session control
that used to masquerade as resume — see [[work-102]]). The field is now **dead** in
`app/lib/claude-sessions.server.ts`, but `claude-sessions.server.test.ts` still asserts on it.

## Scope
Remove `openRepoLink` from `ThreadProjection` (and `buildOpenRepoLink` if nothing else uses it),
and update the server tests in the same change so the suite stays green. Small, mechanical;
coordinate so it doesn't fight the landing of the main Threads PR. ADR-016 unaffected.

## Acceptance
`openRepoLink` (and any now-unused builder) is gone; the console test suite is green. See
[[work-100]], [[adr-016]].
