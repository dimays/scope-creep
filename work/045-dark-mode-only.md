---
id: work-045
title: Dark-mode-only — drop light mode across design package + console
type: feature
status: proposed
priority: medium
owner: chief-designer
assignees: ada
spec: prd-console-explore
created: 2026-09-06
updated: 2026-09-06
---
Owner decision (2026-09-06): **scrap light mode entirely; fix the product to dark mode.**
"I'll never want light mode." This supersedes the light-mode a11y-contrast fix ([[work-043]]),
which is now moot — dark mode already passes WCAG AA on the shipped tokens.

- **@scope-creep/design:** make dark the single committed look — either drop the light
  `:root` token values + the `prefers-color-scheme` light branch, or hard-pin dark. Keep the
  token contract; just stop shipping a light palette. Cut a version + tag per convention.
- **scope-creep-console:** force dark (`color-scheme: dark` / `data-theme="dark"`), remove
  light-mode CSS branches, re-pin the design package.
- Verify contrast holds (it already does in dark) and nothing assumed a light background.

**Acceptance:** the console renders dark-only; no light-mode code paths remain in the console
or the design package; contrast passes AA. Closes the [[work-043]] concern by removing light
mode rather than fixing it. See [[work-041]], [[adr-016]].
