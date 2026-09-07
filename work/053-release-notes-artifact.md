---
id: work-053
title: Release-notes artifact shape + storage convention (generated per version-bump)
type: feature
status: proposed
priority: medium
owner: chief-product-officer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
Define and stand up the **release-notes artifact** for **Surface 2** of
[[prd-console-operations]] — generated per release/version-bump, stored as a repo artifact,
projectable by the Console.

- **Artifact shape (per release):** version, date, a short "highlights" summary, the **landed
  tickets** (work-item ids), the **PRs** (URLs), and any ledger refs — the joins the Console
  already makes, named per release.
- **Storage convention:**
  - *Per-app:* the app's own `CHANGELOG.md` stays the canonical per-app release note (the
    Console already keeps one + a version-sync check, [[work-023]]) — reuse it, don't fork it.
  - *Control-plane / org level:* a `releases/` artifact set (proposed `releases/NNN-vX.Y.Z.md`)
    with a manifest (`name`, `description`, `metadata.type: reference`) so it lints and links
    like every other doc.
- **Producer — dependency, not this ticket:** release notes should be **generated at the
  version-bump**, by the loop/step the CoS is defining in the loop-system redesign (ADR-021, in
  flight; referenced as plain text — not yet in the repo) — candidate: a release step in
  [[ticket-cycle]]. This ticket specs the **artifact + storage + the Console-facing contract**;
  it does **not** author the producing loop step (the CoS's call). Coordinate so the generator
  emits exactly this shape.
- Backfill: seed the control-plane `releases/` index from existing shipped work so the Console
  has something real to project before the generator lands.

**GATED:** introduces a repo artifact convention (+ a manifest/lint touchpoint) → propose → PR,
Owner-gated ([[decision-rights]]).

**Depends on:** ADR-021 (which loop/step generates the notes) — soft; the shape + storage can
land ahead of the generator.  ·  **Blocks:** [[work-054]].

**Acceptance:** a documented release-notes artifact shape + storage convention exists, a seeded
control-plane `releases/` entry lints green, and the shape is agreed with the CoS's producing
loop. See [[prd-console-operations]].
