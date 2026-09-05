---
name: ledger-017-chatbot-shell-and-adr009
description: work-013 done (chatbot shell shipped + grafted); Owner accepted ADR-009 (agent write access), unblocking work-015/016.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 017 — Chatbot shell; ADR-009 accepted

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered — work-013 done
- **`scope-creep-ext-chatbot`** (public, v0.1.0): a portable, framework-agnostic
  Shadow-DOM chat panel (`mountChat`) themed by host tokens, `textContent`-safe.
  Own green gate + `main-gate` ruleset. Registered in `registry/extensions.json`
  (second extension).
- **Console 0.8.0** grafts it onto a new **Chat** tab (gated PR #5) with a labeled
  stub `onSend`; verified send → echo end to end. First clause of the flagship split.

## Governance — ADR-009 accepted (Owner)
The Owner reviewed and **approved [[adr-009]]** (sandboxed live preview + gated
merge), authorizing an agent's **live in-session write access to app code** in this
gated context. `work-015` and `work-016` are **unblocked**. Merges remain
human-gated (ruleset + `guard-gates.sh`); the agent only proposes; never auto-merge.

## Next
`work-014` (conversation primitive + agent runtime — the backend the shell calls;
also powers Work Requests v2). Then `work-015` (live preview) and `work-016`
(propose→merge), now unblocked.
