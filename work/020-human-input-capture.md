---
id: work-020
title: Human-Input Log — v1b (terminal capture hook)
type: feature
status: proposed
priority: high
owner: cto
spec: prd-human-input-log
created: 2026-09-05
updated: 2026-09-05
---
**v1b** of the Human-Input Log ([[prd-human-input-log]], [[adr-010]]) — captures the
richest surface (the terminal / first-class Claude session). **Owner-gated core change.**

- A **`UserPromptSubmit` hook** in `.claude/settings.json` that appends one NDJSON line
  per Owner prompt to a new **`human-input/YYYY-MM.ndjson`** record set (with a redaction
  guard so a pasted secret never lands in git).
- The Console's Human-Input Log ([[work-012]]) unions `human-input/` in (via
  `SCOPE_CREEP_HOME`) so terminal inputs appear.
- **Consistency self-checks:** flag work/merges in a window with no preceding captured
  input (missed input / uninstalled hook) + dup ids.

**Owner-gated:** touches `.claude/` and adds a new core record set → ADR + `core-upgrade`
+ Owner approval; the loop may draft, never self-merge.

**Acceptance:** an Owner prompt in a hooked session becomes a `human-input/` line;
the Console log shows terminal inputs; Consistency flags gaps. See [[adr-010]].
