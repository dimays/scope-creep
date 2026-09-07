---
id: work-064
title: Wire the org's async write-back into threads (critical-update / needs-input types)
type: feature
status: proposed
priority: high
owner: cto
spec: prd-request-loop
created: 2026-09-07
updated: 2026-09-07
---
The thread writers `createOrgThread` / `orgFollowup` / `addGeneratedRequest` exist in
`threads.server.ts` with **zero production callers** — the org *can* post an update and flip
a thread to `needs-you`, but nothing invokes it. Today the org's side of a thread exists
only inside a launched Claude session, projected read-only ([[adr-016]]). This wires the
async write-back that Pillars I–II of [[prd-request-loop]] depend on.

Build:
- **Wire the writers** so a triage decision / progress update lands in the thread as a
  `role = agent` message and the existing typed cards (`OutcomeCard`,
  `GeneratedRequestCard`) render it.
- **Message types** that distinguish a *critical-update* (FYI, thread stays the org's) from
  a *needs-your-input* (parks the thread on the Owner at `needs-you`), so the important
  moments are visually distinct from routine chatter.

**Acceptance:** a process without a launched session (an agent, or the [[request-triage]]
routine) can post an update or a question into a thread and set status accordingly; the
thread renders it as a typed card; a needs-input message is visually distinct and drives the
unread signal from [[work-063]]. See [[adr-012]], [[adr-016]], [[work-063]], [[work-066]].
