---
name: ledger-019-preview-sandbox
description: work-015 done — the ADR-009 preview isolation engine shipped and verified; interactive preview split into work-017.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 019 — Preview sandbox (work-015 done)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[adr-009]] — the safety core)
Console 0.10.0 (gated PR #8): the **preview isolation engine**. Given a proposal,
apply it in a throwaway **git worktree** at HEAD, return the diff, and prove the live
working tree is untouched (`/chat/preview`). A path-safety gate rejects any edit that
could escape the repo.

## Verified live (the CRO's isolation requirement)
`liveClean: true`; the live repo's `git status` was empty **before and after**; an
unsafe `../` path returned **400**; `git worktree list` showed the throwaway worktree
was cleaned up. The agent's write access lands only in an isolated sandbox — never the
running app.

## Split (CTO)
The *interactive* live-serve preview + in-chat diff + **agent-generated proposals**
(code tools) are substantial and separable — moved to **[[work-017]]**. This ticket
delivered the safety-critical isolation.

## Flagship epic
✅ work-013 shell · ✅ work-014 runtime · ✅ work-015 isolation engine · ⬜ work-016
(propose→merge) · ⬜ work-017 (interactive preview + agent code-tools).
