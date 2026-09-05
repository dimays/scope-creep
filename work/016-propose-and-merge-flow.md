---
id: work-016
title: Propose → gated PR → merge (approve/decline in chat)
type: feature
status: done
priority: medium
owner: cto
spec: prd-chatbot-extension
branch: work-016-land
pr: https://github.com/dimays/scope-creep-console/pull/9
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

**Done (2026-09-05):** shipped in Console 0.11.0 (gated PR #9). `landProposal` builds a
proposal on an isolated branch (worktree), pushes, and opens a **gated PR**
(`/chat/land`); decline closes the PR + deletes the branch (`/chat/decline`). Never
auto-merges. **Verified live end to end:** the chat landed a real edit → gated PR #10
→ CI green → merged → `main` updated, with the live checkout untouched throughout.
The software edited itself, safely and gated.
