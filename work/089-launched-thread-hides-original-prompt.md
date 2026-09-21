---
id: work-089
title: Bug — a launched thread's view hides the Owner's original prompt
type: bug
status: proposed
priority: high
owner: cto
spec: prd-cos-threads
created: 2026-09-08
updated: 2026-09-08
---
Clicking **"Open in Claude Code"** on a thread launches it, and the launched thread view then
**stops showing the Owner's original prompt**. The data is intact in the DB (thread #9, message
24 — the capstone-vision request); the launcher does not delete it, but the rendered thread
hides it, so the Owner opens the thread and their own ask is gone from view.

**Root cause (`scope-creep-console` `app/routes/thread.tsx`, ~L217–226).** Once a thread is
`launched`, the message loop drops every plain message with `if (launched) return null;` — on
the assumption the **projected transcript** (from local Claude session JSONL, [[adr-016]])
will show them instead. But the Owner's original prompt is a first-class `role:"owner"
type:"message"` thread record, and the projection can be **empty or unavailable** — a
cloud-launched session, an uncorrelated session, or session JSONL simply not present on this
host. When it is, the seed message renders **nowhere**.

**Why this matters now — and why it's a genuine gap.** Both the Request Loop *and* the proposed
[[work-sweep]] loop produce **cloud-launched threads with no local JSONL on the Owner's
machine** — exactly the case where the projection is empty and the original ask vanishes. This
is checked against the in-flight thread-UX / owner-notification tickets and is **not covered**:
- [[work-063]] — read-state / unread badge / notification center (not message rendering);
- [[work-081]] / [[work-082]] — the Console **activity** read-model + render (not the thread
  transcript);
- [[work-083]] / [[work-085]] — **Owner-action** items source + render (a different surface).

None touch the launched-thread message-visibility logic. Filing as a distinct bug.

**Fix direction (for the assignee to confirm):** always render the Owner's original prompt (the
seed `role:"owner" type:"message"`) in the thread view regardless of `launched`/projection
state — the projected transcript supplements it, never replaces it. Keep the honest-empty
projection copy for the *assistant* side.

**Gate class — agent-buildable periphery** (the Console app; no `.claude/**`, no core, no ADR).
Ordinary [[dev-cycle]]; a bug ticket starts with a **failing test** ([[ticket-cycle]]) — a
launched thread with an empty projection must still render its seed message.

**Acceptance:** a launched thread whose projection is empty/unavailable still shows the Owner's
original prompt (reproduced against thread #9); a regression test covers "launched + empty
projection → seed message visible"; the assistant-side projection keeps its honest-empty state.
See [[prd-cos-threads]], [[adr-016]].
