---
id: work-041
title: Design-system — promote status/motion tokens + extract primitives
type: debt
status: proposed
priority: medium
owner: chief-designer
spec: adr-013
created: 2026-09-06
updated: 2026-09-06
---
Consolidate rather than sprawl as surfaces grow (Theme 2, delight/quality). Extract the
duplication the Threads + real-time work exposed.

- Promote the two status colors hardcoded in the console (`#e8833a` needs-you, `#3aa76d`
  working) → `--sc-attention` / `--sc-success`, and add a motion-token set
  (`--sc-motion`, `--sc-ease`) + a global reduced-motion reset, into `@scope-creep/design`.
- Extract reusable primitives: **Surface** (panel/card/msg/outcome share one base),
  **Badge** (tag/chip/count), **StatusDot** (formalize the thread dot), and the new
  **WorkingIndicator** / **ActivityRow**. Keep visual CSS in the app on tokens; put the
  reduced-motion / announce behavior in the package as a headless a11y primitive.
- **GATED:** the shared-package palette/token-API change is Owner-gated ([[adr-013]] §7b,
  [[decision-rights]]: design system / shared tokens).

**Acceptance:** no status color is hardcoded in an app; the five primitives back the
Threads/real-time/delegation surfaces; reduced-motion is a contract, not a per-component
guess. See [[adr-013]].
