---
id: work-111
title: Make the desktop-only Threads fallback a delightful first-class path, not a degradation
type: chore
status: proposed
priority: medium
owner: chief-designer
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
Queued from the Owner's live acceptance run of [[work-100]] (2026-09-21). For a Claude
**desktop-app-only** user, one-click launch is impossible (the desktop app registers no
`claude-cli:` handler — see [[work-110]]). So the copyable-command + **in-app transcript
projection** IS the primary experience for those users — but today it reads as an error/degradation
fallback.

## Scope
Design the desktop-only path as first-class:
- The copyable `claude-cli://…` / `claude --resume <uuid>` command and the projected transcript are
  presented as the intended experience, not a warning.
- Clearly and warmly explain **why** one-click isn't available and **exactly** what to run —
  informative, not apologetic. Coordinate with the setup-detection branching in [[work-110]].
- Design-system tokens/spacing, dark-mode-correct, delightful.

## Acceptance
A desktop-only user sees a first-class, well-explained experience (not an error state); the
copyable-command + projected-transcript path feels intentional. See [[work-100]], [[work-110]],
design system.
