---
name: adr-026
description: The cloud work-sweep routine's GitHub write path, redesigned around the sandbox proxy identity wall (ledger-066). The claude.ai cloud egress proxy overrides the outbound Authorization header on api.github.com and re-authenticates every request as the SHARED Claude GitHub App identity (resolves to dimays, read-only) — so no custom identity (scope-creep-routine[bot] or @scope-creep-review PAT) can present itself in-sandbox. DECISION — propose-only via granting that shared Claude GitHub App scoped write (Contents + Pull-requests) on scope-creep + scope-creep-console; the routine opens PRs AS that forced identity; review + merge stay OFF the sandbox as @scope-creep-review, where identities resolve and the code-owner gate holds. This REVERSES owner-apply-github-write-access.md §1d (keep the Claude App read-only) and makes the dedicated scope-creep-routine[bot] App moot for the CLOUD write path. Merge containment holds because merging requires being @scope-creep-review, which the proxy can never present — CONDITIONAL on the Claude App manifest lacking Administration/Workflows/Actions write (a fact we do not control, so it is a HARD un-pause gate, not an assumption). ADR-026 narrows the unattended-write surface but does NOT close the ADR-023 Phase-2 residual (an unattended @scope-creep-review PAT satisfies the code-owner review identically). Owner-gated, escalation-class (ADR-022 trigger d). Supersedes the frozen write contract in docs/runbook-work-sweep-cloud-routine.md §2-§4.
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

2. **The Owner grants the shared Claude GitHub App write, scoped to `dimays/scope-creep` + `dimays/scope-creep-console` only.** This is the identity the proxy forces, so it is the only identity that *can* be the cloud author. It needs **`Contents: write` + `Pull requests: write`** present; it must **not** hold **`Administration` / `Workflows` / `Actions`** write (which would let it rewrite the gate — un-pausing gate #3). **Crucially, this is a fixed manifest the Owner consents to and *verifies*, not a per-install dial we can trim** (Consequences — caveat). `Issues: write` (labels), if present, is an accepted recorded residual, not a blocker.

3. **Review + merge stay entirely off the sandbox, as `@scope-creep-review`.** There, identities resolve normally (no proxy), the sole code owner `@scope-creep-review` approves, and `git-manager` merges under the LIVE branch protection (owner-apply Part 0). **The routine's job ends at an open PR.** *(Note: "off-sandbox" secures the cloud→local **author** boundary; it does not by itself make the **merger** human — the unattended `@scope-creep-review` PAT satisfies the code-owner review identically. See the ADR-023 Phase-2 residual in Consequences.)*

4. **The merge boundary is enforced by *identity*, not token scoping — *conditional on the App not being able to rewrite the gate itself.*** Merging `main` requires an approving **code-owner** review from `@scope-creep-review` + last-push-approval + green checks, and **the proxy can never present `@scope-creep-review`** — so a cloud session cannot merge *for any scope up to and including `Contents`/`Pull requests`/`Issues` write.* **The one thing that would break this is the App holding `Administration` write (it could rewrite branch protection to drop the code-owner rule) or `Workflows`/`Actions` write (it could alter the required checks).** That is **a fact we do not control** — the Claude App's permission manifest is Anthropic's — **so it is a *verified precondition*, not an assumption** (un-pausing gate #3). Given that precondition holds, this is the load-bearing safety property.

5. **`scope-creep-routine[bot]` is retained but moot for the cloud path.** Its token is overwritten in-sandbox, so it can never be the cloud author. It stays provisioned for any **non-sandbox** write path (a local runner, a future GitHub Action) where a distinct least-privilege author is still the right principal. **Do not decommission it; do not rely on it in-sandbox.**

> **The one-line mechanism:** *the proxy forces the author identity; branch protection fixes the merger identity; the two are different principals, so `author ≠ merger` holds across the cloud→local boundary — which is exactly "propose, never dispose."*

---

## Consequences

- **This REVERSES owner-apply §1d (stated plainly).** §1d recommends keeping the Claude GitHub App **read-only** — "do not grant it write to fix the push 403." ADR-026 grants it scoped write. **Why the reversal is safe now:** §1d's fear was the pre-hardening hole *"one shared identity authors **and could merge**."* Post-[[adr-023]] Phase 1 (LIVE: sole code owner `@scope-creep-review`, `require_code_owner_reviews`, `require_last_push_approval` on both repos — owner-apply Part 0), **write ≠ merge for any principal that is not `@scope-creep-review`.** §1d was correct under its baseline; the baseline changed. The 403 is no longer "routed around" — it is the wall, and granting the only reachable identity scoped *propose* rights is the way through it.

- **`scope-creep-routine[bot]` is moot for the CLOUD write path (said honestly).** The dedicated bot App was designed to be the in-sandbox author with a minted installation token. The proxy overwrites that token, so the bot **can never present itself in-sandbox.** It remains valid and useful for any local/non-sandbox author path; it is simply not the cloud author. The old runbook's three-principal REST contract (§3) collapses to **one cloud author (Claude App) + one off-sandbox merger (`@scope-creep-review`).**

- **Blast radius — grant it eyes open, and the safety is CONDITIONAL.** The Claude App is the identity behind **every interactive claude.ai session**, not just work-sweep. Granting it write means **any interactive session (or a prompt-injected one) can push a branch or open a PR** on the two repos. **Propose-only is safe *only if* the App's manifest lacks `Administration` and `Workflows`/`Actions` write** — which we **do not control and must verify** (gate #3), not assert. *Given that precondition:* it **cannot** merge (not the code owner), approve as code owner (`@scope-creep-review` only), or rewrite the gate. Worst case is **spurious, non-merging, reviewable PRs — noise, not a gate breach.** For a single-user, fully-trusted-Owner system this is an acceptable trade.
  - **Gloss on `Contents: write`:** it lets any interactive session **push commits to an in-flight PR branch** — but `require_last_push_approval` (the pusher can't be the approver) + `dismiss_stale_reviews` (a new push voids a prior approval) keep that **non-merging**. Pushing to a branch never advances it toward merge on its own.

- **Caveat — the Claude App's permission set is Anthropic's to define, not ours to trim (§1d's real point, preserved).** Unlike our own `scope-creep-routine` App, the Owner **cannot hand-pick** "Contents + Pull-requests only" for the Claude App — the app requests a fixed permission manifest and the Owner consents to it for the selected repos. **So §2's scope is a request, not a guarantee, and the merge-block guarantee is CONDITIONAL on that manifest.** The Owner **must record the full granted permissions and gate on them** (un-pausing criterion #3):
  - **`Administration` / `Workflows` / `Actions` write → HARD BLOCK.** Any of these lets the identity **rewrite branch protection or the required checks** and dismantle the code-owner gate itself. If the manifest carries them, propose-only is **not** safe and the routine does not un-pause.
  - **`Issues: write` → accepted, recorded residual (not a blocker).** An interactive/routine session could **pre-apply the `owner-approved` label**, degrading that marker's integrity (an [[adr-023]] Phase-2 concern) — **but it still cannot merge**, because the code-owner review it cannot produce is an independent required gate. The label-forge risk touches *signal trust*, never *merge capability*.

- **Security posture (current, not stale).** The ledger-066 private-key leak is **RESOLVED** — the Owner rotated the `scope-creep-routine` App key on 2026-09-21; treat the leaked copy as dead. This ADR raises **no** new secret: the Claude App's auth is the sandbox's, minted by the platform, never stored by us. The `GH_APP_*` / `GH_REVIEW_PAT` secrets become **unused by the cloud path** (the bot is moot in-sandbox; the reviewer merges locally) — leave them for the non-sandbox path; they are not on the cloud wire.

- **Simplification — the mutator shrinks.** The cloud path drops the entire in-sandbox JWT/installation-token machinery (inert under the proxy) and the `git push` attempt (403). The routine authors over REST with platform-supplied auth. **Fewer moving parts, one author identity, one merger identity.**

- **The write-back path is untouched.** The routine's DB write-back (`DATABASE_URL`/`DATABASE_AUTH_TOKEN`, [[adr-024]]) does **not** hit `api.github.com`, so the proxy never rewrites it. Honest-degradation on the GitHub side (403 → `needs-you` blocker) is independent of the Turso connection, as before.

- **ADR-026 does NOT close the [[adr-023]] Phase-2 residual (stated plainly).** Propose-only secures the **cloud author** boundary: the sandbox identity cannot merge. It says **nothing** about who drives the **off-sandbox merger**. The code-owner requirement is satisfied **identically** by the **unattended `@scope-creep-review` PAT** (which runs unattended elsewhere in the loop) as by a human — GitHub cannot tell them apart. So the Phase-2 hole — *an unattended reviewer identity can clear an escalation hold and merge escalation-class work with no human* — **stays open** and is **not** closed here. Its close is still [[adr-023]] Phase 2: a **human-only** code owner on core/escalation paths the reviewer PAT is not in, + CI that checks the **approver's identity**, not a label's presence. **This ADR narrows the unattended-write surface (the cloud author is now non-merging); it does not eliminate the unattended-merger risk.**

- **Reversible.** Uninstall the Claude App from the two repos (or drop write) and the cloud routine falls back to read-only — it degrades to a `needs-you` blocker, never a silent action. The bot App and `@scope-creep-review` are unaffected.

---

## Un-pausing criteria (machine-checkable — the routine stays paused until ALL hold)

> **Gated on the Owner grant. The decisive test is NOT reachable locally** — a local session authenticates normally and does not reproduce the sandbox proxy; reproducing it requires a claude.ai cloud routine, which needs the write grant first. **Nothing below is asserted as proven.** These are the falsifiable un-pausing gates; a supervised cloud run walks them and captures the evidence.

| # | Criterion | Verify (in-sandbox unless noted) | Evidence to capture |
|---|---|---|---|
| 1 | **Grant is live** — Owner granted the Claude App `Contents`+`Pull requests` write on both repos | `POST /repos/{owner}/{repo}/git/refs` (throwaway no-op branch) → **201** | branch ref URL; the `.login` the call acted as |
| 2 | **`POST /pulls` succeeds as the proxy identity** | `POST /repos/{owner}/{repo}/pulls` on that branch → **201** | PR URL; PR `user.login` == proxy identity (Claude App / `dimays`), **not** `@scope-creep-review` |
| 3 | **Permission surface recorded AND gated (HARD BLOCK)** | Owner records the **full** granted permissions on **both** repos (installation settings). **HARD-BLOCK un-pause if `Administration` OR `Workflows` OR `Actions` write is present** — any of those lets the identity rewrite the gate and voids the merge guarantee. `Issues: write` is an **accepted, recorded residual** (ADR-023 Phase-2 marker concern), **not** a blocker. | full permission list per repo; explicit **PASS/FAIL** on Administration/Workflows/Actions; whether `Issues: write` is present |
| 4 | **Merge is server-side BLOCKED** | `PUT /repos/{owner}/{repo}/pulls/{n}/merge` from the sandbox → **405/409** (required code-owner review not satisfied) | the blocked response; the `.login` that attempted (proxy identity, **not** `@scope-creep-review`) |
| 5 | **Local merge path intact** *(local, not sandbox)* | `@scope-creep-review` approves as code owner + green checks + last-push-approval → merge succeeds | the approving review's author == `@scope-creep-review`; merge SHA |
| 6 | **Honest degradation holds** | A 403/permission denial on ref-create or PR-open leaves the ticket `ready` and writes a `needs-you` card naming the cause — **never silent, never marked done** | the `needs-you` card; ticket still `ready` |

**Only when 1–6 are captured** does the work-sweep routine un-pause in `registry/routines.json` (a **separate** control-plane PR, per owner-apply Part 4). Criteria 1, 2, 4 together are the empirical proof that **propose works and dispose is blocked from the cloud**; **5 proves the merge path *works* (a code-owner approval merges) — NOT that a human performed it**; **3 is a HARD gate** (Administration/Workflows/Actions write ⇒ no un-pause); 6 preserves fail-closed.

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
