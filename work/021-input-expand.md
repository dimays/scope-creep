---
id: work-021
title: Human-Input Log — expand entries to the full message
type: feature
status: done
priority: medium
owner: chief-designer
spec: prd-human-input-log
branch: work-021-input-expand
pr: https://github.com/dimays/scope-creep-console/pull/14
created: 2026-09-05
updated: 2026-09-05
---
From Owner feedback on the shipped Human-Input Log ([[work-012]], [[work-020]]):
entries were truncated to a preview with no way to read the rest — unlike the
click-through-to-detail experience elsewhere in the app (which terminal inputs
lack, having no source page).

- A truncated entry now renders as a native **`<details>` disclosure**: the preview
  is the collapsed summary; clicking reveals the full message inline (`pre-wrap`, so
  multi-line prompts read correctly). No client JS — matches the app's zero-client
  style. Where an input has a source page, the expanded view links out to it.
- `isExpandable(summary, excerpt)` (pure, unit-tested) decides when there's more to
  show, guarding the feedback case where the summary outruns a short comment.

**Acceptance:** a long input shows a compact preview and expands to its full text;
short inputs stay plain. See [[prd-human-input-log]].

**Done (2026-09-05):** shipped in gated PR dimays/scope-creep-console#14. Verified on
`/work/inputs` — the genesis input renders a 141-char preview (48px) and expands to
the full 6,101-char message (1,952px); 14 disclosures across the timeline.
`npm test` 23 passed (3 new `isExpandable` cases).
