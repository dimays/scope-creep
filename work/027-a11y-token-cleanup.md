---
id: work-027
title: "Console a11y + design-token cleanup (focus, tokens, error boundary)"
type: feature
status: done
priority: medium
owner: chief-designer
spec: prd-console-explore
created: 2026-09-05
updated: 2026-09-05
branch: work-027-a11y-tokens
pr: https://github.com/dimays/scope-creep-console/pull/18
---
From the level-set ([[ledger-027-level-set-round]], Chief Designer). The `--sc-*` token
layer is strong (~90% tokenized) but has gaps that bypass it, plus missing a11y basics.

- **Add a `:focus-visible` system** (one accent-token outline on links, cards, buttons,
  inputs, summary) — biggest a11y win, smallest effort.
- **Purge hardcoded semantic hex** that dodges existing tokens: `.card--high`,
  `.tag--debt`, `.console__count--warn` (→ `--sc-warn`), `.tag--bug` (→ `--sc-danger`).
- **Add `--sc-success`** (+ dark value) to the shared `@scope-creep/design` package;
  route `.req-status--accepted` / `.chip--feedback` green through it. *(Owner: confirm a
  green belongs in the minimal palette — touches the shared package.)*
- **Style the ErrorBoundary** with the `.console` frame (it currently leaks raw Tailwind
  in `root.tsx`) + add pending/disabled form states (double-submit is possible today).

**Acceptance:** keyboard focus is visible app-wide; no hardcoded semantic hex in
`app.css`; thrown errors render on-brand. See [[prd-console-explore]], [[ledger-027-level-set-round]].

**Done (2026-09-05):** Shipped in gated PR dimays/scope-creep-console#18: :focus-visible system, warn/danger tokenized, on-brand ErrorBoundary, CRO display name. (--sc-success + .req-submit contrast deferred pending the palette decision.)
