---
name: ledger-023-human-input-log-plan
description: Human-Input Log refined by CPO + CTO into a projection-only design; work-012 elevated to v1a (top), v1b split to work-020 (Owner-gated).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 023 — Human-Input Log (refined + planned)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Decision ([[adr-010]], [[prd-human-input-log]])
The Owner made the Human-Input Log top priority; CoS convened the CPO (taxonomy +
experience) and CTO (capture architecture). Ratified: the log **owns no data** — a
generated projection (union read over the Console DB + git + `ledger/` + a new
`human-input/` set). Taxonomy: Source × Intent (dual-axis, MECE channel × facet).
Interludes derived, not stored. CPO pushback accepted: "top priority" → top of the
quick-win lane (parallel to the flagship), and no bespoke capture pipeline / no ML.

## Split
- **[[work-012]]** raised medium → high, refined to **v1a** (read-model timeline over
  the 3 already-captured sources + git/ledger interludes; terminal/gate shown as
  "capture pending"). Pure periphery, no gate — building now.
- **[[work-020]]** created for **v1b** — the `UserPromptSubmit` hook + `human-input/`
  NDJSON + Consistency self-checks. **Owner-gated core change** (touches `.claude/`).
