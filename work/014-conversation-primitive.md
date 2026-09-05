---
id: work-014
title: Shared conversation primitive + in-app agent runtime
type: feature
status: done
priority: high
owner: cto
spec: prd-chatbot-extension
branch: work-014-conversation
pr: https://github.com/dimays/scope-creep-console/pull/6
created: 2026-09-05
updated: 2026-09-05
---
The backend half of [[work-001]]'s split, shared with Work Requests v2 ([[adr-008]]):
a conversation model (threads/messages/roles) + an **agent-turn endpoint** the Console
calls via the Claude Agent SDK (server-side auth), with a per-application scoped tool
set (Grant). Generalize the existing `requests`/`request_messages` tables into it.

**Done (2026-09-05):** shipped in Console 0.9.0 (gated PR #6, fix PR #7) — persisted
`conversations` + `conversation_messages`, an agent-turn endpoint (resource route
`/chat/send`) that calls Claude when `ANTHROPIC_API_KEY` is set with a labeled
fallback otherwise, wired into the Chat tab. Verified end to end. Text-only; tools
arrive with [[work-015]]/[[work-016]]. **Deferred:** migrating Work Requests onto this
primitive (kept its tables intact to avoid a risky refactor now).

**Acceptance:** a conversation model + an agent-turn endpoint that produces an agent
message for a thread; Work Requests can adopt it for live triage. Tools are scoped per
consumer. See [[adr-008]].
