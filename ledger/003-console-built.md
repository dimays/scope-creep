---
name: ledger-003-console-built
description: The Console (first Golden-Path app) was built and passed a green gate; toolchain installed; CTO agent smoke-tested.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 003 — Console built

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Events
1. **CTO agent smoke test — passed.** Booted as the `cto` subagent, resolved the
   full loader read-order, and answered a stack question in character (correctly
   ruling MongoDB an ADR-recorded Escapee). Wiring confirmed. Minor note: two
   files named `cto.md` (loader vs canonical) could be conflated by a literal
   path-follower — acceptable, watch for confusion.
2. **Toolchain installed (Owner-approved).** Homebrew `node@22` (v22.23.2,
   keg-only — Heroku Node 16 left untouched) + `bun` 1.3.14.
3. **`scope-creep-console` built** via the `new-app` loop on the Golden Path.
   Green test gate (typegen + tsc + biome + vitest, 2/2). Runtime-verified:
   `/healthz` → `{status:ok, version:0.1.0, db:true}`; homepage renders the four
   control-plane agents from the live registry. Committed locally (36 files).

## Registration
`scope-creep-console` added to `registry/apps.json` (repo `pending-remote`).

## Gate decisions
- GitHub remote for `scope-creep-console` **not yet created** — awaiting Owner
  confirmation (outward-facing).
- Deploy **not performed** — human-gated (ADR-003 / INVARIANTS §III).
