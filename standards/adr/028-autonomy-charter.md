---
name: adr-028
description: The autonomy charter. The Owner's non-negotiables stay in INVARIANTS (v2.0.0). A new Owner-held PRINCIPLES doc guides every other decision, and the org makes those decisions itself (autonomy by default). "Core" narrows from the whole control-plane repo to a small safety kernel. Staffing is pre-ratified by standing rule. Owner approval must be real (not a forgeable label). Metered compute counts as spend, and local builds are not deploys. The substrate is local-first and free-first. One Owner-approved core-upgrade replaces the round-1 list of 15 Owner asks.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-24
---

# ADR-028: The autonomy charter

- **Status:** proposed → **active** when the Owner merges it and applies the staged INVARIANTS v2.0.0
- **Date:** 2026-09-24
- **Deciders:** the Owner (direction, 2026-09-24 check-in); drafted by the CoS and CEO with all seven executives; verified by the CRO
- **Owner-gated:** **yes.** It amends INVARIANTS and the safety kernel (INVARIANTS §4)

> **TL;DR:** The Owner keeps a **short list of non-negotiables** ([[invariants]] v2.0.0),
> plus a **short list of principles** ([[principles]]) to steer everything else. **Anything
> the non-negotiables don't reserve, the org decides.** "Core" shrinks from the whole repo
> to a **safety kernel**. Everything outside it lands on independent org review and shows
> up in a weekly digest with a revert path.

## Context

The Owner's direction, verbatim in [[ledger-080-owner-checkin-and-org-reevaluation]]:
*"I want the C-suite to drive this thing … escalate to me only when they **absolutely**
need it, not for superficial approval on every other PR … Perhaps we need a set of core
principles / non-negotiables, and other than that the org has leeway to make decisions."*

Why the current model fails that direction:
- **INVARIANTS §4 made the whole control plane "core".** Charter, agents, loops, standards,
  registries and the ledger all counted. So nearly every PR escalated, and the Owner
  merged 123 of 127.
- **Staffing was gated per instance.** Every summon was a PR on an Owner-owned path, so
  the org never actually used its staff ([[staffing]] §2).
- **Owner evidence could be forged.** The `owner-approved` label can be applied by
  anything acting under the Owner's shared GitHub identity, so the escalation fence
  relied on a single rail ([[ledger-080-owner-checkin-and-org-reevaluation]]).
- **The substrate leaned on paid or cloud credentials.** The round-2 plan put a
  Max-subscription token in CI. The Owner's direction is **local-first, free-first**.

## Decision

1. **Two charter documents.** [[invariants]] holds the **non-negotiables** and what is
   reserved to the Owner. [[principles]] holds **how the org decides everything else**.
   The Owner amends both (INVARIANTS §2).
2. **Autonomy by default (INVARIANTS §4a).** Whatever isn't reserved, the org decides and
   records. Escalating an org-owned decision counts as a failure.
3. **Narrow "core" to the safety kernel (INVARIANTS §4).** The kernel is:
   - INVARIANTS, PRINCIPLES, and `AGENTS.md` (the instructions every agent loads)
   - the gate surface: `.claude/`, workflows, CODEOWNERS, gate scripts, branch protection
   - [[decision-rights]]
   - the top-level executive and function charters
   - dependency and infra manifests, batched for review

   **Moving, renaming or deleting a kernel file is a kernel change.** The escalation
   check and the routine-reviewer both diff with `--no-renames`. Everything else is
   org-governed. [[core-upgrade]] now applies **only** to the kernel. This
   **supersedes [[adr-021]]'s Owner gate on new scheduled loops and cadence changes**.
   Those are org decisions now, unless they enable spend.
4. **Standing ratification (INVARIANTS §3).** Summoning or retiring an employee from an
   existing template is pre-ratified. A new template, or a change to a charter, is
   ratified individually by the CoS.
5. **Real Owner evidence (INVARIANTS §4b).** Only an act an agent cannot perform counts.
   The transition happens in phases:

   | Phase | Owner evidence | Enforced by |
   |---|---|---|
   | **A (now)** | `owner-approved` label, **applied only by the Owner's hand**. Agents must never apply it, and must never approve a PR as dimays. | The rule is written into INVARIANTS §4b. `guard-gates` v2 catches the common ways of applying the label. That check is a **string match**, so it is a tripwire, not a wall: `--input` files, GraphQL, and variable-split names get through it. The Owner's local allow-list also drops `gh pr review`. |
   | **B (after workstream 1)** | A GitHub **review by `@dimays`** on a PR the org authored as `scope-creep-routine[bot]` | CODEOWNERS plus the escalation workflow reading reviews instead of labels. The label is retired. Tracked in [[work-126]]. |

6. **Spend vs local (INVARIANTS §7).** Enabling metered compute (an API key, a paid host,
   a paid tier) **is spend**. Building, previewing or restarting software **on the Owner's
   own machine is not a deploy**.
7. **Substrate: local-first, free-first** (PRINCIPLES 9–10). This is an org decision,
   recorded here because it supersedes the round-2 Max-token plan.

   | Job | Host | Cost |
   |---|---|---|
   | Claude-powered work: build, spec, design review, heal | `org-run` on the Owner's Mac: launchd plus headless Claude Code on their existing login. Missed runs fire on wake. | $0 incremental |
   | Deterministic gates: routine-reviewer, liveness, CI | GitHub Actions, which is free on public repos. The private reviewer repo stays within free minutes. | $0 |
   | Overnight propose-only: request-triage, board-hygiene | claude.ai routines on the Owner's existing plan. Never a write credential. | $0 incremental |
   | Always-on host or API key | **Not now.** It is a spend proposal, made only if metrics show awake-windows are the bottleneck. | Metered |

## What the Owner applies (the gate surface agents cannot write)

The PR stages these files. The Owner copies them into place, following the
[[ledger-050-adr-022-activated]] precedent. Steps are in `docs/owner-apply-autonomy-charter.md`.

| Staged file | Replaces | Change |
|---|---|---|
| `scripts/owner-runbook/INVARIANTS-v2.0.0.md` | `charter/INVARIANTS.md` | Decisions 1–6 |
| `scripts/owner-runbook/escalation-check.v2.sh` | `scripts/escalation-check.sh` | Escalates only the safety kernel. Still carries the gate-script cases the routine-reviewer requires. |
| `scripts/owner-runbook/guard-gates.v2.sh` | `.claude/hooks/guard-gates.sh` | Phase A: blocks agents from applying `owner-approved` |

Agent-writable parts in the same PR:
- [[principles]]
- [[decision-rights]] v2
- `.github/CODEOWNERS`, narrowed
- [[core-upgrade]] scoped to the kernel
- [[staffing]] with standing ratification
- AGENTS.md with the new read order and Owner Model
- the executive charters, each with an autonomy mandate
- the PRD org model

## Consequences

- **The Owner's queue collapses.** It holds the §7 actions at the moment of action,
  credentials and permissions, kernel changes, red-gate waivers, and irreversible
  deadlocks. Everything else goes to a weekly digest with revert links.
- **More autonomy means more trust has to be earned and shown.** This is mitigated by
  evidence bundles, canary PRs, and published revert, false-green and canary-catch rates
  ([[roadmap-002]] workstream 6), plus runaway caps that pause the org and ping the Owner.
- **Standards and loops can now change without the Owner.** Mitigated by requiring CRO
  verification on load-bearing changes. The gate scripts read nothing from loops,
  standards or the registry (verified by grep), and a rename can't move a kernel file out
  of scope (`--no-renames`, which is also applied to `scripts/routine-reviewer.sh` in this
  PR). So an org-governed change can't weaken a gate.
- **Phase A is still single-rail against a deliberate agent.** It is honest about that.
  Phase B is the fix.

## Alternatives considered

| Option | Why rejected |
|---|---|
| Keep §4 as is and batch approvals | It still routes org-owned decisions to the Owner, which is the failure mode itself |
| Drop Owner review for the gate surface too | It lets the org weaken its own rails. INVARIANTS forbids that, and so does the Owner's threat model (injection) |
| Actions + Max `setup-token` substrate (round-2 plan) | The Owner prefers local-first and free-first, and it puts a subscription credential in CI |
| Always-on paid host now | It is spend with no evidence yet that awake-windows are the bottleneck |
