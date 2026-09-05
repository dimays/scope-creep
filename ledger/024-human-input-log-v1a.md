---
name: ledger-024-human-input-log-v1a
description: Human-Input Log v1a shipped (work-012) — the read-model timeline; v1b (terminal capture hook, work-020) awaits Owner approval.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 024 — Human-Input Log v1a

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[prd-human-input-log]], [[adr-010]])
Console 0.13.0 (gated PR #12): Work → **Inputs** — the Human-Input Log v1a. A
projection that **owns no data**: unions the three already-captured Owner-input sources
(chat / requests / feedback), tags each by Source + Intent, interleaves git-derived
"work between inputs" interludes, and shows a leverage readout. Verified live (the first
input was request #2, with an 8-commit interlude beneath it).

## Awaiting Owner — v1b
**[[work-020]]** (the `UserPromptSubmit` hook + `human-input/` NDJSON that captures the
terminal surface — the richest input channel, currently shown as a "capture pending"
gap) is a **core change** touching `.claude/settings.json` + a new record set. It needs
the Owner's approval + an ADR/core-upgrade before it's built.

## Next
Per the Owner's plan: a level-setting round — evaluate the c-suite pool, operating
standards, the Consistency issues, and the backlog; pay down tech/doc/system debt.
