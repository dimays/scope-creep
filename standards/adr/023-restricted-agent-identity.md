---
name: adr-023
description: Design for a restricted agent GitHub identity, distinct from the Owner's, so the ADR-022 escalation marker (owner-approved) becomes un-forgeable for escalation-class paths. Phase 1 LIVE (2026-09-21) — the @scope-creep-review machine account is a code owner on both repos, so the bot author cannot self-approve and the control plane is unjammed. Phase 2 LIVE (2026-09-22) — review authority is SPLIT by blast radius: a human-only code owner (@dimays) now owns the escalation set (core / safety rails / gate scripts / .github/CODEOWNERS), which the UNATTENDED @scope-creep-review reviewer PAT is NOT in, while @scope-creep-review stays code owner for routine periphery. So the unattended identity can no longer clear an escalation hold or merge an escalation-class change to the org's own gates — that now requires the human Owner's code-owner review. Landed via the CODEOWNERS split (scope-creep#110, console#75) + the control-plane escalation-check .github/CODEOWNERS case (work-094), proven by the reviewer-identity live-verify gate. Closes the residual named in ADR-022, escalation-check.sh, and ledger-048 for escalation-class paths; periphery auto-review by @scope-creep-review remains by design (ADR-022 routine-merge).
metadata:
  type: reference
  status: active
  version: 1.3.0
  owner_agent: cto
  last_verified: 2026-09-22
---

# ADR-023: Restricted agent identity (make the escalation marker un-forgeable)

- **Status:** **ACTIVE — Phase 1 + Phase 2 both live.** *Phase 1 (landed 2026-09-21):* the
  **`@scope-creep-review` machine account is a code owner** on both repos with the reviewer/merger
  runbook (scope-creep #85/#86, console #65), so the **bot author can no longer self-approve** and
  the control plane is unjammed. *Phase 2 (landed 2026-09-22):* review authority is **split by
  blast radius** — a **human-only** code owner (**`@dimays`**) now owns the **escalation set**
  (core / safety rails / gate scripts / `.github/CODEOWNERS`), which the **unattended**
  `@scope-creep-review` reviewer PAT is **not** in, while `@scope-creep-review` stays code owner for
  routine **periphery**. Landed via the CODEOWNERS split (`dimays/scope-creep#110`,
  `dimays/scope-creep-console#75`) + the control-plane `escalation-check.sh` `.github/CODEOWNERS`
  case ([[work-094]]), and proven by the reviewer-identity live-verify gate (a CODEOWNERS-only PR
  shows escalation-check **RED** without `owner-approved`; `@scope-creep-review` **cannot** approve
  an escalation-set change; `@dimays` **can**). **Net: an unattended identity can no longer clear an
  escalation hold or merge an escalation-class change to the org's own gates — that now requires the
  human Owner's code-owner review.** The [[adr-022]] escalation marker is un-forgeable for
  **escalation-class** paths. *(Honest scope: `@scope-creep-review` still auto-reviews/merges
  **periphery** by design — [[adr-022]] routine-merge, Tier-1 — and the `owner-approved` **label**
  remains technically forgeable via `issues:write`; what makes escalation un-spoofable is the
  **code-owner IDENTITY** gate, which no in-sandbox/unattended principal can present — [[adr-026]]
  Blast-radius.)*
  > **Residual that Phase 2 CLOSED (CRO, verbatim — retained, not deleted):** *"Phase 1 makes the
  > owner-approved marker un-forgeable by the BOT author (Issues: No access) but it REMAINS
  > forgeable by the reviewer/merger identity (@scope-creep-review PAT), which runs UNATTENDED in
  > work-sweep — so one unattended identity can clear an escalation hold and merge escalation-class
  > work (including a change to the org's own gates) with no human. Closed only by Phase 2: a
  > human-only code owner on core/escalation paths the reviewer PAT is not in."* **Now closed** by
  > the Phase-2 split above, for escalation-class paths.
  > See [[ledger-072-work-sweep-unpause-safety-gates]], [[ledger-065-checkpoint-reconciliation]], [[work-094]].
  > **Reframe (Owner decision 2026-09-20) — this is NOT a "later follow-up"; it is the
  > PRECONDITION of write access / next up.** Granting the unattended cloud routine GitHub
  > write access ([[work-088]]) makes the "org merges a change to its own gates" path
  > reachable end-to-end (any credential that can open PRs can add the `owner-approved`
  > label). So the Owner's decision is to **activate this ADR's substance as part of that
  > grant** — a **separate bot identity** shipped *together with* the write access, not after
  > it. The residual below was factually true **until the Owner provisioned** the human-only split;
  > what changed then was priority, not the hole. See `docs/owner-apply-github-write-access.md`
  > (PR #79), `docs/owner-apply-work-sweep-unpause.md`, [[work-088]], [[work-117]]. **Provisioned
  > 2026-09-22 — status is now `active`** (the CODEOWNERS split + [[work-094]] landed). *This
  > reframe is escalation-class ([[adr-022]] trigger (d)) and HOLDS for the Owner marker.*
- **Date:** 2026-09-06 (authored) · 2026-09-20 (reframed to precondition of [[work-088]])
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
- **Residual — now CLOSED for escalation-class paths (state the remainder plainly, do not
  overclaim):** with the Phase-2 human-only split live (2026-09-22), an escalation-class change
  requires an approving **code-owner review from `@dimays`**, which no unattended/in-sandbox
  principal can present — so escalation-class merges are un-spoofable. **What honestly remains:**
  (a) the `owner-approved` **label** is still technically forgeable via `issues:write`, but it is
  no longer sufficient — the code-owner IDENTITY gate is the load-bearing control ([[adr-026]]
  Blast-radius); (b) **periphery** is still auto-reviewed/merged by `@scope-creep-review` by design
  ([[adr-022]] routine-merge / Tier-1). The work-057/058/059 rails remain the mechanical,
  auditable, fail-closed floor beneath the identity gate.

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
