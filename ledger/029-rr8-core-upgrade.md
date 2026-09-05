---
name: ledger-029-rr8-core-upgrade
description: RR7→RR8 + Vite7→Vite8 ratified as a gated core-upgrade (work-028) — ADR-001 amendment 4, golden-path updated, Console pinned to exact versions. Closes the governance gap where the bump had landed unratified.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 029 — RR8 / Vite 8 core-upgrade (ratified)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Context
The level-set ([[ledger-027-level-set-round]], CTO) found that the Console had shipped
on **React Router 8 + Vite 8** while [[adr-001]] / [[golden-path]] still pinned RR7, with
**no gated core-upgrade and no ledger entry** — a §I.4 / ADR-001 breach that slipped
because nothing enforced it. Raised to the Owner as [[work-028]].

## Decision (Owner: **ratify**)
Keep RR8/Vite8 (already running green) and close the governance gap:
- **[[adr-001]]** — amendment (4): the full-app framework is **RR8 on Vite 8**, pinned to
  exact versions, ratified as a gated core-upgrade. Description updated to RR8.
- **[[golden-path]]** — the stack table now reads RR8 / Vite 8.
- **Console** (dimays/scope-creep-console#19) — `react-router` + `@react-router/*`
  pinned to **8.3.1**, `vite` to **8.2.2** (dropping the caret ranges), so the next
  framework bump is a deliberate, reviewed change per ADR-001's "pin versions" mitigation.
- **Playwright** — named in ADR-001/golden-path but never installed; **deferred** until an
  E2E need is identified. The `test` gate stays `tsc` + Biome + Vitest.

## Consequence
The written standard and the shipped stack agree again, and the framework is pinned so
`bun install` can't silently drift it. The process lesson (from [[ledger-027-level-set-round]]):
this bump bypassed the gate because nothing enforced core-upgrade ratification — the
enforcement machinery ([[work-024]] docs:lint, a version-bump gate) is the durable fix.

## Rollback
Not taken — RR8/Vite8 is stable. If needed later, revert the pins to RR7/Vite7 and this
amendment via a new core-upgrade.
