---
id: work-018
title: Model selection (user- and agent-pickable)
type: feature
status: done
priority: medium
owner: chief-product-officer
spec: prd-chatbot-extension
created: 2026-09-05
updated: 2026-09-06
---
Make the model a choice, not a hardcode. Two axes:
- **Owner-pickable:** a model picker in the Console (chat / settings), persisted, that
  sets the chat model (the runtime already reads `CHAT_MODEL` — [[adr-008]]).
- **Agent-pickable:** a documented policy so agents/subagents select a model per task
  as the system grows — a cheap/fast model for routine turns, a stronger model for hard
  reasoning/agentic work.

Seed the picker + agent policy from the committed catalog **`reference/models.json`**
([[reference]]) — `{id, tier, input$, output$, context}` for the current Claude API
models, plus `defaults` (chat → sonnet-5, agentic → opus-5, routine → haiku). Always
falls back to a sane default; validate against the catalog (retired IDs fail hard).

**Acceptance:** the Console exposes a persisted model picker that drives the chat
model; an agent model-selection policy is documented; unknown/failed IDs fall back
cleanly. Broader than the chatbot — the agent-policy half applies system-wide.
