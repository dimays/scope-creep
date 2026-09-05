---
id: work-015
title: Sandboxed, state-preserving live preview of proposed edits
type: feature
status: proposed
priority: high
owner: cto
spec: prd-chatbot-extension
created: 2026-09-05
updated: 2026-09-05
---
Second clause of [[work-001]]'s split: **edits render in-place in a preview.** Apply a
chatbot-proposed edit in an **isolated git worktree** (never the running checkout),
build/serve it, and show the diff + a state-preserving preview ([[adr-009]]).

**Owner-approved (2026-09-05):** [[adr-009]] is accepted — the agent live-write-access
capability is authorized in this gated context. Ready to build. CRO: still verify the
worktree can't reach the live app or other apps before trusting isolation.

**Acceptance:** a proposed edit renders in an isolated preview without disturbing the
running app; the diff is visible in chat. See [[adr-009]].
