# Owner-manual steps — grant GitHub write access & activate the Autonomous Execution Loop ([[prd-autonomous-execution-loop]])

> **⛔ WRITE-PATH SUPERSEDED by [[adr-026]] (2026-09-21) — follow Part 1′, not the bot path.**
> The cloud write path is now **PROPOSE-ONLY**: grant the **shared Claude GitHub App** scoped
> `Contents` + `Pull requests` **write** on both repos — it is the sandbox proxy's **forced
> identity**, so it is the only identity that can author in-sandbox. The separate
> `scope-creep-routine[bot]` is **moot for the cloud path** (its token is overwritten by the
> proxy). **§1d's "keep the Claude App read-only" is REVERSED.** The bot-path steps (Part 1a–1f)
> are kept as **historical** (supersede-not-destroy, [[doc-standards]] §5) — do **not** follow
> them for the cloud path. **Start at [Part 1′](#part-1-adr-026-propose-only-grant-the-current-path).**

> **✅ RESOLUTION (was: ⛔ ACTIVATION BLOCKED by the sandbox proxy).** The block this checklist hit —
> the bot-author / reviewer-merger identity model **cannot run in the cloud sandbox** (its egress
> proxy overrides the `Authorization` header and forces its own read-only GitHub App identity for all
> `api.github.com` traffic, [[ledger-066-cloud-sandbox-proxy-identity-wall]]) — is now **resolved by
> [[adr-026]]**, which redesigns the write path to **propose-only** (Part 1′). The reviewer-identity
> build (CODEOWNERS + branch protection, [[adr-023]]) is **done, correct, and still governs
> local/human merges** — and is exactly what makes propose-only safe (a code-owner review the proxy
> identity can't present). The reviewer credential was **never** the problem — see
> [[ledger-066-cloud-sandbox-proxy-identity-wall]]. **Security incident RESOLVED:** the Owner rotated
> the leaked `scope-creep-routine` App private key on 2026-09-21 — do **not** treat rotation as an
> open action.

> **What this file is.** PR #78 merged the capstone as plan of record (the PRD, the
> [[work-sweep]] loop manifest, `work-086`…`089`). Your merge was the greenlight — it
> dispositioned [[roadmap-001]] Theme 3 as extended by the PRD, clearing prerequisite (b)
> (loop creation is Owner-gated, [[adr-021]]). One hard prerequisite remains: **GitHub write
> access for the cloud routine** ([[work-088]]) — read-only today, so an unattended push
> `403`s and no PR can open.
>
> This checklist was drafted by the **C-suite convened 2026-09-20** — Chief of Staff
> (sequencing), CTO (credential mechanism), Chief Reality Officer (independent safety pass).
> **The CRO pass found the naïve "just grant a token" path unsafe under the live config.**
> The steps below are ordered so you never grant an unattended agent a path it shouldn't have.

---

## ⚠️ Read first — why this is not a one-step token grant (CRO finding)

The two facts below were the CRO's **original** finding on the **pre-hardening** baseline.
They **motivated** this checklist — and have **since been closed** by [[adr-023]] Phase 1 +
branch protection. **Part 0 carries the current live state; read these as history, not today.**

1. **[Pre-hardening] `main` required `0` approving reviews and there was no CODEOWNERS file**
   on either repo, so for a single write-capable identity **write access = merge access**.
   **[Now: 1 required review + code-owner review by `@scope-creep-review` + last-push-approval
   on both repos — Part 0.]**
2. **[Pre-hardening] `scope-creep-console` had no escalation rail** (only the `App Contract
   test gate`). **[Now: it also requires the `Path-based auto-escalation (ADR-022 trigger d)`
   check and carries `* @scope-creep-review` CODEOWNERS — Part 0.]**

The residual that **remains** after hardening (the [[adr-023]] **Phase-2** gap): the
escalation marker is still forgeable by any **label-capable** write identity — now
specifically the **unattended reviewer PAT** (`@scope-creep-review`, classic `repo` scope,
which includes label write). The bot author **cannot** (Issues: No access). So the end-to-end
self-merge path is **narrowed to the reviewer identity, not eliminated**:

> escalation-class PR → **reviewer PAT** adds `owner-approved` → check GREEN → reviewer
> approves (sole code owner) → merge → **merged, no human.**

This is precisely the "the org autonomously merges a change to its own gates" case
([[ledger-048-autonomous-merge-cro-and-decision]], [[adr-022]] activation gate). **So the write grant must ship together with
the mechanical backstop that closes it** — the substance of [[adr-023]]. The order below does
that.

---

## Part 0 — the live baseline (queried 2026-09-21)

> **Rewritten against the LIVE GitHub state.** The pre-hardening baseline this section used to
> describe (0 required reviews, no CODEOWNERS, console with no escalation rail) is **no longer
> true** — [[adr-023]] Phase 1 + branch protection have landed. What is **actually set now**,
> on both repos:

| Setting | `dimays/scope-creep` | `dimays/scope-creep-console` |
|---|---|---|
| `.github/CODEOWNERS` | `* @scope-creep-review` | `* @scope-creep-review` |
| Required approving reviews | **1** | **1** |
| Require code-owner review | **true** | **true** |
| Require last-push approval | **true** | **true** |
| Dismiss stale reviews | **true** | **true** |
| Enforce for admins | **true** | **true** |
| Required status checks | Path-based auto-escalation (ADR-022 trigger d); Registry sync + work-item schema | **App Contract test gate; Path-based auto-escalation (ADR-022 trigger d)** |

So **author≠merger is mechanically enforced now**: the sole code owner is `@scope-creep-review`
(not the Owner, not the bot), last-push-approval blocks the pusher from self-approving, and the
**console now carries its own escalation rail — §1c is DONE.** Re-confirm before acting:

```bash
gh api repos/dimays/scope-creep/branches/main/protection
gh api repos/dimays/scope-creep-console/branches/main/protection
gh api repos/dimays/scope-creep/contents/.github/CODEOWNERS         -H "Accept: application/vnd.github.raw"
gh api repos/dimays/scope-creep-console/contents/.github/CODEOWNERS -H "Accept: application/vnd.github.raw"
```

Still confirm the routine's **write path** separately (it is the open item, not the gates):
the cloud routine still **`403`s on `git push`** through the read-only Claude App, so the fix
is REST authoring (Part 2 / `docs/runbook-work-sweep-cloud-routine.md` §4), and that chain is
**expected-but-unverified** end-to-end (only run-1 JWT app-auth succeeded).

> **Known Phase-2 gap — do NOT paper over it.** The control-plane `scripts/escalation-check.sh`
> `is_escalation()` (inspected 2026-09-21) has **no `.github/CODEOWNERS` case** — its
> escalation set is `charter/INVARIANTS.md`, `.claude/*`, `standards/*`, `agents/*`, `loops/*`,
> `registry/*`, `.github/workflows/*`, infra/lock manifests, and non-append `ledger/*`. So a PR
> that **rewrites `.github/CODEOWNERS` itself is classified ROUTINE**, and the sole code owner
> `@scope-creep-review` could approve a change to the gate's own ownership as routine work —
> **unattended, via the reviewer PAT.** The fix is to add a `.github/CODEOWNERS` case to
> `is_escalation()` (and mirror it in the console's copy), but that script is a **locked gate
> surface an agent may not edit** ([[adr-023]] Phase 2 / `docs/owner-apply-reviewer-identity.md`
> Phase 4). It is **flagged here, not fixed here.**

---

## Part 1′: ADR-026 propose-only grant (the current path)

> **This is the write path to follow now ([[adr-026]]).** It replaces the bot-author path in
> Part 1a–1f (kept below as historical). The Owner does **one** thing: grant the **shared Claude
> GitHub App** scoped write on the two repos. Everything else (the merge gate) is **already live**
> — Part 0.

**Why this and not the bot:** the cloud sandbox proxy re-authenticates every `api.github.com`
call as the **shared Claude GitHub App** ([[ledger-066-cloud-sandbox-proxy-identity-wall]]), so a
custom bot token **never resolves in-sandbox**. The Claude App is the only identity that *can*
author from the cloud — so grant **it** the minimum to *propose*, and let the merge stay
off-sandbox as `@scope-creep-review` (Part 0), a code owner the proxy can never present.

### Owner steps (the only manual action)

- [ ] **Install / configure the Claude GitHub App on both repos.** GitHub → the Claude GitHub App
  installation → **Only select repositories** → tick **`scope-creep`** and **`scope-creep-console`**
  (not the design/extension repos).
- [ ] **Grant it write:** **Repository permissions → Contents: Read and write** and **Pull requests:
  Read and write**. Leave **Administration / Workflows / Actions / Environments / Secrets** at
  **No access**. (Issues/label write is the residual below — see the caveat.)
- [ ] **Record the ACTUAL granted permissions** the App holds on both repos (installation settings /
  `gh api repos/dimays/scope-creep/installation`). This is un-pause criterion #3 — see the caveat.

> **⚠️ Residual — the Claude App's permission set is Anthropic's manifest, not ours to trim.**
> Unlike our own `scope-creep-routine` App, you **cannot** hand-pick "Contents + Pull-requests only";
> you consent to whatever the Claude App requests. **So the scope above is a request, not a
> guarantee — verify it.** **IF the Claude App carries `Issues`/label write,** a cloud/interactive
> session could **pre-apply the `owner-approved` label**, degrading that marker's integrity — the
> live **[[adr-023]] Phase-2 marker-integrity concern**. It still **cannot merge** (the code-owner
> review it cannot produce is an independent required gate), but the un-pause criteria **must
> capture** whether `Issues:write` is present. See [[adr-026]] Consequences + un-pausing criteria.

### What this closes (and doesn't)

- **Merge stays impossible from the cloud** — the proxy identity is **not** the sole code owner
  `@scope-creep-review`, and `require_code_owner_reviews` + `require_last_push_approval` (Part 0)
  hold server-side regardless of the App's scopes. **Author (cloud) ≠ merger (off-sandbox).**
- **Blast radius:** every interactive claude.ai session gains push/open-PR on the two repos — but
  **cannot merge, approve as code owner, or edit protection/workflows.** Worst case is spurious,
  non-merging, reviewable PRs. Accepted for a single-user, fully-trusted-Owner system.
- **Reversible:** uninstall the Claude App (or drop its write) → the routine falls back to
  read-only, degrading to `needs-you`, never a silent action.

### Un-pause the routine only after (ADR-026 / runbook §4a)

`POST /git/refs` → 201 · `POST /pulls` → 201 **as the proxy identity** · permission surface recorded
· `PUT /merge` from the sandbox → **405/409 blocked** · local `@scope-creep-review` merge intact ·
403 → `needs-you` blocker (never silent). **Only then** flip `registry/routines.json` (a separate
PR). The decisive test is **gated on this grant and not reachable locally** — do not assert it
proven.

---

## Part 1 (HISTORICAL — superseded for the cloud path by [[adr-026]] / Part 1′) — close the merge gate BEFORE granting write (the safety preconditions)

> **⛔ Superseded for the CLOUD write path (supersede-not-destroy, [[doc-standards]] §5).** Part 1a–1f
> below build the **`scope-creep-routine[bot]` author** identity, which the sandbox proxy overwrites —
> so it is **moot for the cloud path** ([[adr-026]]). Kept as the historical record and because the
> bot App remains valid for any future **non-sandbox** author path (a local runner / GitHub Action).
> **The branch-protection substance (1b) is LIVE and still governs local/human merges — see Part 0.**
> For the current path, use **Part 1′** above.

These make "propose but not dispose" a **mechanical** property instead of a hope. All are
Owner-side (repo settings + a new identity). Do them **before** Part 2.

### 1a. Provision the write credential as a *separate* identity — a **GitHub App** [Owner]

**DECIDED (Owner, 2026-09-20): a dedicated bot identity, not a fine-grained PAT under
`dimays`. CTO pick: a GitHub App installation** (over a dedicated machine account).

*Why an App:* it is a principal that **structurally cannot be a code owner or approve as one**,
and it mints **~1-hour installation tokens from a stored private key** — so a leaked `GH_TOKEN`
dies within the hour, and there is no second GitHub *account* (email, 2FA, recovery, ToS) to
secure forever. A machine account gives the "outside the approving set" property only by
convention and leaves a long-lived PAT on the wire; the App gives it by construction. (The PAT
bridge the CTO first floated for speed was rejected: a PAT under `dimays` is the same principal
as every interactive session, so a required review couldn't tell them apart, and any credential
that can open PRs can also self-label — so only a *separate* principal + a required review the
bot can't satisfy actually closes the forge+merge path.)

**A. Create the App** — GitHub → avatar → **Settings → Developer settings → GitHub Apps →
New GitHub App**:
- **Name:** `scope-creep-routine` (→ the `scope-creep-routine[bot]` principal; if taken,
  `scope-creep-routine-dimays`).
- **Homepage URL:** `https://github.com/dimays/scope-creep` (any valid URL; required field).
- **Webhook:** untick **Active** (the routine acts; it doesn't receive events).
- **Repository permissions** — set only these; leave **everything else "No access"**:
  - **Contents: Read and write** (push the branch)
  - **Pull requests: Read and write** (`gh pr create`)
  - **Metadata: Read-only** (auto)
  - Explicitly leave **Administration / Workflows / Actions / Environments / Secrets** at
    **No access** — so the bot cannot edit branch protection or `.github/workflows/**`.
- **Where can this be installed?** "Only on this account." → **Create GitHub App.**

**B. Mint the standing secret** — on the App page, note the **App ID**, then **Generate a
private key** (downloads a `.pem`).

**C. Install it, scoped to two repos** — **Install App** → on `dimays` → **Only select
repositories** → tick **`scope-creep`** and **`scope-creep-console`** (the two [[adr-025]]
checks out — *not* the design/extension repos) → **Install**. The installation id is **not a
stored secret** — the runner **derives it per repo at runtime** (see E). You do not need to
copy the `<INSTALLATION_ID>` from the URL.

> **Correction (first-run finding, [[work-093]]).** The first run stored the App's
> **client_id** in a `GH_APP_INSTALLATION_ID` env var; the client_id is a valid **JWT
> issuer** but the **wrong value** for the installation-token endpoint, so the mint failed.
> The fix is to **derive** the installation id at runtime, not hardcode it — so this env var
> is **removed**, not corrected.

**D. Land two secrets in the `scope-creep-local` cloud env** (same place as `DATABASE_URL` /
`DATABASE_AUTH_TOKEN`) — **no `GH_APP_INSTALLATION_ID`:**
- `GH_APP_ID` = the App ID
- `GH_APP_PRIVATE_KEY_B64` = the `.pem` **base64-encoded to a single line** — a `.env`-format
  value can't hold the PEM's real line breaks, so encode it first (macOS):
  ```bash
  openssl base64 -A -in ~/Downloads/scope-creep-routine.private-key.pem | pbcopy
  ```
  Store the resulting single line (no surrounding quotes). The runner decodes it back to a real
  PEM at startup. (Base64 avoids the `\n`-escaping fragility of pasting a raw PEM into a
  key=value block.)

**E. Token minting + authoring (runner impl — [[work-086]]/[[work-088]]/[[work-093]], not an
Owner step; stated so the wiring is complete):** at run start the routine mints a JWT from the
**two** secrets, **derives the installation id per repo**, mints a ~1 h installation token, and
authors **over the REST API** as `scope-creep-routine[bot]` — it does **not** `git push` (see
the callout below):
```
// JWT from the private key (node:crypto RS256, or @octokit/auth-app), iss = App ID:
const privateKey = Buffer.from(process.env.GH_APP_PRIVATE_KEY_B64, "base64").toString("utf8");
// DERIVE the installation id at runtime — never a stored GH_APP_INSTALLATION_ID:
//   GET /repos/{owner}/{repo}/installation  ->  .id
// then mint the installation token:
//   POST /app/installations/{id}/access_tokens  ->  .token
// then author OVER REST with that token (Authorization: Bearer <token>):
//   POST /repos/{o}/{r}/git/refs (branch) -> git-data blobs/tree/commit -> PATCH ref
//   POST /repos/{o}/{r}/pulls (open the PR)
```

> **`git push` does NOT work in the cloud sandbox (first-run finding, [[work-093]]).** The
> sandbox proxies `git push` through the **read-only Claude GitHub App** and returns **403**,
> regardless of any local `gh auth setup-git`. `api.github.com` REST **is** reachable with the
> bot's own bearer token — so the routine **authors entirely over REST** (refs / contents /
> pulls). The step-by-step sequence is in `docs/runbook-work-sweep-cloud-routine.md` §4.

**F. Expiry / rotation posture:**
- **Installation tokens auto-expire (~1h)** — minted fresh each run, never stored. A leaked
  `GH_TOKEN` is dead within the hour.
- **The private key has no expiry** — the only standing secret. Rotate annually as hygiene, or
  immediately on suspicion (generate a new key, re-encode + replace `GH_APP_PRIVATE_KEY_B64`,
  delete the old).
- **Instant revoke:** uninstall the App or drop a repo from the installation — no token to hunt.
- Nothing (key or token) ever lands in the repo, a committed `.env`, the ledger, or an Artifact
  ([[tech-sops]] §6).

### 1b. Require a review the bot cannot give — CODEOWNERS + branch protection [Owner]

**Order matters: land CODEOWNERS *before* flipping `require_code_owner_reviews`,** or the very
PR that adds it can't merge.

- [ ] Add `.github/CODEOWNERS` to **each** repo, identical. `scope-creep-routine[bot]` is a
  GitHub App, so it **cannot** be a code owner or approve as one — it can only propose.
  (`.github/CODEOWNERS` is *not* an escalation-class path — only `.github/workflows/*` is — so
  it lands as a normal PR.)
  ```
  # Every change requires review from the Owner (code owner). The cloud routine acts as
  # scope-creep-routine[bot] (a GitHub App), which cannot be a code owner or approve — it
  # proposes; the Owner disposes.
  * @dimays
  ```
- [ ] Then set branch protection on `scope-creep`:
  ```bash
  gh api --method PUT repos/dimays/scope-creep/branches/main/protection --input - <<'JSON'
  {"required_status_checks":{"strict":true,"contexts":["Path-based auto-escalation (ADR-022 trigger d)","Registry sync + work-item schema"]},"enforce_admins":true,"required_pull_request_reviews":{"required_approving_review_count":1,"require_code_owner_reviews":true,"dismiss_stale_reviews":true,"require_last_push_approval":true},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}
  JSON
  ```
- [ ] And on `scope-creep-console` (keeps its single check for now — see 1c):
  ```bash
  gh api --method PUT repos/dimays/scope-creep-console/branches/main/protection --input - <<'JSON'
  {"required_status_checks":{"strict":true,"contexts":["App Contract test gate"]},"enforce_admins":true,"required_pull_request_reviews":{"required_approving_review_count":1,"require_code_owner_reviews":true,"dismiss_stale_reviews":true,"require_last_push_approval":true},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}
  JSON
  ```

`require_last_push_approval: true` is the precise mechanical author≠merger rail — the last
pusher (the bot) can't be the approver, so a different principal must approve;
`dismiss_stale_reviews: true` voids an approval if the bot pushes more commits after it.

### 1c. Give the console repo its own escalation rail (fast-follow, then require it) [Agent + Owner]

- [ ] **Port** `escalation-check.yml` + `scripts/escalation-check.sh` to `scope-creep-console`
  (agent-buildable; the workflow file is escalation-class, so it lands on your marker).
- [ ] **Only then** add the escalation context as required on the console — **do not require it
  before the workflow exists**, or every console PR wedges at "waiting for status":
  ```bash
  # ONLY after the escalation-check workflow exists in scope-creep-console:
  gh api --method PUT repos/dimays/scope-creep-console/branches/main/protection --input - <<'JSON'
  {"required_status_checks":{"strict":true,"contexts":["App Contract test gate","Path-based auto-escalation (ADR-022 trigger d)"]},"enforce_admins":true,"required_pull_request_reviews":{"required_approving_review_count":1,"require_code_owner_reviews":true,"dismiss_stale_reviews":true,"require_last_push_approval":true},"restrictions":null,"allow_force_pushes":false,"allow_deletions":false}
  JSON
  ```

### 1d. ~~Keep the newly-installed **Claude GitHub App** read-only~~ [Owner] — **REVERSED by [[adr-026]]**

> **⛔ REVERSED by [[adr-026]] (2026-09-21) — do NOT keep the Claude App read-only for the cloud
> path.** ledger-066 proved the Claude App is the sandbox's **forced identity**, so it is the *only*
> identity that can author in-sandbox — the write path **requires** granting it scoped write
> (Part 1′). §1d's original reasoning was correct under its **pre-hardening** baseline ("one shared
> identity authors *and could merge*"); post-[[adr-023]] Phase 1 (sole code owner `@scope-creep-review`,
> Part 0), **write ≠ merge for any non-code-owner**, so that hole is closed and the recommendation no
> longer applies. The read-only text below is kept as historical record.

> **[Historical] Recommendation (CTO, [[work-093]]): the Claude GitHub App stays READ-ONLY. Do not grant
> it write to "fix" the push 403.** The 403 is routed *around*, not escalated. *(Superseded — see the
> reversal callout above and [[adr-026]].)*

You installed the **Claude GitHub App** (the principal behind the MCP `github` tools). It is a
**third, distinct** identity — and the one the sandbox's `git push` proxy authenticates as.
Treat it as **read-only**:

| Principal | Posture | Why |
|---|---|---|
| **Claude GitHub App** (MCP tools) | **Read-only** — Contents / Pull requests / Issues / Metadata: **Read** | A **shared, general-purpose** identity behind every interactive Claude session. Giving it write would re-create the "one shared identity authors *and* could merge" hole that [[adr-023]] exists to close — and its permission set is Anthropic's to define, outside our least-privilege control. |
| **`scope-creep-routine[bot]`** (this App) | **Write, scoped** (1a) | The **dedicated** author; a non-code-owner principal that mechanically cannot approve or merge. |

**Why the read-only Claude App does not block us:** the routine authors over **REST with the
bot's own token**, which hits `api.github.com` directly and never touches the git-push proxy.
So the push 403 is irrelevant to the write path — **do not raise the Claude App's grant to
work around it.**

**For a stable Claude-App connection (the MCP tools), the Owner's exact actions:**
- **Scope the installation** to **only** `scope-creep` and `scope-creep-console` (Install App →
  Only select repositories) — same two repos as the bot, not the whole account.
- **Repository permissions: Contents / Pull requests / Issues / Metadata → Read** (the read
  side the MCP tools need). Leave **everything else at No access.**
- **Do not grant Pull requests: Write** unless a concrete need appears — write there would let
  an interactive-Claude path add labels / reviews, widening the trusted set. Read-only is the
  least-privilege default; revisit only on a named requirement.

---

> **What 1a–1c close (and don't).** They make the *unattended cloud routine* "propose, never
> dispose" **mechanically, server-side** (independent of the local `guard-gates` hook, which
> isn't guaranteed in the cloud env): the bot can push branches and open PRs but is the
> author/last-pusher and not a code owner, so it cannot approve or merge, and an
> escalation-class diff stays unmergeable without a genuine `owner-approved`. They do **not**
> cover **interactive agents**, which still run under the shared `dimays` identity and can
> approve as code owner — which is what keeps [[adr-022]] autonomous merge of routine work
> alive (a git-manager-as-`dimays` approval on a bot-authored PR is now a genuine author≠merger
> event). Moving the remaining functions onto restricted identities is the rest of [[adr-023]],
> a follow-up — but this removes the highest-risk actor (the hourly unattended runner) from the
> trusted set, making **[[adr-023]] partially active** once applied.

---

## Part 2 — grant the scoped write access

- [ ] Provision the identity from **1a** with exactly the scopes listed there, on exactly the
  two repos. The stored secrets are the **App ID + base64 private key** from **1D**
  (`GH_APP_ID`, `GH_APP_PRIVATE_KEY_B64`) in the existing **`scope-creep-local`** claude.ai
  cloud environment — **not** a static `GH_TOKEN`. The runtime `GH_TOKEN` is the ~1 h
  installation token the runner **mints each run** (1E) and never stores. Never put the key in
  the repo, a committed `.env`, a ledger entry, or an Artifact ([[tech-sops]] §6).
- [ ] The runner **authors over REST** with the minted token (1E) — it does **not** `git push`
  (403 through the read-only Claude App). Your action is only pasting the two 1D secrets.
- [ ] **Expiry/rotation** is the **1F** posture: installation tokens auto-expire (~1 h, minted
  fresh); the **private key** is the only standing secret (rotate annually, or on suspicion). A
  revoked/expired credential surfaces as a `needs-you` **blocker** (honest-degradation below),
  never a silent drop. *(The reviewer credential `GH_REVIEW_PAT` is a separate, already-correct
  secret — see `docs/owner-apply-reviewer-identity.md`; do not repaste or regenerate it.)*

**Honest-degradation (required behavior, [[work-088]] acceptance):** a `403`/permission error
on push or PR-open is a **hard, non-zero failure**; the ticket stays `ready` (never marked
done/handled), and the routine writes a `needs-you` card via the [[work-064]] writer naming
the cause (*"Couldn't open the PR — routine GitHub write access missing/expired (403). Check
the `GH_TOKEN` secret / expiry."*). Triage judgment still completes; only the write-of-record
step fails; the next sweep retries idempotently.

---

## Part 3 — what the org does on its own vs. what holds for you

Granting write hands the *cloud routine* the ability to **propose**; every **disposition**
gate stays where it is. After Parts 1–2, and independent of them for the build:

| Ticket | Org does autonomously | Holds for you |
|---|---|---|
| [[work-089]] (Console bug: launched thread hides the original prompt) | **Builds and lands it** — routine Console periphery, independent review. Do this **early**: both the live Request Loop and work-sweep produce cloud-launched threads this bug breaks, so fixing it first makes every autonomous run legible. | Nothing. |
| [[work-087]] (milestone predicate + `cadence-decision` self-tune) | Builds the predicate + protocol + unit tests, stages the PR. | **The merge** — edits `loops/` + `registry/` (escalation trigger d); cadence *policy* + milestone rule are core-loop policy ([[adr-021]]). Lands on your `owner-approved`. |
| [[work-086]] (the work-sweep runner) | Builds the runner, reusing the Request Loop substrate ([[adr-024]] store + [[work-064]] writers, [[adr-025]] topology — no schema fork, no new PR path), stages the PR. | **The merge** — new core loop, escalation-class ([[adr-021]]); never self-merged. |

> **Who builds the runner:** work-086/087 are built by a **launched (event-driven) dev-cycle**
> — the sweep can't build itself before it exists. Only *after* it's live does work-sweep pick
> up remaining ready work on its own. The same scoped credential also unblocks the already-live
> **request-triage** routine's autonomous PR-opening — intake and execution share the write
> path.

---

## Part 4 — register the work-sweep cloud routine (mirrors the Request Loop's step 2)

Register **only after** work-086 lands **and** Parts 1–2 are done (a routine that can't open a
PR, or has no runner, is inert). System of record is claude.ai, not this repo ([[adr-016]]).

> **Topology ([[adr-025]]):** sourced from `github.com/dimays/scope-creep`, with
> `scope-creep-console` checked out as a sibling and the [[adr-024]] env from the Request
> Loop's provisioning. Reuse the **`scope-creep-local`** cloud env. Runtime is **Node**
> (`npm run …`), **not bun** (egress proxy drops bun's `fetch`). The routine **stages** PRs
> and **never self-merges**.
>
> **You don't hand-click this** — the CoS can register it programmatically via the schedule
> tooling; **your approval is the gate** (it's the [[adr-021]] loop-creation disposition and
> turns on recurring API spend, [[invariants]] §III).

1. Create the routine → `github.com/dimays/scope-creep`, running the [[work-sweep]] loop,
   sibling + env as above.
2. **Cron seed: `0 16 * * *`** (daily, 16:00 UTC — offset from the 14:00 planning cluster and
   request-triage's `:17`). work-sweep is heavy/build-shaped: each run drains the ready set
   continuously, so it wakes far less often than hourly triage. **`cadence_bounds_days:
   [1, 7]`** — as often as daily when the backlog is deep, backing off toward weekly when it's
   dry; don't hand-tune after this ([[work-087]] self-tunes within bounds).
3. **Model: `claude-sonnet-5`** — matches the scheduled fleet.
4. **Record it in `registry/routines.json`** — a small follow-up PR with the real
   `trigger_id`, `cron`, `cadence_bounds_days`, `model`, `source`, `manage_url`,
   `status: active`, added **after** the routine exists (never a fabricated `trigger_id`).
   Edits `registry/`, so it holds for your marker. Log registration + activation in `ledger/`.

---

## Part 5 — definition of done for activation (observed, not asserted — [[work-086]] acceptance)

- [ ] A `ready` ticket with **nobody at the keyboard** is **picked up within the cadence
  window**.
- [ ] It is **driven to `done`**: ticket → branch → PR → **merge on independent review**
  (author ≠ merger, now GitHub-enforced by 1b; [[code-reviewer]] → [[qa-tester]] proof →
  [[git-manager]] lands + ledger entry).
- [ ] The **outcome is posted back to the owning thread** as a `role = agent` message via the
  [[work-064]] writers, `working` while executing, thread legible (original prompt visible —
  [[work-089]]).
- [ ] The sweep runs **multiple tickets in one run without pausing between them** (WIP cap ≤2).
- [ ] It **stops at `needs-you`** on a **blocker** (STOP/escalation gate) **and** a
  **milestone** (theme/PRD boundary, release boundary, priority-floor exhaustion, or an
  explicit `milestone: owner-review` marker) — **and nowhere else**.
- [ ] **Nothing crosses a STOP gate autonomously**; an escalation-class PR **cannot** be
  self-merged and the `owner-approved` marker cannot merge on its own (1a–1c compose).
- [ ] A missing-scope credential surfaces as a **blocker at `needs-you`**, never a silent drop.

When those hold, the Owner's full vision is met: **requests flow in and get triaged; roadmap
work flows out and gets built — autonomously, stopping only where you said to stop.**

---

## Decision record — credential identity

**DECIDED (Owner, 2026-09-20): separate bot identity now.** The C-suite surfaced a genuine
tradeoff — a separate bot identity now (CRO/reconciled) vs. a fine-grained PAT now with the
separate identity deferred (CTO's speed path). The Owner chose the **separate identity**: the
entire point of this loop is that it runs **unattended**, which is exactly when a process
convention is worth least and a mechanical gate is worth most. Parts 1a–1c therefore give
mechanically-enforced "propose, never dispose" *before* the unattended loop can push anything,
and this closes [[adr-023]]'s substance as part of the grant rather than deferring it.

---

## Residuals (recorded honestly)

- **[[adr-023]] is now a precondition, not a follow-up.** Granting write to the unattended
  routine is what makes the forgeable-marker residual *agent-reachable*. Parts 1a–1c are its
  substance; if you take the PAT bridge instead, [[adr-023]] is the immediate next priority.
- **Local harness gates don't travel to the cloud.** The `guard-gates` hook and the
  `Bash(gh pr merge *)` revocation (`docs/owner-apply-adr-022-floor.md`) are per-checkout,
  gitignored, local — they do **not** constrain the cloud routine. Server-side branch
  protection (Part 1) is the rail that does.
- **Reversible.** Revoke the credential or delete the `GH_TOKEN` secret and the routine drops
  back to read-only; the loop degrades to `needs-you`, never a silent action.

---

## Reference (source of record)

- PRD `product/autonomous-execution-loop.prd.md` · loop `loops/work-sweep.md` · tickets
  `work/086`…`089`
- Governance `standards/adr/021` · `022` · `023` · `025`
- Pattern template `docs/owner-apply-request-loop.md` · registry `registry/routines.json`
