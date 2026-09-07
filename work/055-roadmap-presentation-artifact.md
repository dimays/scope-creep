---
id: work-055
title: CEO roadmap-presentation artifact shape + storage convention
type: feature
status: done
priority: low
owner: chief-product-officer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
> **Shipped 2026-09-06.** Artifact shape + storage convention defined:
> [`roadmap/000-template.md`](../roadmap/000-template.md) (the shape below), storage at
> `roadmap/NNN-YYYY-MM-DD-*.md` with a manifest, supersede-not-destroy per
> [[doc-standards]]. No seed presentation is included — unlike [[work-053]]'s
> release-notes backfill, fabricating a CEO board deck's themes/traces would violate the
> no-fabrication rule ([[invariants]] §III.8); the first real entry is the [[roadmap]]
> loop's own finale run. **Not shipped (deliberately out of scope):** the Roadmap
> Planning Loop itself, which is the CoS's [[adr-021]] design and runs as the capstone
> after this ticket.

Define and stand up the **roadmap-presentation artifact** for **Surface 3** of
[[prd-console-operations]] — the CEO's board decks, stored as repo artifacts, projectable by
the Console.

- **Artifact shape (per presentation):** date, horizon (e.g. "next quarter"), the **themes**
  (the board-deck sections), and per theme a short narrative + the **artifacts it traces to**
  (PRDs, tickets, decisions, ledger entries). Markdown is the substrate (projected like a
  PRD/ADR); the "deck" is its section structure, not a binary slide file.
- **Storage convention:** control-plane `roadmap/NNN-YYYY-MM-DD-*.md`, mirroring the ledger's
  numbered-artifact convention, each with a manifest (`name`, `description`, `metadata.type`)
  so it lints/links like every doc. **Supersede-not-destroy** ([[doc-standards]]): a new
  presentation supersedes the prior; history stays in the repo.
- **Producer — dependency, not this ticket:** roadmap presentations are produced by the
  **Roadmap Planning Loop** the CoS is designing (ADR-021, in flight; referenced as plain text
  — not yet in the repo). This ticket specs the **artifact + storage + the Console-facing
  contract**; it does **not** author the producing loop (the CoS's call). Coordinate so the
  loop emits exactly this shape. The CEO ([[ceo]]) is the author-of-record of the deck content.

**GATED:** introduces a repo artifact convention (+ a manifest/lint touchpoint) → propose → PR,
Owner-gated ([[decision-rights]]).

**Depends on:** the Roadmap Planning Loop / ADR-021 (which loop produces the presentation) —
soft; the shape + storage can land ahead of the producer.  ·  **Blocks:** [[work-056]].

**Acceptance:** a documented roadmap-presentation artifact shape + storage convention exists and
lints green, agreed with the CoS's Roadmap Planning Loop design. See [[prd-console-operations]].
