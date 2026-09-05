---
name: ledger-026-human-input-expand
description: Human-Input Log entries are now expandable to the full message (work-021) — native <details> disclosure, from Owner feedback.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 026 — Human-Input entries expand to the full message

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[work-021]], [[prd-human-input-log]])
Owner feedback on the shipped log: entries were truncated to a preview with no way
to read the rest. Shipped in gated PR dimays/scope-creep-console#14 (Owner-merged).

- A truncated entry now renders as a native **`<details>` disclosure** — the preview
  is the collapsed summary; clicking reveals the full message inline (`pre-wrap`).
  No client JS, keeping the app's zero-client-state style. Inputs with a source page
  also link out to it from the expanded view.
- `isExpandable(summary, excerpt)` — pure, unit-tested — gates the affordance so
  short inputs (and feedback whose summary outruns a short comment) stay plain.

## Verified
`/work/inputs`: the genesis input shows a 141-char preview (48px collapsed) and
expands to the full 6,101-char message (1,952px); 14 disclosures across the timeline.
`npm test` 23 passed (3 new cases).

## Note
A fast-follow driven directly by Owner chat feedback rather than the Work Requests
intake — small, same-feature UX refinement. The intake remains the path for larger
or independent requests.
