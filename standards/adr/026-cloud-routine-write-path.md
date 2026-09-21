---
name: adr-026
description: The cloud work-sweep routine's GitHub write path, redesigned around the sandbox proxy identity wall (ledger-066). The claude.ai cloud egress proxy overrides the outbound Authorization header on api.github.com and re-authenticates every request as the SHARED Claude GitHub App identity (resolves to dimays, read-only) — so no custom identity (scope-creep-routine[bot] or @scope-creep-review PAT) can present itself in-sandbox. DECISION — propose-only via granting that shared Claude GitHub App scoped write (Contents + Pull-requests) on scope-creep + scope-creep-console; the routine opens PRs AS that forced identity; review + merge stay OFF the sandbox as @scope-creep-review, where identities resolve and the code-owner gate holds. This REVERSES owner-apply-github-write-access.md §1d (keep the Claude App read-only) and makes the dedicated scope-creep-routine[bot] App moot for the CLOUD write path. Merge containment holds because merging requires being @scope-creep-review, which the proxy can never present — the manifest is Anthropic-fixed and the ACTUAL grant is broad (workflows/actions/checks/issues write, Administration ABSENT), so the un-pause gate is a two-part compensating-controls check on repo state (verified 2026-09-21): Administration absent AND no code-owner credential in Actions secrets/environments (both empty), which makes the present writes signal-only and non-merging. Because the grant is broad (workflows+issues write), a cloud session can FORGE both non-identity merge signals (CI-green via a workflow rewrite that github-actions posts under the pinned app_id; the owner-approved label) — so the code-owner IDENTITY gate is the sole trustworthy merge control and ADR-026 does NOT close the ADR-023 Phase-2 residual (an unattended @scope-creep-review PAT satisfies the code-owner review identically). Hence a TWO-TIER un-pause: Tier 1 (board-hygiene + non-escalation periphery) is safe after the supervised canary; Tier 2 (work-sweep on any escalation/core/gate-reachable path) requires closing ADR-023 Phase-2 first (a CODEOWNERS split putting the escalation set behind a human-only code owner + an escalation-check.sh CODEOWNERS case). Owner-gated, escalation-class (ADR-022 trigger d). Supersedes the frozen write contract in docs/runbook-work-sweep-cloud-routine.md §2-§4.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-21
---

# ADR-026: Cloud routine write path — propose-only via the sandbox proxy identity

- **Status:** **PROPOSED — Owner-gated, HOLDS for the Owner marker.**
- **Date:** 2026-09-21
- **Deciders:** **CTO** (this decision); **Owner** (must grant the App install + scopes; ratifies); **[[chief-reality-officer]]** (independent cross-check from the pushed branch).
- **Owner-gated:** **yes — escalation-class ([[adr-022]] trigger (d): a core `standards/` ADR + a change to the write/identity safety posture).** Not self-mergeable.
- **Supersedes:** the **frozen write contract** in `docs/runbook-work-sweep-cloud-routine.md` §2–§4 (the "author-as-`scope-creep-routine[bot]` over REST" contract). **Reverses** `docs/owner-apply-github-write-access.md` **§1d** (keep the Claude GitHub App read-only). **Refines** [[adr-025]]'s cloud authoring assumption (git-push/`landProposal` → REST as the proxy identity).

> **TL;DR:** The cloud sandbox proxy **forces every `api.github.com` call to act as the shared Claude GitHub App** ([[ledger-066-cloud-sandbox-proxy-identity-wall]]). So the only reachable write path is **propose-only**: grant *that* identity **Contents:write + Pull-requests:write** on both repos, let the routine **open PRs as it**, and keep **review + merge off the sandbox** (local/human as `@scope-creep-review`). **Merge stays impossible from the cloud not by token scoping but by identity: the sole code owner `@scope-creep-review` is a principal the proxy can never present.** This **reverses** owner-apply §1d and makes the `scope-creep-routine[bot]` App **moot for the cloud path**. The decisive test is **gated on the Owner grant** and is defined below as a machine-checkable un-pausing criterion — **not asserted as proven.**

---

## Context — the proxy identity wall (why the old contract is dead)

The definitive diagnostic ([[ledger-066-cloud-sandbox-proxy-identity-wall]], 2026-09-21) proved: the claude.ai cloud sandbox's egress proxy **strips/overrides the outbound `Authorization` header** on `api.github.com` and **re-authenticates every request as its own GitHub App identity**, which resolves to `dimays` and is **read-only**. A valid PAT, a garbage token, and no token all returned the same `dimays` login at HTTP 200 (`rate_limit.core.limit = 15000`, a GitHub-App installation ceiling).

- **The forced identity is the shared Claude GitHub App** — the principal behind *every* interactive claude.ai session and the sandbox's git-push proxy (`owner-apply-github-write-access.md` §1d identifies it). It is not something we provision; the sandbox picks it.
- **No custom identity survives the proxy.** Neither the `@scope-creep-review` reviewer PAT nor a minted `scope-creep-routine[bot]` installation token can present itself in-sandbox — both are overwritten. **The proxy does not *block* the request; it *re-authenticates* it.**
- **Corollary that reframes everything:** a write call **succeeds iff the proxy identity (the Claude App) has write.** The bearer token the routine sends is decorative. The JWT → derive-install-id → mint-token dance in the old runbook §4a is **inert under the proxy** — the minted token is discarded before it reaches GitHub.
- **`author ≠ merger` cannot exist *within one sandbox session*** — every call is the same proxy identity. But it **can** exist *across the propose/dispose boundary* if the merge happens **outside** the sandbox, where identities resolve.

The competing forces:

- **We need a working cloud write path at all** — today there is none (`git push` 403s; REST-as-bot is overridden). The routine is **paused** until this lands.
- **We must not weaken "propose, never dispose"** — [[invariants]] §7/§10, [[adr-022]], [[adr-023]]. The merge gate must stay mechanical and server-side.
- **We must keep the mutator small** — not stand up a new execution surface or a patch-transport pipeline if a scoped grant suffices.

---

## Decision — propose-only, merge off-sandbox

**Grant the shared Claude GitHub App the minimum write to *propose*, and move *all* disposition off the sandbox to where identities resolve.** Five parts:

1. **The cloud routine authors over REST as the forced proxy identity (the Claude App).** It creates the branch ref, commits (git-data blobs/tree/commit or `PUT /contents`), and `POST /pulls` — carrying whatever token, since the proxy overrides it anyway. **No in-sandbox token minting; the auth is the sandbox's to supply.**

2. **The Owner grants the shared Claude GitHub App write, scoped to `dimays/scope-creep` + `dimays/scope-creep-console` only.** This is the identity the proxy forces, so it is the only identity that *can* be the cloud author. **The grant is a fixed manifest the Owner consents to and *verifies* — not a per-install dial we can trim.** The **actual grant (Owner-reported 2026-09-21, both repos, all Read+Write):** `actions`, `checks`, `code` (Contents), `discussions`, `issues`, `pull-requests`, `repository-hooks`, `workflows` — **`Administration` ABSENT.** The one permission that must be absent (**Administration / branch-protection write**) *is* absent; the broader writes that *are* present (workflows/actions/checks/issues/hooks) are **accepted, compensated residuals** (gate #3 + Consequences), not blockers — none of them can produce the `@scope-creep-review` code-owner review that is the merge gate.

3. **Review + merge stay entirely off the sandbox, as `@scope-creep-review`.** There, identities resolve normally (no proxy), the sole code owner `@scope-creep-review` approves, and `git-manager` merges under the LIVE branch protection (owner-apply Part 0). **The routine's job ends at an open PR.** *(Note: "off-sandbox" secures the cloud→local **author** boundary; it does not by itself make the **merger** human — the unattended `@scope-creep-review` PAT satisfies the code-owner review identically. See the ADR-023 Phase-2 residual in Consequences.)*

4. **The merge boundary is enforced by *identity*, held by two verified compensating controls.** Merging `main` requires an approving **code-owner** review from `@scope-creep-review` (+ last-push-approval + green checks), and **the proxy can never present `@scope-creep-review`.** The grant *does* carry broad signal-write (workflows/actions/checks/issues) — but that only lets an actor tamper with **signals**, never produce the code-owner review, **provided both of these hold (verified 2026-09-21):**
   - **(i) `Administration` / branch-protection write is ABSENT** — so the required-checks list, the `require_code_owner_reviews` rule, and the `@scope-creep-review` code-owner cannot be rewritten. *(Verified: Administration absent from the grant.)*
   - **(ii) No code-owner-capable credential is stored in these repos' Actions secrets or Environments** — so a malicious/forged workflow has **nothing to authenticate as `@scope-creep-review` with.** *(Verified: `gh secret list` empty on both repos; `environments.total_count = 0` on both.)*
   Given (i)+(ii), a cloud session **can forge CI-green (via a workflow rewrite) and the `owner-approved` label — but not the code-owner review.** So the **code-owner identity is the sole trustworthy merge gate**; disabling a check fails CLOSED, but the honest point is that the *other* signals are forgeable and only the identity holds. This is the load-bearing safety property, a **verified precondition** (gate #3) — **with the composition caveat in the Tiered-un-pause section: it holds against a cloud session alone, but an auto-approving unattended code owner (ADR-023 Phase-2, open) would let the cloud session's pre-staged forgeries compose into a merge.**

5. **`scope-creep-routine[bot]` is retained but moot for the cloud path.** Its token is overwritten in-sandbox, so it can never be the cloud author. It stays provisioned for any **non-sandbox** write path (a local runner, a future GitHub Action) where a distinct least-privilege author is still the right principal. **Do not decommission it; do not rely on it in-sandbox.**

> **The one-line mechanism:** *the proxy forces the author identity; branch protection fixes the merger identity; the two are different principals, so `author ≠ merger` holds across the cloud→local boundary — which is exactly "propose, never dispose."*

---

## Consequences

- **This REVERSES owner-apply §1d (stated plainly).** §1d recommends keeping the Claude GitHub App **read-only** — "do not grant it write to fix the push 403." ADR-026 grants it scoped write. **Why the reversal is safe now:** §1d's fear was the pre-hardening hole *"one shared identity authors **and could merge**."* Post-[[adr-023]] Phase 1 (LIVE: sole code owner `@scope-creep-review`, `require_code_owner_reviews`, `require_last_push_approval` on both repos — owner-apply Part 0), **write ≠ merge for any principal that is not `@scope-creep-review`.** §1d was correct under its baseline; the baseline changed. The 403 is no longer "routed around" — it is the wall, and granting the only reachable identity scoped *propose* rights is the way through it.

- **`scope-creep-routine[bot]` is moot for the CLOUD write path (said honestly).** The dedicated bot App was designed to be the in-sandbox author with a minted installation token. The proxy overwrites that token, so the bot **can never present itself in-sandbox.** It remains valid and useful for any local/non-sandbox author path; it is simply not the cloud author. The old runbook's three-principal REST contract (§3) collapses to **one cloud author (Claude App) + one off-sandbox merger (`@scope-creep-review`).**

- **Blast radius — grant it eyes open; the grant is broad, and CI-green + the label are FORGEABLE.** The Claude App is the identity behind **every interactive claude.ai session**, not just work-sweep, and the actual grant is **broad** (workflows/actions/checks/issues/hooks write, not just Contents+PR). A deliberate/prompt-injected cloud session can therefore **forge both of ADR-022's non-identity signals:** (1) it can **rewrite a check workflow on the PR branch**, which `github-actions` (the pinned `app_id 15368`) then posts **green** — satisfying the pinned required check (`pull_request` workflows run from the **head** branch, so a PR *can* alter the check that gates it); and (2) `issues:write` lets it **forge the `owner-approved` label.** **What it still cannot forge is the `@scope-creep-review` code-owner review** — it is not that principal (`can_approve=false`), and no credential for it is stored in Actions (secrets empty, environments 0 — verified). **So the sole trustworthy merge gate is the code-owner IDENTITY; the CI-green and label signals beneath it are not trustworthy against a cloud session.** Worst case *from the cloud alone* is spurious non-merging PRs. The **composition risk** (auto-approving reviewer) is the Tiered-un-pause section below. *(A direct `checks:write` forge under the Claude App's own `app_id` does NOT satisfy the pinned check — only the `github-actions`-posted result does, which is why the vector is workflow-rewrite, not check-post.)*
  - **Gloss on `Contents: write`:** it lets any interactive session **push commits to an in-flight PR branch** — but `require_last_push_approval` (the pusher can't be the approver) + `dismiss_stale_reviews` (a new push voids a prior approval) keep that **non-merging**. Pushing to a branch never advances it toward merge on its own.

- **Caveat — the Claude App's manifest is Anthropic's, not ours to trim; so the gate is a *state-of-the-repo* check, not a scope dial (§1d's real point, preserved).** The Owner **cannot hand-pick** "Contents + Pull-requests only" — the app requests a fixed manifest and the Owner consents to it. Since fine-grained scope restriction is **impossible**, un-pausing criterion #3 is **not** "block if workflows/actions present" (they are, unavoidably). It is a **two-part compensating-controls gate on the actual repo state**, both verified 2026-09-21:
  - **(i) `Administration` / branch-protection write ABSENT** — required, and **verified absent**. If a future re-grant added it, propose-only would be unsafe (the identity could rewrite the code-owner rule) → HARD BLOCK.
  - **(ii) No code-owner-capable credential in Actions secrets / Environments** — **verified** (`gh secret list` empty on both repos; `environments.total_count = 0` on both). A forged workflow has nothing to authenticate as `@scope-creep-review` with. If a secret/environment holding such a credential were later added → HARD BLOCK until removed or the code-owner rule is otherwise made unforgeable.
  - **Given (i)+(ii), `workflows`/`actions`/`checks`/`issues`/`hooks` write are ACCEPTED, explicitly-recorded residuals.** Worst case is **signal tampering** — a forged check or a pre-applied `owner-approved` label defeats a *signal*, not the code-owner merge gate; a disabled required check **fails CLOSED**. The `issues`/label case is the [[adr-023]] Phase-2 marker-integrity concern, recorded, non-merging.

- **Security posture (current, not stale).** The ledger-066 private-key leak is **RESOLVED** — the Owner rotated the `scope-creep-routine` App key on 2026-09-21; treat the leaked copy as dead. This ADR raises **no** new secret: the Claude App's auth is the sandbox's, minted by the platform, never stored by us. The `GH_APP_*` / `GH_REVIEW_PAT` secrets become **unused by the cloud path** (the bot is moot in-sandbox; the reviewer merges locally) — leave them for the non-sandbox path; they are not on the cloud wire.

- **Simplification — the mutator shrinks.** The cloud path drops the entire in-sandbox JWT/installation-token machinery (inert under the proxy) and the `git push` attempt (403). The routine authors over REST with platform-supplied auth. **Fewer moving parts, one author identity, one merger identity.**

- **The write-back path is untouched.** The routine's DB write-back (`DATABASE_URL`/`DATABASE_AUTH_TOKEN`, [[adr-024]]) does **not** hit `api.github.com`, so the proxy never rewrites it. Honest-degradation on the GitHub side (403 → `needs-you` blocker) is independent of the Turso connection, as before.

- **ADR-026 does NOT close the [[adr-023]] Phase-2 residual — and under this broad grant that residual is SHARPER (CRO, stated plainly).** Propose-only secures the **cloud author** boundary; it says nothing about the **off-sandbox merger**. The code-owner requirement is satisfied **identically** by the **unattended `@scope-creep-review` PAT** as by a human — GitHub cannot tell them apart. The sharpening: because a cloud session can **pre-stage every non-identity precondition** (forge CI-green via a workflow rewrite; forge the `owner-approved` label — see Blast radius), the **only** thing standing between an unattended run and a merged **escalation-class change to the gates themselves** is that the code owner is not auto-approving. The instant an unattended `@scope-creep-review` auto-approves, a cloud session could merge a gate change with no human. So the Phase-2 hole is not merely open — it is the **sole** remaining defense for escalation-class paths.
  - **Concrete close (make it an actionable Owner gate, not a deferral):** a **CODEOWNERS split** so the **escalation set** — `charter/INVARIANTS.md`, `.claude/**`, `standards/**`, `agents/**`, `loops/**`, `registry/**`, `.github/workflows/**`, the gate scripts, non-append `ledger/**`, **and `.github/CODEOWNERS` itself** — requires review from a code owner the unattended work-sweep reviewer **is not** (i.e. **`@dimays`** or a human-only team), while `@scope-creep-review` stays code owner for **routine periphery**. **Companion fix** (already flagged in owner-apply Part 0): add a `.github/CODEOWNERS` case to `scripts/escalation-check.sh` `is_escalation()` — today a CODEOWNERS rewrite classifies **ROUTINE**. Both are Owner-provisioned (ADR-023 substance) and touch locked gate surfaces.

- **Reversible.** Uninstall the Claude App from the two repos (or drop write) and the cloud routine falls back to read-only — it degrades to a `needs-you` blocker, never a silent action. The bot App and `@scope-creep-review` are unaffected.

---

## Un-pausing criteria (machine-checkable — the routine stays paused until ALL hold)

> **Gated on the Owner grant. The decisive test is NOT reachable locally** — a local session authenticates normally and does not reproduce the sandbox proxy; reproducing it requires a claude.ai cloud routine, which needs the write grant first. **Nothing below is asserted as proven.** These are the falsifiable un-pausing gates; a supervised cloud run walks them and captures the evidence.

| # | Criterion | Verify (in-sandbox unless noted) | Evidence to capture |
|---|---|---|---|
| 1 | **Grant is live** — Owner granted the Claude App `Contents`+`Pull requests` write on both repos | `POST /repos/{owner}/{repo}/git/refs` (throwaway no-op branch) → **201** | branch ref URL; the `.login` the call acted as |
| 2 | **`POST /pulls` succeeds as the proxy identity** | `POST /repos/{owner}/{repo}/pulls` on that branch → **201** | PR URL; PR `user.login` == proxy identity (Claude App / `dimays`), **not** `@scope-creep-review` |
| 3 | **Compensating-controls gate — repo state, not scope (2026-09-21)** | Fine-grained scope restriction is impossible (fixed manifest), so the gate is: **(i) `Administration`/branch-protection write ABSENT** *(Owner GitHub-UI manifest read — CLI can't verify without the App JWT; Owner to **double-confirm** Administration/branch-protection is not listed)* **AND (ii) no code-owner-capable credential in Actions secrets or Environments** *(verified via CLI: `gh secret list` empty both repos; `environments.total_count = 0` both)*. Given (i)+(ii), `workflows`/`actions`/`checks`/`issues` write are **accepted, signal-only residuals** (forgeable but non-merging — the code-owner identity is the sole trustworthy gate). **HARD-BLOCK** only if (i) or (ii) is ever violated. | recorded: Administration absent (Owner UI-read); secrets empty + environments 0 both repos (CLI-verified); branch protection + CODEOWNERS (`@scope-creep-review`, `can_approve=false` App) live |
| 4 | **Merge is server-side BLOCKED** | `PUT /repos/{owner}/{repo}/pulls/{n}/merge` from the sandbox → **405/409** (required code-owner review not satisfied) | the blocked response; the `.login` that attempted (proxy identity, **not** `@scope-creep-review`) |
| 5 | **Local merge path intact** *(local, not sandbox)* | `@scope-creep-review` approves as code owner + green checks + last-push-approval → merge succeeds | the approving review's author == `@scope-creep-review`; merge SHA |
| 6 | **Honest degradation holds** | A 403/permission denial on ref-create or PR-open leaves the ticket `ready` and writes a `needs-you` card naming the cause — **never silent, never marked done** | the `needs-you` card; ticket still `ready` |

**Only when 1–6 are captured** does a routine un-pause (a **separate** control-plane PR, per owner-apply Part 4). Criteria 1, 2, 4 are the empirical proof that **propose works and dispose is blocked from the cloud**; **5 proves the merge path *works* (a code-owner approval merges) — NOT that a human performed it**; **3 is the compensating-controls gate** (Administration absent + no code-owner credential in Actions — both verified 2026-09-21); 6 preserves fail-closed. **Criteria 1/2/4/6 are executed by the `board-hygiene` supervised-canary run** (`docs/owner-apply-board-hygiene-routine.md`).

## Tiered un-pause (which routines, on which paths, safely)

> **The grant is SAFE TO KEEP. This tiering is only about what a routine may touch UNATTENDED** — because for a cloud session every merge signal *except* the code-owner identity is forgeable (Blast radius), and the code-owner identity's human-ness is the open ADR-023 Phase-2 residual.

| Tier | Scope | Un-pause condition |
|---|---|---|
| **Tier 1 — safe now** | **`board-hygiene`** (edits only `work/*.md` `status`; opens a **non-escalation** `board-state-correction` PR; lowest blast radius) **and other non-escalation routine periphery** | The **supervised canary** (criteria 1/2/4/6) passes. **No ADR-023 Phase-2 required** — an auto-approving reviewer on *periphery* is bounded and reversible ([[adr-022]] routine-merge). |
| **Tier 2 — gated** | **`work-sweep`** for **any path that can reach escalation-class / core / gate-touching changes** | **Requires ADR-023 Phase-2 closed first.** For these paths every signal but the code-owner approval is forgeable, so an auto-approving unattended code owner would let a cloud session merge a **gate change** unattended. Not un-paused for such paths until the CODEOWNERS split (§ residual) + the `escalation-check.sh` CODEOWNERS case land. |

**Sequencing:** merge this PR → run the `board-hygiene` canary → un-pause **Tier 1** → close ADR-023 Phase-2 → only then un-pause **Tier 2** (`work-sweep` on escalation-reachable paths).

---

## Alternatives considered

| Option | What it is | Why not (vs. the decision) |
|---|---|---|
| **2. Alternate execution surface** | Run the write step where the proxy doesn't rewrite auth — a GitHub Action / self-hosted runner the routine triggers; claude.ai for intake + reasoning only. | **Heavier, and chicken-and-egg.** Dispatching a workflow is itself an `api.github.com` write → overridden to the read-only Claude App, so it needs a write grant *anyway* (or a self-scheduled Action, which then doesn't need the claude.ai routine and re-introduces a runner + Actions/self-hosted spend to operate). Defeats the "no local session / claude.ai-native routine" goal and grows the mutator. **Viable fallback only if §2's grant proves unacceptable.** |
| **3. Async-through-the-app** | Routine writes only a proposal into the shared DB queue; the Console/local side opens the PR and merges. | **Relocates the write, doesn't remove it — and adds machinery.** The routine's branch/commits still need write to reach GitHub; with a read-only Claude App the routine cannot get its diff out at all, so this requires **serializing the full patch into the queue + a Console-side apply/push worker**, losing the routine-as-author artifact. Option 1 already parks the *merge* off-sandbox (its safety property) with **zero new transport** — Option 3's only delta is *where the branch/PR is created*, bought with a patch-transport build. Its merge-stays-human posture is a **subset of Option 1**, so #1 subsumes it. |
| **(rejected earlier) Keep the Claude App read-only, author as the bot over REST** | The current frozen runbook contract. | **Physically cannot work** — proven by ledger-066: the proxy overwrites the bot token, so the bot never authenticates in-sandbox. This is the dead contract this ADR supersedes. |

---

## Testability boundary (do not overclaim)

- **Cannot be verified from a local session.** Locally there is no egress proxy; a local `POST /pulls` authenticates as the real caller and does **not** reproduce the identity override. So the decisive empirical claim — *"a write-enabled proxy identity opens a PR **and** branch protection holds it against merge"* — is **only** testable from inside a claude.ai cloud routine, which needs the Owner grant **first**.
- **Therefore this ADR asserts a *reasoned* decision and a *defined* test, not a passing test.** The reasoning against the LIVE branch-protection config (owner-apply Part 0) is legible and falsifiable; the un-pausing criteria are the machine-checkable un-pausing gate. **If criterion #2 fails (PR does not open) or #4 fails (the PR *can* be merged from the sandbox), this decision is falsified** and Option 2 becomes the fallback.
- **`git push` under the grant is an open secondary unknown, not relied upon.** Once the Claude App has `Contents: write`, the git-push proxy *may* also start succeeding — but the REST path is the header-independent primary, and git-push behavior is out of scope for the un-pausing gate.

---

## Relates to

[[ledger-066-cloud-sandbox-proxy-identity-wall]] (root cause) · [[work-096]] (this spike) · [[adr-022]] (autonomous-merge escalation — why merge stays gated) · [[adr-023]] (restricted identity — the reviewer/label residual this ADR touches) · [[adr-025]] (runner topology — its cloud authoring assumption is refined here) · [[adr-024]] (the shared store the write-back uses) · `docs/runbook-work-sweep-cloud-routine.md` (corrected per this ADR) · `docs/owner-apply-github-write-access.md` §1d (reversed here) · [[prd-autonomous-execution-loop]].
