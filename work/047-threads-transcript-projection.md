---
id: work-047
title: Threads transcript projection from local Claude session data (no Claude calls)
type: feature
status: done
priority: high
owner: cto
spec: prd-cos-threads
created: 2026-09-06
updated: 2026-09-06
---
The projection half of the [[adr-016]] reframe — capture the conversation's
responses/follow-ups back into the in-app thread transcript, the [[adr-016]] hard way:
**the app reads local data and makes ZERO automated Claude calls.**

Key finding (2026-09-06): **Claude Code sessions store full local JSONL transcripts** at
`~/.claude/projects/<project>/<session>.jsonl` — locally readable, so ToS-clean to project.
**Claude Desktop / claude.ai chats do NOT** — their transcripts live server-side and cannot
be projected without a Claude call. **This is the crux of the [[work-044]] surface decision:**
the auto-captured transcript the Owner wants is achievable cleanly only on the Claude Code path.

- Read the relevant local session JSONL, map turns → the thread's projected transcript
  (owner/agent messages, tool activity at a high level), reusing the [[prd-human-input-log]] /
  operator-session projection pattern. Never invent turns; "empty is empty."
- If the surface decision lands on Claude Desktop instead, this ticket degrades to a
  manual/summary capture (no auto-sync) — call that out; don't pretend to sync server-side data.
- Any machine-generated summary must run on an **API key**, never subscription ([[adr-016]]).

**Acceptance:** after a conversation happens in the launched Claude session, the in-app
thread shows its transcript, projected from local data, with no Claude API call. See
[[work-044]], [[work-046]], [[adr-016]].
