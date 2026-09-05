---
id: work-015
title: Sandboxed, state-preserving live preview of proposed edits
type: feature
status: done
priority: high
owner: cto
spec: prd-chatbot-extension
branch: work-015-sandbox
pr: https://github.com/dimays/scope-creep-console/pull/8
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

**Done (2026-09-05):** shipped in Console 0.10.0 (gated PR #8) — the **isolation
engine**: apply a proposal in a throwaway git worktree, return the diff, and prove
the live working tree is untouched (`/chat/preview`), with a path-safety gate.
Verified live: `liveClean:true`, live repo clean before/after, unsafe paths → 400,
worktree cleaned up. **Split:** the *interactive* live-serve preview + in-chat diff +
agent-generated proposals (code tools) are [[work-017]] — this ticket delivered the
safety-critical isolation core.
