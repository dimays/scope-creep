---
name: release-000-template
description: Template for a control-plane release-notes entry. Copy to releases/NNN-vX.Y.Z.md when generating one at a version-bump (see [[work-053]]). Not itself a release; exempt from lint like every other 000-template.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# Release NNN — vX.Y.Z

- **Date:** YYYY-MM-DD
- **Scope:** control-plane (scope-creep) — org-wide / cross-app roll-up. A single app's own
  release stays in *its* `CHANGELOG.md` ([[work-053]] "Storage convention"); only reference
  it here, never fork it.
- **Version:** the semver (or `MANIFEST.yaml` / `package.json` version) this entry documents.

## Highlights
2–6 sentences, cold-readable: what shipped and why it matters to the Owner. This is the
"what changed" a human reads without opening `git log` — no unexplained jargon or ids.

## Landed
- **Tickets:** [[work-NNN]], [[work-NNN]], …
- **PRs:** <https://github.com/OWNER/REPO/pull/N>, …
- **Ledger:** [[ledger-NNN-slug]], …

(Any of the three groups may be empty for a quiet release — say so rather than omitting
the heading, so the Console's "nothing landed" state is a real, honest read, not a gap.)

## Notes
Anything needed to interpret this release honestly: known gaps, deferred scope, follow-up
tickets spun out, or — for a hand-seeded backfill entry — that it predates the generator
and was assembled from git/ledger history rather than produced at an actual version-bump.

---

**Producing this file is not this template's job.** The artifact shape + storage
convention are specified by [[work-053]]; *which* loop/step generates an entry at each
version-bump is the Chief of Staff's call under [[adr-021]] (in flight). Until that
generator lands, entries here are hand-seeded backfills — see [[release-001]] for the
first one.
