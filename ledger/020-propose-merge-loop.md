---
name: ledger-020-propose-merge-loop
description: work-016 done — the approve → gated PR → merge loop shipped and verified; the software edited itself end to end.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 020 — The self-edit loop closed (work-016 done)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[adr-009]] loop closed)
Console 0.11.0 (gated PR #9): `landProposal` builds a proposal's edits on an isolated
branch (worktree, never the running checkout), pushes, and opens a **gated PR**
(`/chat/land`) — never auto-merged. `declineProposal` closes the PR + deletes the
branch (`/chat/decline`).

## Verified live — the software edited itself
The Console chat approved a real edit → an isolated branch → **gated PR #10** → the CI
`test` gate passed → merged (the Owner's gated action) → `main` updated. The live
checkout was **clean before and after** (isolation held); the worktree was cleaned up.
Proposal → isolated branch → gated PR → CI green → merge, with nothing reaching `main`
un-gated.

## Flagship epic — 4 of 5 done
✅ work-013 shell · ✅ work-014 runtime · ✅ work-015 isolation engine · ✅ work-016
propose→merge · ⬜ **work-017** (interactive live-serve preview + agent code-generation
— the "magic": the agent writes the edits from natural language).

## Milestone
The flagship's **safe self-editing loop is complete**. What remains (work-017) is the
UX magic: the agent generating proposals from the Owner's words + an interactive
preview. The safety-critical machinery is done and proven.
