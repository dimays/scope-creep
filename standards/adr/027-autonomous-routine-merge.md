---
name: adr-027
description: How (and whether) to let ROUTINE (non-escalation) PRs merge autonomously from the cloud, now that Gate 0 deliberately removed the @scope-creep-review reviewer credential from the routine's own cloud env (ledger-072) and the sandbox proxy forces the Claude App identity (ledger-066, ADR-026) — so a routine PR authored in-sandbox cannot obtain its own code-owner review and waits for the Owner's off-sandbox 2-click (as observed disposing #119/#120/#121, 2026-09-23). DECISION — do NOT re-introduce a merge-capable reviewer credential into the routine's execution env or into repo Actions secrets (that just undoes Gate 0 / violates ADR-026 gate #3(ii)); instead define a SEPARATED routine-reviewer that lives outside the routine's sandbox, decides from an INDEPENDENT re-run of escalation-check against a trusted checkout (never the PR's own forgeable CI/label signals), and is mechanically confined to periphery — escalation-class PRs stay routed to the human code owner @dimays and never auto-merge. BUILD IT ONLY when routine-PR volume justifies it; until then keep the human 2-click as the deliberate boundary, optionally softened by a Console batch approve+merge. Owner-gated, escalation-class (ADR-022 trigger d); status proposed — decision loop complete (CTO owns / CRO verified SOUND-WITH-FIXES / CoS ratified with fixes folded), pending Owner approval.
metadata:
  type: reference
  status: accepted
  version: 1.1.1
  owner_agent: cto
  last_verified: 2026-09-24
---

# ADR-027: Autonomous routine-merge — a separated reviewer, not a credential in the sandbox

- **Status:** **accepted** (2026-09-24, via PR #122) — Owner-gated, escalation-class. **Decision loop complete 2026-09-23: CTO owns · CRO verified (SOUND-WITH-FIXES) · CoS ratified (with fixes folded); built 2026-09-24 ([[work-118]]), supervised run + CRO sign-off. See the Amendment below** for the two mechanisms that diverge from the original design (direct-merge; Actions host).
- **Date:** 2026-09-23
- **Deciders:** **CTO** (this proposal) · **[[chief-reality-officer]]** (verified — SOUND-WITH-FIXES) · **[[chief-of-staff]]** (ratified — with the CRO fixes folded) · **Owner** (approves — it touches the merge posture).
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
   `~/.config/scope-creep/review-pat` **attested in** [[ledger-066-cloud-sandbox-proxy-identity-wall]] / [[ledger-072-work-sweep-unpause-safety-gates]] — Owner-attested, not independently verifiable from the sandbox) or a dedicated review-only environment the routine has no access to. **`author ≠ reviewer` is enforced by *environment separation*, not just identity** — the routine env and the review env never overlap.

3. **The reviewer decides from an INDEPENDENT re-derivation of "routine + safe," never the PR's own
   signals.** On each candidate PR it: **(a)** re-runs `scripts/escalation-check.sh` from a **trusted
   checkout** (`main`'s copy of the gate script, against `base...head`) — not the PR's CI result;
   **(b)** confirms the diff touches **no** escalation path — consulting **both** the re-run **and
   `.github/CODEOWNERS`**, because the two rails currently disagree (see the un-spoofability note
   below): `is_escalation()` catches `.github/workflows/**` + `.github/CODEOWNERS` (so a
   workflow-rewrite forge disqualifies) but has **no `scripts/` case**, while CODEOWNERS routes the
   gate scripts to `@dimays`; **(c)** confirms the author is the expected routine identity. Only
   if all hold does it approve as `@scope-creep-review`. **It trusts its own computation, not the
   forgeable green check or label.**

4. **Escalation-class PRs are never auto-anything.** The reviewer is a code owner for **periphery
   only**; for the escalation set CODEOWNERS names **`@dimays`**, whom it cannot impersonate, so an
   escalation PR's required review is simply **never satisfied** by the reviewer and continues to
   **hold for the human** — exactly ADR-023 Phase 2. The reviewer **never** applies the
   `owner-approved` label.

5. **Mechanism for the merge itself: GitHub-native auto-merge, enabled by the routine.** When the
   routine opens a routine PR it enables GitHub **auto-merge** — *expected* to be within its existing
   Pull-requests-write grant ([[adr-026]]) with **no new credential**, but **not yet proven**: the
   [[ledger-073-work-sweep-first-run-canary]] canary never exercised `enablePullRequestAutoMerge`
   from the sandbox, and auto-merge also needs the repo setting **`allow_auto_merge = true`**
   (unverified). **A build-gated canary must confirm both** before part 5 is relied on (build
   precondition below). GitHub then merges **only** once branch protection is satisfied — i.e. once
   the separated reviewer's approval lands and checks are green. The routine enables; the reviewer
   approves; **GitHub** merges. No single actor both authors and disposes.

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
- **Named residuals (folded from CRO):** three the design lives with, none a safety hole given the
  reviewer distrusts the PR: **(a)** the `escalation-check.sh` ↔ CODEOWNERS **asymmetry on the gate
  scripts** (build precondition #1 closes it); **(b)** the **CI-adjacent surface that is not
  `.github/workflows/**`** — composite actions (`.github/actions/**`), non-`guard-*` scripts a
  workflow invokes — is periphery in *both* classifiers, so a green check can be induced without
  touching a locked path; this stays inside [[adr-022]]'s accepted "bad-but-routine, reversible"
  residual **only because** the reviewer ignores CI-green and re-derives from the diff; **(c)** gate
  #3(ii) ("no code-owner credential in Actions secrets/Environments") is **point-in-time** — so the
  separated reviewer must **re-verify #3(ii) as a per-run precondition**, not trust the build-time check.
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
- the gate surface the reviewer relies on is **locked by CODEOWNERS→`@dimays`** (`.claude/**`,
  `scripts/escalation-check*.sh`, `scripts/guard-*.sh`, `.github/workflows/**`, `.github/CODEOWNERS`),
  so an agent cannot rewrite what "routine" means or where the reviewer points.

> **Correction folded from CRO/CoS (2026-09-23) — the load-bearing lock on the gate scripts is
> CODEOWNERS, NOT the escalation re-run.** `escalation-check.sh` `is_escalation()` has **no
> `scripts/` case**, so a PR touching `scripts/guard-*.sh` or `scripts/escalation-check*.sh`
> classifies **ROUTINE** on the re-run — the thing that actually holds it for `@dimays` is the
> CODEOWNERS routing (lines 33–34), which `@scope-creep-review`'s approval cannot satisfy. The
> safety property **holds** (branch protection still requires the `@dimays` review), but the
> re-run is *incomplete* defense-in-depth there, not the lock.

**Build preconditions (all required before the separated reviewer is built — CoS-ratified):**
1. **Align the two rails** — add `scripts/escalation-check*.sh` + `scripts/guard-*.sh` cases to
   `is_escalation()` so the trusted re-run is *real* defense-in-depth (and survives a CODEOWNERS
   regression). `escalation-check.sh` is **guard-write-blocked** → this is an **Owner-applied**
   gate-file patch (the [[work-094]] pattern), its own escalation-class change.
2. **Canary the auto-merge trigger** (part 5) — prove `enablePullRequestAutoMerge` succeeds from the
   sandbox as the proxy identity **and** that `allow_auto_merge = true` on both repos.
3. **CRO re-signs** that the three `iff` preconditions above hold at build time.

If any precondition is unmet, the separated reviewer is **not** safe to run and the build stays
blocked. This ADR **asserts the design and the preconditions, not a running system** — building it is
gated on the volume trigger **and** the three preconditions.

## Decision-loop determinations (2026-09-23)

Run via the [[decision]] loop — **CTO owns · CRO verifies · CoS ratifies** (the [[ledger-072-work-sweep-unpause-safety-gates]] pattern). Full record: [[ledger-077-adr-027-decision-loop]].

- **CTO (owns):** authored this proposal (the separated-reviewer design; defer-the-build; keep the 2-click interim).
- **CRO (verifies) — SOUND-WITH-FIXES.** Re-checked every load-bearing claim against live source: the friction is **real** (#119/#120/#121 merged off-sandbox by the Owner, not the routine — GitHub API confirmed), the un-spoofability core is **intact** (`is_escalation()` L67/L68 catch workflows + CODEOWNERS), no fabrications. Required 4 precision fixes (the rails asymmetry; the untested auto-merge capability; the `review-pat` attestation wording; three named residuals) — **all folded above.**
- **CoS (ratifies) — RATIFIED with the CRO fixes folded.** INVARIANTS upheld (§7/§10 author≠merger by environment separation; §II single-user — a machine reviewer is identity separation, not roles/auth; §I.4 the build is a core-upgrade). Defer-the-build and the 2-click interim both endorsed; the Console batch approve+merge approved as an interim softener (runs *as the Owner*). Added routing: **align the two rails** as a build precondition (Owner-applied gate-file patch, work-094 pattern).
- **Owner (approves):** pending — escalation-class, HOLDS. Disposal per below.

## Amendment — build authorized and completed (2026-09-24)

The original decision **deferred the build** behind a volume trigger and kept the human 2-click
interim. The Owner **overrode that deferral** and directed the build now, precisely to remove the
per-PR friction it describes. The separated reviewer was built ([[work-118]]), ran a **supervised
first run** (approved + squash-merged one routine PR as `@scope-creep-review` — author `dimays` →
`author ≠ merger` confirmed live; held one escalation PR for `@dimays`), and the CRO **re-signed**
it (SIGN-OFF-WITH-CONDITIONS; conditions cleared). This section reconciles the ADR text with the
system that shipped. Two mechanisms diverge from the design above — both **narrow** risk, and both
are recorded here rather than left silent.

**Divergence (i) — Part 5 revised: DIRECT approve-then-merge, not GitHub-native auto-merge.** The
reviewer, running as `@scope-creep-review`, **approves and then merges** (`gh pr merge --squash`)
once it has independently classified the PR routine and confirmed required checks green + mergeable.
This **drops** the unproven dependency Part 5 flagged (`enablePullRequestAutoMerge` from the sandbox
+ repo `allow_auto_merge = true`) — build precondition #2 is therefore **moot**, not met.
`author ≠ merger` still holds by environment separation: the **author** is the `dimays` proxy, the
**merger** is `@scope-creep-review` in a separate env — no single actor both authors *and* disposes.
GitHub still refuses the merge unless branch protection is fully satisfied, so approving cannot force
an unsafe merge.

**Divergence (ii) — the reviewer's home is a scheduled GitHub Action in a SEPARATE Owner-owned repo.**
Part 2 permits "a dedicated review-only environment the routine has no access to." The realized host
is a private `scope-creep-reviewer` repo the Owner owns, running the reviewer hourly with the
`@scope-creep-review` PAT as **that repo's** Actions secret. **This is NOT the "PAT in Actions
secrets" option the Alternatives table HARD-BLOCKS** — that block concerns **scope-creep's own**
Actions (gate #3(ii)), where a forged in-repo workflow could authenticate as the reviewer.
scope-creep's Actions/Environments stay empty (gate #3(ii) is still re-checked per run and still
passes); the credential lives in a **different trust domain** the proposing routine cannot reach.
Stated plainly: the threat gate #3(ii) guards — a workflow that can act as the reviewer — is
**relocated** into the reviewer repo, so **that repo's access control is now load-bearing**
(Owner-sole-admin, single workflow, protected branch, no `pull_request` trigger, fine-grained
least-privilege PAT). The reviewer repo's README carries the lockdown conditions the CRO/CTO
required before go-live.

**Build-precondition status:** #1 (align the two rails) **DONE** — the gate-script + `charter/*` +
reviewer-self cases landed in `is_escalation()` (PR #128), and the reviewer now also consults
`.github/CODEOWNERS` as a second rail (holds if either flags a path). #2 (auto-merge canary) **MOOT**
— superseded by direct-merge (divergence i). #3 (CRO re-signs the `iff` preconditions) **DONE** — the
supervised-run sign-off. The host itself is gated on the reviewer-repo lockdown + liveness conditions
in that repo's README.

**Disposition:** with this reconciliation the Owner **accepts** ADR-027 and the shipped system (this PR).

## Operational status — reviewer host live (first run 2026-09-24 UTC)

> **Divergence (ii)'s host is BUILT and LIVE.** The private, Owner-owned `dimays/scope-creep-reviewer`
> repo now runs the reviewer on an **hourly schedule**; its **first scheduled run was GREEN on
> 2026-09-24 UTC** — a clean no-op (`reviewer: scope-creep-review` · `no open PRs targeting main`).
> Full go-live record: [[ledger-078-routine-reviewer-action-host-live]].

**As-built facts (recorded so the ADR text and the running system agree):**

| Aspect | As built |
|---|---|
| **Host** | `.github/workflows/routine-reviewer.yml` — hourly `schedule` + `workflow_dispatch`; `permissions: {}`; environment `ci`; `actions/checkout` SHA-pinned to v4.2.2 (`11bd719`); runs `bash scripts/routine-reviewer.sh --unattended` (checked out from `dimays/scope-creep@main`) as `@scope-creep-review`. Shipped via reviewer-repo **PR #1** (+ full README). |
| **Credential** | a **classic `repo`-scoped** `REVIEW_PAT` for `@scope-creep-review`, stored **only** as the reviewer repo's `ci` environment secret — *corrects* Divergence (ii)'s "fine-grained least-privilege PAT" wording (the as-built token is classic-scoped). |
| **Reliability** | reviewer-repo **PR #2** — `heartbeat.yml` (weekly `.heartbeat` commit; defeats GitHub's 60-day scheduled-workflow auto-disable; `GITHUB_TOKEN` `contents:write`) + `liveness.yml` (every 2h; emails the Owner if no successful `routine-reviewer` run in 4h; `GITHUB_TOKEN` `actions:read`). Both dispatched green. |

> **Correction to Divergence (ii)'s lockdown list — branch protection is NOT available; the posture
> is discipline-only.** On GitHub's **free plan a PRIVATE repo cannot be branch-protected** — both
> classic branch protection *and* rulesets return **403 "Upgrade to GitHub Pro or make this
> repository public."** So the **"protected branch"** condition listed under Divergence (ii) is
> **unattainable as-built.** The **Owner accepted a discipline-only posture (2026-09-23)** in its
> place: **Owner sole admin · the Claude GitHub App the only other actor · no agent ever merges into
> the reviewer repo.** It is documented in the reviewer repo's `README.md` (the authoritative source
> for the host's lockdown + reliability conditions). **The safety property ADR-027 depends on is
> unchanged** — `dimays/scope-creep`'s own Actions/Environments stay empty ([[adr-026]] gate #3(ii)
> still holds), `author ≠ merger` still holds by environment separation, the reviewer stays bounded
> to periphery by the two-rail re-derivation, and escalation still holds for `@dimays`. The
> discipline-only posture governs only the **reviewer repo's own** change-control, into which the
> threat gate #3(ii) guards (a workflow that can act as the reviewer) is **relocated**.

## Relates to

[[adr-022]] (autonomous-merge escalation — the routine-merge posture this extends) ·
[[adr-023]] (restricted identity — the human-only escalation code owner this preserves) ·
[[adr-026]] (cloud write path — the forge analysis + gate #3 this builds on) ·
[[ledger-066-cloud-sandbox-proxy-identity-wall]] (the proxy identity wall) ·
[[ledger-072-work-sweep-unpause-safety-gates]] (Gate 0 — the credential removal this must not undo) ·
[[ledger-073-work-sweep-first-run-canary]] (the 405 merge-refusal, live) ·
[[ledger-077-adr-027-decision-loop]] (the decision-loop record) ·
[[ledger-078-routine-reviewer-action-host-live]] (the reviewer host go-live) ·
[[board-hygiene]] · [[work-sweep]] · [[ticket-cycle]] · [[prd-autonomous-execution-loop]].
