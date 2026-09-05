---
name: ledger-018-conversation-primitive
description: work-014 done — in-app agent runtime + conversation primitive shipped; ADR-008 accepted.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 018 — Conversation primitive + agent runtime (work-014 done)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[adr-008]], accepted)
Console 0.9.0 (gated PR #6, fix PR #7): the **in-app agent runtime** — persisted
`conversations` + `conversation_messages`, and an agent-turn endpoint (resource route
`/chat/send`) that calls Claude server-side when `ANTHROPIC_API_KEY` is set, with a
clear labeled fallback otherwise. The Chat tab now runs on it (the stub is gone).
Text-only; code tools arrive with [[work-015]]/[[work-016]] behind [[adr-009]].

## Verified + a bug caught and fixed live
Demoed end to end. Initial demo surfaced a real bug — posting to the `/chat` UI route
re-rendered the page instead of returning JSON, so the shell couldn't read the reply.
Fixed by moving the action to a resource route (PR #7). The CRO-style live check paid
off.

## Deferred
Migrating Work Requests onto the shared primitive (its tables kept intact to avoid a
risky refactor). Real Claude replies await an `ANTHROPIC_API_KEY` (Owner-set).

## Flagship epic status
✅ work-013 (shell) · ✅ work-014 (runtime) · ⬜ work-015 (live preview, unblocked) ·
⬜ work-016 (propose→merge, unblocked).
