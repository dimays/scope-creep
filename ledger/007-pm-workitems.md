---
name: ledger-007-pm-workitems
description: PM work-item system delivered — control-plane records + validator + CI, and the Console Work board.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 007 — PM work-item system

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Delivered ([[adr-005]])
- **System of record** — `work/` with a schema ([[work-readme]]) and 7 seed items
  capturing the real backlog; `scripts/work-check.ts` validator wired into the
  control-plane CI (renamed workflow "Control plane": registry sync + work schema).
- **Console Work board** (`scope-creep-console` 0.3.0) — read-only kanban of the
  records grouped by status (Proposed / Active / Blocked / Done), priority accents,
  type tags, per-item detail pages; global nav. Green gate (9 tests).

## Lifecycle demonstrated
`work-002` (the PM system itself) moved `active → done` — the factory tracked and
completed its own work item.

## Follow-up
- **Console write-back** (create/edit work items from the app) is deferred; today
  items are authored as files.
