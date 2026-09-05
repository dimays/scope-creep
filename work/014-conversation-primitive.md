---
id: work-014
title: Shared conversation primitive + in-app agent runtime
type: feature
status: active
priority: high
owner: cto
spec: prd-chatbot-extension
branch: work-014-conversation
created: 2026-09-05
updated: 2026-09-05
---
The backend half of [[work-001]]'s split, shared with Work Requests v2 ([[adr-008]]):
a conversation model (threads/messages/roles) + an **agent-turn endpoint** the Console
calls via the Claude Agent SDK (server-side auth), with a per-application scoped tool
set (Grant). Generalize the existing `requests`/`request_messages` tables into it.

**Acceptance:** a conversation model + an agent-turn endpoint that produces an agent
message for a thread; Work Requests can adopt it for live triage. Tools are scoped per
consumer. See [[adr-008]].
