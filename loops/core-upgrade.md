---
name: core-upgrade
description: The governed path for changing the SAFETY KERNEL (INVARIANTS v2.0.0 §4). That means INVARIANTS, PRINCIPLES, the gate surface, decision-rights, the top-level executive and function charters, and dependency/infra manifests. It runs ADR → branch → green suite → Owner approval → land → record. Everything else is org-governed and lands on independent org review (ADR-028).
metadata:
  type: reference
  status: active
  version: 2.0.0
  owner_agent: cto
  last_verified: 2026-09-24
  mode: partially-autonomous
---

# Loop: core-upgrade

> **Scope ([[adr-028]]):** this loop is **only** for the **safety kernel** ([[invariants]]
> §4). A change to loops, standards, ADRs, templates, employees, registries, the PRD or the
> glossary is **not** a core-upgrade. It is ordinary org work: independent review, CRO
> verification if it's load-bearing, and a line in the digest.

## Inputs (typed)
- `proposal`: an ADR draft for the kernel change and its rationale.

## Steps
1. **Propose.** Write an ADR ([[doc-standards]] §6) and mark it `proposed`. Batch related
   kernel changes into **one** upgrade, so the Owner makes one decision rather than several.
2. **Branch.** Implement on a branch. Files agents can't write (INVARIANTS, `.claude/`,
   workflows, gate scripts) are **staged** in `scripts/owner-runbook/` with a
   `docs/owner-apply-*.md` for the Owner to apply by hand.
3. **Core test suite.** Full green gate on the control plane, plus a behavioural test of
   any changed gate script, for example classifying a synthetic path list.
4. **CRO verification.** The [[chief-reality-officer]] checks that nothing weakens a gate
   without saying so.
5. **Owner approval.** **HUMAN-GATED.** The Owner reviews, applies the staged files, and
   merges ([[invariants]] §4b: the Owner's own act).
6. **Land.** Bump the version, set the ADR to `active`, and record it.

## Termination condition
Either merged with Owner approval and a green core suite, OR rejected (the ADR is marked
`superseded`/closed and the reason recorded). Always terminal.
