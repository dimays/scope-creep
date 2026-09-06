---
name: adr-014
description: Owner-directed amendment loosening the PR-merge gate — a merge is gated on a green CI gate + Owner approval (implicit in conversation or explicit), and once approved a ratified git-manager/developer agent may EXECUTE the merge on any Scope-Creep repo and record it. Refines INVARIANTS §III.7/§III.10 ("only the owner disposes" → the owner disposes by approving). Does not touch deploy/spend/delete/publish, which stay Owner-executed via the guard-gates hook.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# ADR-014: Delegated PR-merge execution

- **Status:** accepted
- **Date:** 2026-09-06
- **Deciders:** **Owner** (directed the amendment; only the Owner may amend
  [[invariants]], §I.2), Chief of Staff (ratified + recorded). CRO review is
  recommended for a governance change of this weight and remains available; the
  Owner directed it expedited.
- **Owner-gated:** yes — this is an INVARIANTS amendment, made on the Owner's
  explicit direction.
- **Amends:** [[invariants]] §III (adds the §10 clarification; bumps to v1.2.0).

## Context
Merging a PR to `main` had effectively been treated as an Owner-only keystroke: the
docs read "only the owner disposes" (§III.7) and "gated merge" (§III.10), and in
practice the Owner clicked every merge. Two facts made this friction, not safety:
1. The mechanical gate (`.claude/hooks/guard-gates.sh`) never blocked `gh pr merge` —
   it blocks `fly deploy`/`destroy`, `npm/bun publish`, `gh release create`, and
   force-push. So "merge is human-gated" lived only in prose, enforced by the harness
   permission prompt, not by the project's own gate.
2. The Owner is already in the loop on every merge — approving it in conversation.
   Requiring the Owner to *also* perform the click adds a step without adding a check.
The Owner directed a more permissive rule: **approval is the gate; execution may be
delegated** to a dedicated agent.

## Decision
1. **A PR merge is gated on two things: a green CI gate, and Owner approval.** Not the
   Owner's keystroke. Approval may be **implicit** (a conversational go-ahead — "merge
   those", "ship it", "go ahead") or **explicit** (a direct yes to a merge question).
2. **Once approved, a ratified [[git-manager]] / developer agent may execute the merge**
   on any Scope-Creep repo (`scope-creep`, `scope-creep-console`, `scope-creep-design`,
   `scope-creep-ext-*`), and records it in the [[ledger]]. The agent is created and
   ratified per [[adr-002]]; recorded in [[ledger-035-delegated-merge]].
3. **Preconditions the executing agent must satisfy** (verify, don't assume): the PR is
   **green** and **mergeable**, its diff matches what was approved, and — for a stacked
   PR — it is merged **parent-first with children retargeted**, so the orphan-close
   failure of 2026-09-06 ([[ledger-033-realtime-delegation-round]] aftermath) does not
   recur. Every merge appends a ledger record.
4. **What this does NOT change.** §III.7's other gates stand, Owner-executed at the
   moment of action, still enforced by `guard-gates`: **deploy, spend, delete, publish**
   (and force-push / release). A **red** CI gate is never waivable by an agent — only
   the Owner waives red ([[engineering-policy]] §1). Core-upgrade and other load-bearing
   merges still carry their own Owner approval + CRO verification ([[decision-rights]]).

## Two layers (be honest about enforcement)
This ADR is the **org-policy** layer — it authorizes the agent within Scope Creep. The
**harness-permission** layer is separate: whether the agent can actually run `gh pr merge`
without a per-call prompt depends on the Claude Code permission rules (e.g. an
`allow: Bash(gh pr merge*)` grant in `settings.local.json`, applied by the Owner, the way
the QA-tester hook grant was). The policy change alone does not silence the harness prompt;
the grant is the operational counterpart. This is intentional defense-in-depth, not a bug.

## Consequences
- The Owner stops being a merge button and stays a merge **approver**; the git-manager
  lands approved, green PRs and keeps merge hygiene (stacked order, retargeting, cleanup).
- Auditability is preserved (green gate + ledger record on every merge) and improved (a
  single agent owning merge order prevents the orphaned-PR class of error).
- The blast radius is bounded: only *merge* is delegated, only on Scope-Creep repos, only
  post-approval, only when green. Everything genuinely irreversible/outward stays gated.
- The Owner can revoke at any time (this ADR is superseded by a new one; the harness grant
  is removed).

## Alternatives considered
- **Keep merge as an Owner-only keystroke** — rejected by the Owner: friction without a
  check, since approval already happens in conversation.
- **Delegate merge to any agent** — rejected: scope it to a single ratified git-manager so
  responsibility (and the merge-hygiene discipline) has one owner.
- **Also delegate deploy/spend/publish** — rejected: those are genuinely irreversible or
  outward-facing; they stay Owner-executed at the moment of action.
