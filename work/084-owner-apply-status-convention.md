---
id: work-084
title: Owner-apply "pending | applied" convention + backfill — make "pending" deterministic
type: feature
status: proposed
priority: high
owner: chief-knowledge-manager
spec: prd-owner-action-notifications
created: 2026-09-07
updated: 2026-09-07
---
The capture/convention half of [[prd-owner-action-notifications]]. Owner-apply docs
(`docs/owner-apply-*.md`) are the primary source for two of the four Owner-action kinds
(activation steps, pending owner-apply docs) — but **there is no signal today for whether a
doc is still pending or already applied.** A filename scan can't tell `owner-apply-work-059.md`
(likely applied) from `owner-apply-request-loop.md` (pending). Without this, the read-model
([[work-083]]) can only guess, and the notification would nag about already-done work.

## What to add
- **A frontmatter convention** on every `docs/owner-apply-*.md`: a machine-readable
  `status: pending | applied` (plus optional `applied_at` / `applied_by` for the record).
  This is a [[chief-knowledge-manager]]-owned manifest convention ([[doc-standards]] §1) —
  deterministic discovery over search, so the Console reads state, not archaeology.
- **A documented convention** (short, in `standards/` or the owner-apply docs' own README)
  stating the naming (`owner-apply-<slug>.md`), the frontmatter shape, and the rule that the
  **Owner (or the applying agent) flips `pending → applied`** when the manual step is done —
  never the Console (the app only reads). Fold the shape into what [[work-083]] specs so the
  two agree.
- **Backfill** the existing docs (`owner-apply-activity-write-path.md`,
  `owner-apply-adr-022-floor.md`, `owner-apply-request-loop.md`, `owner-apply-work-059.md`)
  with an honest `status` — flag rather than guess where "applied" is uncertain, and confirm
  with the Owner in review.

## Gate class — escalation
Touches the **core repo** (`docs/` + a `standards/` convention). Per [[adr-022]] trigger d
(a change to core/standards conventions) this **holds for the Owner** and is not
self-mergeable. Keep it a pure docs/convention change — no runtime behavior.

## Dependencies
Depends on the shipped surface ([[work-063]]) only indirectly; pairs with [[work-083]] (the
source-model deep-dive frames this convention). Unblocks the render ticket [[work-085]] for
the owner-apply source. Owner-apply docs have no manifest `name`, so they are referenced by
path, never as `[[wikilinks]]` — the convention keeps them that way (a `status`, not a
`name`).

**Acceptance:** every `docs/owner-apply-*.md` carries `status: pending | applied`; the
convention is documented in one canonical place with the "who flips it" rule; the read-model
([[work-083]]) can determine pending-vs-applied from the filesystem alone with zero network
and zero Claude call. Escalation-class — flagged for the Owner, not self-merged.
