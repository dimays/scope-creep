---
name: ledger-021-model-catalog
description: Claude API model catalog pulled and committed (reference/models.json) to seed work-018's model picker + agent policy.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 021 — Model catalog

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## What
Pulled the current Claude API model IDs + pricing from Anthropic's docs (via the
claude-code-guide agent) and committed them as **`reference/models.json`** ([[reference]]):
Fable 5.1 ($10/$50), Opus 5 ($5/$25), Sonnet 5 ($2/$10), Haiku 4.5 ($1/$5) per MTok;
batch −50%, cache-read ~0.1×. Defaults: chat → `claude-sonnet-5`, agentic →
`claude-opus-5`, routine → `claude-haiku-4-5-20251001`.

## Why
Seeds **[[work-018]]** (model selection — Owner-pickable + agent-pickable). Also
confirmed the Console's existing default `CHAT_MODEL=claude-sonnet-5` is a valid,
active, pinned ID — so real chat replies work once an `ANTHROPIC_API_KEY` is set.

## Note
Prices/IDs are point-in-time; re-pull periodically. Prefer dateless pinned IDs;
retired IDs fail hard (no fallback) — the picker must validate against the catalog.
