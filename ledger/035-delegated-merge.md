---
name: ledger-035-delegated-merge
description: Owner amended INVARIANTS §III (v1.2.0) to make a PR merge gated on green CI + Owner approval rather than the Owner's keystroke (ADR-014), and authorized a git-manager agent to execute approved merges on Scope-Creep repos. Records the amendment, the agent creation (ADR-002), and the harness grant still needed.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 035 — Delegated merge execution + Git Manager

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff (Owner-directed)

## What changed
The Owner directed a more permissive merge rule: **approval is the gate, not the
keystroke.** Amended and recorded:
- **[[invariants]] → v1.2.0:** §III.10 gains an Owner-approved clarification — a PR merge is
  gated on a **green CI gate + Owner approval** (implicit conversational go-ahead or an
  explicit yes); a ratified agent may then *execute* it. Refines §III.7 ("the owner disposes
  by **approving**"). The `deploy`/spend/`delete`/publish gates are untouched.
- **[[adr-014]]** (accepted): the decision, its preconditions (green + mergeable + diff
  matches approval + stacked-parent-first + ledger record), and the honest two-layer note
  (org policy ≠ harness permission).
- **[[git-manager]]** created (ratified per [[adr-002]]): the version-control operator that
  lands approved work and owns merge hygiene — the role that would have prevented the
  stacked-PR orphan-close earlier today. Registry regenerated (`registry/agents.json`, 8
  agents). Pairs with the [[qa-tester]] (QA proves green; git-manager lands it).
- Notes added to [[decision-rights]], [[tech-sops]] §9.

## Why (grounding)
`guard-gates.sh` never blocked `gh pr merge` — it blocks deploy/destroy/publish/force-push.
So "merge is human-gated" lived only in prose, enforced by the harness prompt while the
Owner approved every merge in conversation anyway. Requiring the keystroke on top added a
step without adding a check.

## Still needed (harness grant — Owner applies)
Org policy authorizes the git-manager, but the harness may still prompt on `gh pr merge`.
To let it land approved PRs without per-call friction, add an allow rule in
`scope-creep/.claude/settings.local.json` (gitignored), e.g.
`"Bash(gh pr merge*)"` — the same pattern as the QA-tester hook grant ([[ledger-034-qa-tester]]).
The CoS will prepare the exact rule for the Owner to apply.

## Scope & guardrails (unchanged invariants)
Only **merge**, only **Scope-Creep repos**, only **post-approval**, only when **green**.
A red gate is waivable only by the Owner. Deploy/spend/delete/publish stay Owner-executed at
the moment of action. The Owner can revoke (supersede [[adr-014]]; remove the grant).

## CRO note
A governance change of this weight normally gets a CRO verification pass ([[decision-rights]]).
The Owner directed it expedited; CRO review remains available and is recommended before the
harness grant is applied.
