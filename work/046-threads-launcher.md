---
id: work-046
title: Threads launcher — submit opens a seeded Claude conversation; resume reopens it
type: feature
status: done
priority: high
owner: cto
spec: prd-cos-threads
created: 2026-09-06
updated: 2026-09-06
---
The launcher half of the [[adr-016]] reframe and the Owner's 2026-09-06 feature-flow spec.
**Blocked on the surface decision in [[work-044]]** (Claude Desktop vs Claude Code — it sets
the deep-link target and whether resume is thread-precise).

Owner's desired flow:
- Start with a prompt in the UI → **Submit** opens a thread in Claude with the typed message
  as the **first message** of a NEW conversation. Verified working: `claude://claude.ai/new?q=<msg>`
  is registered on the Owner's machine and fires (opens Claude Desktop, seeds the message).
  (Claude Code equivalent: `claude-cli://open?repo=<slug>&q=<msg>` — new session, prefilled.)
- After submit, the thread's **input box is disabled/hidden**; a **"Resume in Claude" button**
  reopens the existing conversation. Thread-precise resume is `claude://claude.ai/chat/{uuid}`
  (needs the chat UUID — only available on the claude.ai/Desktop path) or `claude --resume <id>`
  (Claude Code, CLI). Provide a **generic-open floor** where precise resume isn't available.

**Acceptance:** typing a prompt + Submit opens Claude with that message as the first message;
the input is then replaced by a working "Resume in Claude" control; the launcher makes no
Claude API call. See [[work-044]], [[work-047]], [[adr-016]].
