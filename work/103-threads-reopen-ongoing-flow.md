---
id: work-103
title: Verify reopen-ongoing-thread flow works end-to-end
type: bug
status: active
priority: medium
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
**Owner report (2026-09-21):** the Owner wants confidence that **reopening a conversation on an
ongoing thread** works well, but couldn't test it because the launch→link path ([[work-102]]) is
broken.

## Scope
The full loop, verified empirically by running the console:
1. Launch a thread → send the seeded prompt in Claude Code → the session gets the
   `[scope-creep-thread:<id>]` marker.
2. The in-app thread **correlates** and projects the transcript (short-poll revalidation should
   pick up new turns with no manual reload — the existing 3s poll in `thread.tsx`).
3. **Reopen** the thread later → the projected transcript is still there, and the resume control
   reopens the **same** conversation (per [[work-102]]).
4. Continue the conversation in Claude → new turns appear in the projected transcript on the
   next poll.

## Dependencies
Blocked on [[work-101]] (folder) + [[work-102]] (resume-existing). This ticket is the end-to-end
acceptance of that chain.

## Acceptance
[[qa-tester]] demonstrates the reopen-ongoing loop with evidence (a real launched session, its
correlated transcript, a reopen that lands on the existing conversation, and a new turn showing
up on poll). Any step that genuinely requires the Owner's own Claude Desktop is written up as a
precise Owner acceptance check rather than claimed proven. See [[work-100]], [[adr-016]].
