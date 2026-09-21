---
id: work-099
title: Console — render the in-review column on the Work board
type: feature
status: proposed
priority: medium
owner: cto
spec: adr-003
created: 2026-09-21
updated: 2026-09-21
---
> **Console periphery — scope-creep-console repo, NOT this control plane.** This ticket only
> *specs* the change; the code lands in the Console repo, not here.

**User problem.** The control plane now has an explicit **in-review** lifecycle state
([[work-097]], [[work-readme]]) mapping the Owner's four-column kanban to
`proposed`/`active`/`review`/`done`. The Console's Work board still renders three columns, so a
ticket that is code-complete with an open PR has **nowhere to appear** — the surface is no longer
uniform with the schema, and the Owner can't *see* the verify → review → land finish line the new
state was created to make visible.

**Success signal.** The Console Work board shows **four columns — To-do · In-progress ·
In-review · Done** — with `review` tickets rendered in the In-review column (showing the open
`pr:` link), so the board the Owner reads is one-to-one with the lifecycle. `blocked`/
`superseded`/`dropped` stay presented as they are today (side/terminal, off the four columns).

**Scope (Console repo — do not implement here):**
- Add the `review` status to the board's column model and render an **In-review** column between
  In-progress and Done, ordered `proposed → active → review → done`.
- Surface each `review` ticket's `pr:` link in its card (it is "awaiting review/merge").
- Keep it uniform with the existing board styling — the [[chief-designer]] should sign off on the
  column's visual treatment so the four columns read as one system (the Owner's elegant/uniform
  mandate).

**Acceptance:** the Console Work board renders the four columns with `review` tickets in
In-review; column order matches the [[work-readme]] lifecycle; no regression to the existing
columns; the change lands in the Console repo on independent review ([[adr-022]], periphery). See
[[adr-003]], [[work-readme]], [[work-097]].
