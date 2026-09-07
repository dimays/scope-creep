---
id: work-053
title: Release-notes artifact shape + storage convention (generated per version-bump)
type: feature
status: done
priority: medium
owner: chief-product-officer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
> **Shipped 2026-09-06.** Artifact shape + storage convention defined:
> [`releases/000-template.md`](../releases/000-template.md) (the shape below) +
> [[release-001]] (a hand-seeded backfill covering 2026-09-04–06, grounded in git log +
> the ledger — not invented). Per-app `CHANGELOG.md` stays canonical per-app; the
> control-plane `releases/NNN-vX.Y.Z.md` set is for org-wide/cross-app roll-ups. **Not
> shipped (deliberately out of scope):** the generator that produces an entry at each
> real version-bump — that is the loop/step the CoS specs under [[adr-021]]; this ticket
> only guarantees the generator has an exact shape to emit into. `docs:lint` doesn't yet
> treat `releases/` as a manifest dir (would need a `scripts/docs-lint.ts` change, out of
> this ticket's touched surface); the seed still carries a full manifest so it's ready
> when that lands.

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
