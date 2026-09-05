---
name: adr-008
description: A shared conversation primitive (threads/messages/roles + an agent-turn runtime) backing both Work Requests v2 and the chatbot extension.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# ADR-008: A shared conversation primitive

- **Status:** proposed
- **Date:** 2026-09-05
- **Deciders:** CTO (drafted, scheduled run), CPO — awaiting Owner
- **Owner-gated:** yes (proposed)

## Context
Two features need an in-app agent conversation: **Work Requests v2** (live chat over
an intake thread) and the **chatbot extension** (chat that edits an app). Building
two would fork the model and the runtime.

## Decision
Build **one conversation primitive**, consumed by both:
- **Data:** a conversation is a `thread` + ordered `messages`, each with a `role`
  (`owner` | `agent` | `system`) and optional structured `attachments` (e.g. a
  proposed diff). Work Requests' existing `requests`/`request_messages` tables
  generalize into this.
- **Runtime:** an **agent-turn endpoint** the Console backend calls to produce an
  agent message via the Claude Agent SDK (Claude auth server-side). The caller
  supplies the thread + a scoped tool/permission set.
- **Scoping is per-application:** Work Requests grants the agent *backlog* tools
  (triage/route/ticket); the chatbot grants *code* tools behind the [[adr-009]]
  sandbox + gates. Same primitive, different Grants.

## Consequences
- One model, one runtime, two consumers; Work Requests v2 stops being bespoke.
- Introduces an in-app agent runtime with server-side Claude auth — a new dependency
  the CTO owns; keep it small and behind Grants.
- `work-014` builds this; Work Requests v2 migrates onto it.

## Alternatives considered
- **Two separate chat systems** — rejected: duplicated model + runtime, divergence.
- **Reuse a third-party chat runtime** — rejected: couples the core to an external
  service; violates single-user/base-repo-is-the-product.
