---
name: adr-009
description: How a chatbot-proposed edit is isolated, previewed live, and merged only through the existing gated PR flow — and the security line this crosses.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# ADR-009: Sandboxed live preview & gated merge

- **Status:** proposed
- **Date:** 2026-09-05
- **Deciders:** CTO (drafted, scheduled run), Chief Designer, CRO — awaiting Owner
- **Owner-gated:** yes (proposed) — see the security note; do NOT build work-015/016
  until the Owner signs off.

## Context
The chatbot proposes edits to an app's code. Those edits must (1) render **live** in
a preview so the Owner sees exactly what they'll get, and (2) reach `main` only
through the same gated flow every other change uses.

## Decision
- **Isolation:** each proposal is applied in an **isolated git worktree** off the
  app's repo — never the running checkout. The preview builds/serves from the
  worktree; the live app is untouched.
- **Preview:** the proposal's diff is shown in chat; the preview renders it with
  state-preserving reload where the stack allows (Golden Path: Vite HMR).
- **Merge path (unchanged):** approve → branch + commit + **open a gated PR** → CI
  `test` gate must pass → merge (the Owner's admin-bypass, or a green required
  check). Decline → discard the worktree. **Never auto-merge; never merge red.**
- The existing `guard-gates.sh` + `main-gate` ruleset still apply.

## Security note (load-bearing — the reason this is Owner-gated)
This is the **first capability that grants an agent live write access to app code
in-session.** It crosses an INVARIANTS §III line. The mitigations above keep it
safe: the agent only *proposes*, isolation prevents touching the running app, and
nothing reaches `main` except through the human-gated, CI-gated PR flow. **The Owner
must explicitly accept this ADR before `work-015`/`work-016` are built.** The CRO's
standing note: verify the isolation actually holds (worktree can't reach the live
app or other apps) before trusting it.

## Consequences
- A powerful, safe self-editing loop that reuses all existing gates.
- New machinery (worktree management, preview serving) the CTO owns.

## Alternatives considered
- **Edit the live checkout directly** — rejected: unsafe, no isolation, no clean
  discard.
- **Auto-merge on green** — rejected: removes the human gate on code the Owner
  hasn't seen; violates the propose-don't-dispose rule.
