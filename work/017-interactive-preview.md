---
id: work-017
title: Interactive live-serve preview + in-chat diff + agent-generated edits
type: feature
status: proposed
priority: high
owner: cto
spec: prd-chatbot-extension
created: 2026-09-05
updated: 2026-09-05
---
The interactive half of the preview, split from [[work-015]] (which shipped the
isolation engine). Three parts:
- **Serve the worktree** as a state-preserving live preview (Vite HMR) on a preview
  port; surface it (iframe) in chat alongside the diff.
- **Render the diff in chat** (the [[work-013]] shell gains a diff/attachment block).
- **Agent-generated proposals:** give the [[work-014]] runtime code tools so a natural-
  language request produces the `{path, content}` edits the sandbox previews (the
  Agent SDK / tool loop, behind [[adr-009]] gates).

**Acceptance:** the Owner describes a change in chat → the agent proposes edits → the
diff + a live interactive preview appear in chat, all isolated. Merge is [[work-016]].
