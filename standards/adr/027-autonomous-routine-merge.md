---
name: adr-027
description: How (and whether) to let ROUTINE (non-escalation) PRs merge autonomously from the cloud, now that Gate 0 deliberately removed the @scope-creep-review reviewer credential from the routine's own cloud env (ledger-072) and the sandbox proxy forces the Claude App identity (ledger-066, ADR-026) — so a routine PR authored in-sandbox cannot obtain its own code-owner review and waits for the Owner's off-sandbox 2-click (as observed disposing #119/#120/#121, 2026-09-23). DECISION — do NOT re-introduce a merge-capable reviewer credential into the routine's execution env or into repo Actions secrets (that just undoes Gate 0 / violates ADR-026 gate #3(ii)); instead define a SEPARATED routine-reviewer that lives outside the routine's sandbox, decides from an INDEPENDENT re-run of escalation-check against a trusted checkout (never the PR's own forgeable CI/label signals), and is mechanically confined to periphery — escalation-class PRs stay routed to the human code owner @dimays and never auto-merge. BUILD IT ONLY when routine-PR volume justifies it; until then keep the human 2-click as the deliberate boundary, optionally softened by a Console batch approve+merge. Owner-gated, escalation-class (ADR-022 trigger d); status proposed pending CRO verification + CoS ratification + Owner approval.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-23
---

# ADR-027: Autonomous routine-merge — a separated reviewer, not a credential in the sandbox

- **Status:** **proposed** — Owner-gated, escalation-class; HOLDS for the Owner.
- **Date:** 2026-09-23
- **Deciders:** **CTO** (this proposal) · **[[chief-reality-officer]]** (must verify before accept) · **[[chief-of-staff]]** (ratifies) · **Owner** (approves — it touches the merge posture).
- **Owner-gated:** **yes** — a `standards/` ADR changing the merge/identity posture ([[adr-022]] trigger (d)). Not self-mergeable.
- **Extends:** [[adr-022]] (autonomous-merge-with-escalation) · [[adr-023]] (restricted identity) · [[adr-026]] (cloud routine write path). **Closes no gate on its own** — it defines the design and the trigger to build it.

> **TL;DR:** A routine PR opened in the cloud sandbox **cannot obtain its own `@scope-creep-review` code-owner review** — the proxy forces the Claude App identity ([[ledger-066-cloud-sandbox-proxy-identity-wall]]) and [[ledger-072-work-sweep-unpause-safety-gates]] Gate 0 **deliberately removed** the reviewer PAT from the routine's env — so every routine PR waits for the Owner's off-sandbox 2-click. **The fix is NOT to put a reviewer credential back in the sandbox** (that undoes Gate 0) **or in Actions secrets** (that violates [[adr-026]] gate #3(ii)). It is a **separated routine-reviewer**: a review-only surface *outside* the routine's env that **independently re-derives "routine + safe"** (re-runs `escalation-check` from a trusted checkout, never the PR's forgeable CI/label) and approves+merges **periphery only** — escalation-class PRs still route to the human code owner **`@dimays`** and never auto-merge. **Build it when routine-PR volume warrants; until then the human 2-click is the deliberate boundary.**

---

## Context — why routine PRs still wait on a human

Un-pausing `work-sweep` (2026-09-23) surfaced a real friction, not a bug: even a **routine**,
non-escalation PR (a board-hygiene status correction; a ledger append) **cannot merge itself from
the cloud.** Watched live: #119, #120, #121 all needed the Owner's off-sandbox review+merge.

The mechanism, from the landed architecture:

- **The proxy fixes the author identity.** Every `api.github.com` call from the sandbox acts as
  the shared Claude GitHub App (`dimays`), never `@scope-creep-review` ([[ledger-066-cloud-sandbox-proxy-identity-wall]], [[adr-026]]). The canary re-proved a direct merge is refused **405** ([[ledger-073-work-sweep-first-run-canary]]).
- **Branch protection needs the code-owner *identity*.** `require_code_owner_reviews` + CODEOWNERS
  route **periphery → `@scope-creep-review`**, **escalation set → `@dimays`** (ADR-023 Phase 2, live).
- **Gate 0 removed the reviewer credential from the routine's env — on purpose.** The
  `@scope-creep-review` PAT is **gone** from the `scope-creep-local` cloud env ([[ledger-072-work-sweep-unpause-safety-gates]]): an unattended merge-capable identity sitting in work-sweep's own sandbox was the exact risk it closed.
- **So there is no principal that can supply the routine review from the sandbox.** The harness
  auto-mode classifier also blocks an agent from applying any approval (self-approval). The PR waits.

The forces in tension:

- **We want routine hygiene to run unattended** — that is the point of the cadenced routines
  ([[prd-autonomous-execution-loop]]); a daily 2-click per hygiene PR erodes it.
- **We must not re-open Gate 0 or [[adr-026]] gate #3.** No merge-capable reviewer credential may
  live in the routine's execution env **or** in repo Actions secrets/Environments (both verified empty; a credential there is a **HARD BLOCK**).
- **Escalation must stay human.** [[adr-026]]'s blast-radius analysis is load-bearing: a cloud
  session can **forge CI-green** (rewrite a `pull_request` workflow that `github-actions` then posts green) **and forge the `owner-approved` label** (`issues:write`). The **only** un-forgeable merge signal is the code-owner *identity*. So any auto-approver must **not** trust the PR's own signals, and must **never** act on an escalation-class path.

---

## Decision

**Do not re-introduce a merge-capable credential into the sandbox or Actions. Define a separated
routine-reviewer, confined to periphery by an independent check, and build it only when volume
justifies it.** Five parts:

1. **REJECTED outright — a reviewer credential in the routine's env or in Actions secrets.** Putting
   the `@scope-creep-review` PAT back in `scope-creep-local`, or adding it as a repo Actions
   secret/Environment, **undoes Gate 0 / violates [[adr-026]] gate #3(ii)** and makes the
   "cloud session forges every signal, then the auto-approver merges it" path reachable. **This is a
   HARD BLOCK, not an option.**

2. **The reviewer is a SEPARATED, review-only surface — outside the routine's sandbox.** It holds the
   `@scope-creep-review` credential where the routine cannot reach it: the Owner's own machine (the
   `~/.config/scope-creep/review-pat` that already exists, [[ledger-072-work-sweep-unpause-safety-gates]]) or a dedicated review-only environment the routine has no access to. **`author ≠ reviewer` is enforced by *environment separation*, not just identity** — the routine env and the review env never overlap.

3. **The reviewer decides from an INDEPENDENT re-derivation of "routine + safe," never the PR's own
   signals.** On each candidate PR it: **(a)** re-runs `scripts/escalation-check.sh` from a **trusted
   checkout** (`main`'s copy of the gate script, against `base...head`) — not the PR's CI result;
   **(b)** confirms the diff touches **no** escalation path (which, by ADR-023 Phase 2, includes
   `.github/workflows/**` and `.github/CODEOWNERS` — so a workflow-rewrite forge is itself
   escalation and disqualifies); **(c)** confirms the author is the expected routine identity. Only
   if all hold does it approve as `@scope-creep-review`. **It trusts its own computation, not the
   forgeable green check or label.**

4. **Escalation-class PRs are never auto-anything.** The reviewer is a code owner for **periphery
   only**; for the escalation set CODEOWNERS names **`@dimays`**, whom it cannot impersonate, so an
   escalation PR's required review is simply **never satisfied** by the reviewer and continues to
   **hold for the human** — exactly ADR-023 Phase 2. The reviewer **never** applies the
   `owner-approved` label.

5. **Mechanism for the merge itself: GitHub-native auto-merge, enabled by the routine.** When the
   routine opens a routine PR it enables GitHub **auto-merge** (a Pull-requests-write action it
   already has under [[adr-026]] — **no new credential**). GitHub then merges **only** once branch
   protection is satisfied — i.e. once the separated reviewer's approval lands and checks are green.
   The routine enables; the reviewer approves; **GitHub** merges. No single actor both authors and
   disposes.

> **The one-line mechanism:** *the routine enables auto-merge and proposes; a reviewer in a separate
> env independently re-derives "routine" and approves; GitHub merges — so `author ≠ reviewer` holds
> by environment, and escalation still holds for `@dimays`.*

**Sequencing / trigger to BUILD (not now):** keep the human 2-click as the deliberate boundary
**until** routine-PR volume makes it costly — concretely, when **more than one routine merges
periphery PRs on a sub-weekly cadence** (e.g. board-hygiene **and** work-sweep periphery both live).
Until then, optionally soften the friction with a **Console batch action** ("approve + merge all
green, routine-classified PRs") that still runs as the Owner — human authority, one click for many.

---

## Consequences

- **Autonomy without re-opening Gate 0.** Routine hygiene can merge unattended, but the credential
  that can do it **never lives where a cloud session can reach it**. The property Gate 0 bought — *no
  merge-capable reviewer in the routine's own env* — is preserved verbatim.
- **The auto-approver is safe *because* it distrusts the PR.** Re-running the gate script from a
  trusted checkout (not the PR's CI) is what defeats [[adr-026]]'s forge vectors: a workflow-rewrite
  is escalation-class (so disqualifying), and a forged label is irrelevant (the reviewer doesn't read
  it). **The reviewer's own code + config are escalation-class and locked** (`.claude/**` / gate
  surface) — it cannot be silently repointed.
- **A new trusted component (accepted, bounded).** The separated reviewer is one more thing that must
  be correct and running. **If it is down, routine PRs simply wait** — the system degrades to today's
  2-click, never to an unsafe merge. Its blast radius is **periphery only, bounded and reversible**
  ([[adr-022]] routine-merge); it can never touch the escalation set.
- **Residual, stated plainly.** An auto-approver on periphery means a compromised/prompt-injected
  cloud session could get a **bad but routine** change merged (bounded, reversible — a revert PR).
  That is the *same* risk [[adr-022]] already accepts for routine-merge; ADR-027 does not widen it,
  and keeps escalation strictly human. It does **not** apply to Tier-2 escalation paths at all.
- **Interim cost is real but small.** Until the build trigger fires, the Owner keeps clicking
  review+merge on routine hygiene PRs (as for #119/#120/#121). At today's daily-ish, single-app
  cadence that is cheap; the Console batch action makes it one click for many.
- **Reversible.** Stop the separated reviewer (or revoke its PAT) and everything falls back to the
  human 2-click. Nothing about the routine's own grant changes.

---

## Alternatives considered

| Option | What it is | Why not (vs. the decision) |
|---|---|---|
| **Reviewer PAT back in the routine's cloud env** | Re-add `GH_REVIEW_PAT` to `scope-creep-local` so the routine reviews itself. | **Undoes Gate 0.** An unattended merge-capable identity in the routine's own sandbox — the exact hole [[ledger-072-work-sweep-unpause-safety-gates]] closed. A cloud session that can forge CI+label would then merge unattended. **HARD BLOCK.** |
| **GitHub Actions auto-merge with the PAT as a repo secret** | A workflow approves+merges routine PRs, PAT in Actions secrets. | **Violates [[adr-026]] gate #3(ii)** ("no code-owner-capable credential in Actions secrets/Environments"). A forged workflow could then authenticate as the reviewer. And a `pull_request` workflow runs from the head branch — the PR could rewrite the very job that merges it. **HARD BLOCK.** |
| **Trust the PR's green check + `owner-approved` label** | Auto-merge anything green + labelled. | **Both are forgeable from the cloud** ([[adr-026]] Blast radius). This is exactly the un-trustworthy path; the decision's part 3 exists to avoid it. |
| **Keep the human 2-click forever** | No autonomy; Owner disposes every routine PR. | **Safe, and the right interim** — adopted as the default until the volume trigger. Rejected only as the *permanent* answer, because it caps the cadenced-routine value the org is building toward ([[prd-autonomous-execution-loop]]). |
| **A second human code owner for periphery** | Add another person so `author ≠ approver` without a machine reviewer. | **No second human exists** (single-user org, [[invariants]] §II). Non-starter. |

---

## Un-spoofability (the honest core)

The design is only as good as part 3's independence. It holds **iff**:

- the reviewer re-runs the gate check from a **trusted** `escalation-check.sh` (main's copy), so a PR
  cannot present a doctored classification;
- the escalation set (ADR-023 Phase 2) **already includes `.github/workflows/**` and
  `.github/CODEOWNERS`**, so any forge-enabling diff is itself escalation → routed to `@dimays`,
  never auto-approved;
- the reviewer's own code/config live on the **locked gate surface** (`.claude/**` / `scripts/guard-*`),
  so an agent cannot rewrite what "routine" means or where the reviewer points.

If any of those three is not true, the separated reviewer is **not** safe to run and the build stays
blocked. This ADR **asserts the design and the preconditions, not a running system** — building it is
a follow-up gated on the volume trigger and on CRO sign-off that the three hold.

## Relates to

[[adr-022]] (autonomous-merge escalation — the routine-merge posture this extends) ·
[[adr-023]] (restricted identity — the human-only escalation code owner this preserves) ·
[[adr-026]] (cloud write path — the forge analysis + gate #3 this builds on) ·
[[ledger-066-cloud-sandbox-proxy-identity-wall]] (the proxy identity wall) ·
[[ledger-072-work-sweep-unpause-safety-gates]] (Gate 0 — the credential removal this must not undo) ·
[[ledger-073-work-sweep-first-run-canary]] (the 405 merge-refusal, live) ·
[[board-hygiene]] · [[work-sweep]] · [[ticket-cycle]] · [[prd-autonomous-execution-loop]].
