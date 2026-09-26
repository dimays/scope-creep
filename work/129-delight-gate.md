---
id: work-129
title: Delight gate — local live preview, design-review stage in dev-cycle, taste.md (roadmap-002 WS4)
type: feature
status: proposed
priority: medium
owner: chief-designer
spec: roadmap-002
created: 2026-09-24
updated: 2026-09-24
---

## Acceptance
- **Local live preview.** The console serves the agent's worktree with Vite HMR, and the "ready to look" card opens it. This is a **new build**: a live preview has never existed.
- **Design review.** dev-cycle gains a design-review stage. The reviewer attaches evidence:
  - screenshots
  - empty, loading and error states
  - keyboard behaviour
  - reduced-motion behaviour

  It may block non-kernel work on taste grounds.
- **Taste standard.** `standards/taste.md` is a checkable rubric, fed by the Owner's reactions.
- **Scope.** Local only. A hosted preview would be spend (INVARIANTS §7).
