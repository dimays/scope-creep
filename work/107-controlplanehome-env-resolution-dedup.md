---
id: work-107
title: Consolidate control-plane-home / env resolution duplication across *.server.ts
type: debt
status: proposed
priority: medium
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-23
---
Follow-up from the [[work-101]] folder-resolution fix. The Threads fix added a robust
`resolveControlPlaneHome()` (absolute-real-dir-or-null, honest fallback) in
`app/lib/claude-sessions.server.ts`. But the same `SCOPE_CREEP_HOME`-with-inert-env pattern is
re-derived independently across multiple console server modules — human-input, authoring, work,
explore, models, registry `.server.ts` — each with its own `process.env.SCOPE_CREEP_HOME ?? …`
fallback. qa found `bun run dev` does not load `.env`, so these fallbacks are load-bearing and
should not each get the resolution subtly different.

## Scope
Extract ONE shared, tested control-plane-home / env resolver and adopt it across the console
server modules that currently re-derive it, so `.env`-loading behavior and the absolute-path /
honest-null contract are uniform. Audit the listed `.server.ts` files; converge them.

## Acceptance
A single resolver owns control-plane-home resolution; the duplicated inline fallbacks are gone or
delegate to it; console tests green. See [[work-101]], [[work-100]].

> **[2026-09-23] board reconcile:** `active → proposed` — un-started follow-up (no branch/PR); returned to To-do to clear the WIP-cap. work-sweep will re-activate it within the ≤2 cap. See [[ledger-074-board-reconciliation]].
