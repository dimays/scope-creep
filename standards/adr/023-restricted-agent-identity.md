---
name: adr-023
description: Design for a restricted agent GitHub identity, distinct from the Owner's, so the ADR-022 escalation marker (owner-approved) becomes un-forgeable — an agent identity that cannot self-approve reviews, add the owner-approved label, or merge escalation-class PRs. PROPOSED — the design is accepted but requires Owner GitHub infra (a separate token/app + branch protection) to activate; until then the marker stays agent-forgeable and merges stay Owner-gated. Closes the residual named in ADR-022, guard-gates.sh, escalation-check.sh, and ledger-048.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-06
---

# ADR-023: Restricted agent identity (make the escalation marker un-forgeable)

- **Status:** **PROPOSED** — design accepted by the CTO; **NOT ACTIVE**. It cannot
  be activated by an agent: it requires Owner GitHub infrastructure (a separate
  restricted token/app and branch protection, [[work-060]]). Until it lands, the
  ADR-022 escalation marker stays agent-forgeable and merges stay Owner-gated
  ([[adr-014]] / [[adr-022]] activation gate).
- **Date:** 2026-09-06
- **Deciders:** **Owner** (must provision the identity/infra), CTO (design).
- **Owner-gated:** **yes** — a safety-rail + core change (ADR-022 trigger (d)); and
  the activation step is literally Owner-only GitHub account/token setup.
- **Relates to:** [[adr-022]] (autonomous-merge escalation model), [[work-059]]
  (this ticket), [[work-060]] (branch protection), [[ledger-048-autonomous-merge-cro-and-decision]].

## Context

ADR-022's escalation rail HOLDS an escalation-class PR until the Owner clears it,
and the Owner clears it by applying a marker — today the `owner-approved` GitHub
label, checked by `.github/workflows/escalation-check.yml` and enforced at merge by
`.claude/hooks/guard-gates.sh`.

The load-bearing hole, named honestly in three places already (the guard-gates
NOTE, the escalation-check.sh header, and [[ledger-048-autonomous-merge-cro-and-decision]]):
**all agents act through the Owner's ONE GitHub identity.** So any agent with `gh`
can `gh pr edit --add-label owner-approved` and clear its own hold. Every marker an
agent could apply is, by construction, one an agent can forge:

- a **label** — `gh pr edit --add-label` (agent can add it);
- a **PR review approval** — `gh pr review --approve` (agent can approve its own);
- a **signed commit / GPG marker** — the shared identity holds the signing key too.

The root cause is identity, not the choice of marker. No marker is un-forgeable
while the agent and the Owner are the same GitHub principal. The mechanical rails
(work-057/058) make escalation *auditable and fail-closed against accidental or
unreviewed merges*, but **not un-spoofable against a deliberate agent.** This ADR
fixes the root cause.

## Decision

**Introduce a restricted agent GitHub identity, distinct from the Owner's, and make
the Owner-approval marker an action only the Owner's principal can perform.**

Two parts, both Owner-provisioned:

### 1. A separate, restricted principal for agents
Agents authenticate all `gh`/git operations with a **restricted credential** — a
dedicated GitHub App installation token or a fine-grained PAT on a **bot/machine
account** — that is scoped so it **cannot**:
- add or remove the `owner-approved` label (no `issues:write` / `pull_requests`
  label-write on the repo, or the label is governed by a rule the token can't
  satisfy — see part 2);
- **approve** pull-request reviews (a review from the PR author's own identity does
  not count toward a required approval; and the restricted identity is **not a
  member of the approving team**);
- **merge** an escalation-class PR (blocked by branch protection + required checks,
  [[work-060]]);
- push to protected branches or edit branch-protection settings.

The **Owner's personal token stays with the human only** and is never handed to an
agent.

### 2. An Owner-only approval mechanism the agent identity provably cannot satisfy
The marker moves from "a label anyone can add" to **an approval only the Owner's
principal can produce.** The strongest, standard GitHub-native options (pick per
repo; they compose):
- **Required review from a team the agent identity is not in** (CODEOWNERS +
  branch protection "require review from Code Owners"). The restricted agent
  cannot approve as a member of that team, and its own author-review never counts.
- **A protected `owner-approval` GitHub Environment** whose deployment/approval
  gate lists the Owner as the sole required reviewer; the escalation-class merge job
  waits on that environment. The agent token cannot approve the environment.

CI then verifies the **identity of the approver**, not merely the presence of a
marker — e.g. the escalation-check confirms the approving review / environment
approval came from the Owner principal, and (once a bot identity exists) that the
`owner-approved` label, if still used, was applied by the Owner and not the bot.

**Net effect:** clearing an escalation hold becomes an act only the human Owner's
principal can perform. The marker is no longer agent-forgeable.

## Feasibility — honest assessment

- **Cannot be delivered by an agent, at all.** Creating a GitHub App / bot account,
  minting a restricted token, wiring branch protection, and configuring environment
  reviewers are **Owner-only account actions** (they touch credentials and account
  settings — [[invariants]] §III, and outside any agent's authority). This ADR is a
  *design + the exact steps*; the Owner executes them. `docs/owner-apply-work-059.md`
  carries the concrete checklist.
- **Depends on [[work-060]]** (branch protection). Without protection on `main`, a
  restricted token that "can't merge escalation PRs" is moot — the rule needs a
  mechanism to enforce it.
- **What CAN ship now (this PR):** the design of record (this ADR), the exact Owner
  scoping checklist, and the two write-side rails of [[work-059]] (block Edit/Write
  to the gate surface; bring permission grants in-band). These reduce the blast
  radius and make the residual precise — they do **not** by themselves make the
  marker un-forgeable.
- **What must NOT ship as a half-measure:** a CI step that "checks who applied the
  label" while everything still runs as the single Owner identity would look like a
  control without being one (an agent-as-Owner passes it). Adding it now would be
  *false assurance* — exactly the failure the CRO guards against — so it is
  deliberately **deferred** until a separate identity exists to check against.

## Consequences

- **The escalation marker becomes un-forgeable** once activated: only the Owner's
  principal can clear a hold, closing the last hole in the ADR-022 activation gate.
- **Operational cost:** agents run under a restricted credential; some `gh` actions
  that "just worked" under the Owner's token will (correctly) be denied and must
  route through the Owner. This is the point.
- **Residual until the Owner provisions it (state this plainly, do not overclaim):**
  the `owner-approved` label remains **agent-forgeable** under the shared identity.
  The work-057/058/059 rails make escalation mechanical, auditable, and fail-closed
  against *accidental/unreviewed* merges; they are **not** un-spoofable against a
  *deliberate* agent until this ADR is activated. ADR-022 does not go active on the
  strength of the marker alone.

## Alternatives considered

- **Keep the label, add commit-signature verification.** Rejected: the shared
  identity holds the signing key, so a signature is as forgeable as the label. Same
  root cause, more machinery.
- **Out-of-band approval in a channel agents can't reach (e.g. the Console / a chat
  the Owner controls) feeding a CI-checked token.** Viable and complementary, but it
  still reduces to "a credential/identity agents don't hold" — i.e. this ADR. Folded
  in rather than treated as a rival.
- **Do nothing; rely on reviewer judgment + the mechanical rails.** Rejected: leaves
  the catastrophic "org merges a change to its own gates" case reachable by a
  deliberate agent, which is precisely what [[ledger-048-autonomous-merge-cro-and-decision]]
  said must be closed before ADR-022 activates.
