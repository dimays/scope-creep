---
name: reference
description: Reference data pulled from external sources (not generated) — e.g. the Claude API model catalog.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# reference/

External reference data, hand-pulled (not harvested), with provenance in each file's
`_source` + `_pulled` fields. Re-pull periodically; treat prices/IDs as
point-in-time.

- **[models.json](models.json)** — the Claude API model catalog (id, tier, input/output
  $/MTok, context, defaults). Seeds the Console model picker and the agent
  model-selection policy ([[work-018]]). Dateless IDs (`claude-*-5`) are pinned; the
  Haiku entry uses the pinned dated ID. Prices are USD per million tokens.
