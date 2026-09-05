---
name: ledger-012-feedback-extension
description: work-006 done — the feedback Extension shipped and grafted onto the Console; first extension registered.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 012 — Feedback Extension (work-006 done)

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Delivered
- **`scope-creep-ext-feedback`** (public, v0.1.0): a framework-agnostic, portable
  **Shadow-DOM graft** (`mountFeedback`) themed by host `--sc-*` tokens, with
  host-agnostic `onSubmit` persistence and once-per-`contextKey` non-nagging. Own
  green gate + `main-gate` ruleset. Registered in `registry/extensions.json` (first
  extension).
- **Console 0.5.0** grafts it onto Explore (gated PR #2); a `feedback` table +
  `/feedback` action persist responses. **Verified end-to-end** — recorded a live
  feedback row.

## Why it mattered
Proves the **portable-graft + style-isolation** pattern on a small surface before
the flagship chatbot ([[work-001]]) bets on it. Second clean gated-autonomous cycle
(branch → PR → CI green → merge).

## Next in sequence
`work-001` (flagship chatbot extension) — now de-risked. But see the Owner's new
intake request captured in [[ledger-013-work-intake-request]].
