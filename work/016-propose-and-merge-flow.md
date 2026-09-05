---
id: work-016
title: Propose → gated PR → merge (approve/decline in chat)
type: feature
status: proposed
priority: medium
owner: cto
spec: prd-chatbot-extension
created: 2026-09-05
updated: 2026-09-05
---
Third clause of [[work-001]]'s split: **approving merges via the gated flow.** In chat,
approve a proposal → open a gated PR (branch + commit) → CI `test` gate must pass →
merge; decline → discard the worktree. Never auto-merge, never merge red.

**Owner-approved (2026-09-05):** [[adr-009]] accepted. Merge stays human-gated; the
existing ruleset + `guard-gates.sh` still apply.

**Acceptance:** approving a chat proposal opens a gated PR and merges on green;
declining discards cleanly; nothing reaches `main` un-gated. See [[prd-chatbot-extension]].
