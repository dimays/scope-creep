---
name: adr-007
description: Establish the Chief Reality Officer — an independent verifier that cross-checks decisions/research/outputs for hallucinations and unchecked assumptions.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# ADR-007: Establish the Chief Reality Officer

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** Owner (proposed), Chief of Staff (ratified)
- **Owner-gated:** yes

## Context
Scope Creep is a system of AI agents making consequential decisions. The dominant
failure mode of that is **confident fabrication and unchecked assumptions** — and we
just hit a live one: enabling the merge gate was planned on the assumption that
branch protection was available, when it's Pro-gated for private repos ([[ledger-009-branch-protection]]).
A dedicated skeptic would have asked "is that verified?" before we spent the steps.

## Decision
Add the **Chief Reality Officer (CRO)** as a sixth core C-suite agent. It has no
domain to defend; it cross-checks any load-bearing decision, research assignment, or
"done/works" claim for hallucination, invention, and unchecked assumptions —
labeling claims verified / inferred / assumed, naming the assumption most likely to
break the plan, and preferring a runnable check over an opinion (including its own).

**Scoped to avoid ceremony** (per the CPO's anti-ceremony principle in [[adr-006]]):
invoked at high-stakes checkpoints — ADR-worthy decisions, research/claims about to
be acted on, consequential "done" assertions, and the [[ticket-cycle]] judgment
forks — **not** routine edits. It advises and may flag verify-before-proceed; the
CoS or Owner adjudicates. It does not set direction.

## Consequences
- An independent check against the exact failure mode AI agent orgs are prone to.
- Core org is now six; org changes remain CoS-ratified ([[adr-002]]).
- Woven into [[ticket-cycle]] as a reality-check at decision/research checkpoints.

## Alternatives considered
- **A policy/checklist instead of an agent** — rejected: verification benefits from
  an independent actor with a standing mandate, not a box the deciding agent ticks
  on itself.
- **Invoke on everything** — rejected: ceremony; scoped to high-stakes checkpoints.
