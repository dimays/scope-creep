# Owner-manual steps — grant GitHub write access & activate the Autonomous Execution Loop ([[prd-autonomous-execution-loop]])

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

The CRO checked the **live** GitHub state, not the docs. Two facts reshape everything:

1. **Branch protection on `main` requires `0` approving reviews and there is no CODEOWNERS
   file** (verified on both `dimays/scope-creep` and `dimays/scope-creep-console`). So for a
   single write-capable identity, **write access = merge access** — GitHub is *not*
   mechanically enforcing author≠merger or any human review today. The "verify → review →
   land" finish line is currently a **process convention** carried by the agent roles, not a
   server-side gate.
2. **`scope-creep-console` has no escalation rail at all** — its only required check is
   `App Contract test gate`; it has **no** path-based escalation check and no CODEOWNERS. A
   write-capable routine could merge a console PR touching any sensitive path with just the
   test gate green.

Composed with the known **[[adr-023]] residual** (the `owner-approved` label is forgeable
under the shared `dimays` identity, and **any credential that can open PRs can also add
labels**), granting write to the *unattended, scheduled* routine makes this path reachable
end-to-end with no human:

> open an escalation-class PR → check goes RED → `gh pr edit --add-label owner-approved` →
> check re-runs GREEN → `gh pr merge` (0 required reviews) → **merged.**

This is precisely the "the org autonomously merges a change to its own gates" case
([[ledger-048]], [[adr-022]] activation gate). **So the write grant must ship together with
the mechanical backstop that closes it** — the substance of [[adr-023]]. The order below does
that.

---

## Part 0 — verify the baseline (do this before anything; ~5 min)

The read-only `403` is **documented but not independently confirmed** (the CRO holds the
interactive `dimays` token, not the routine's cloud credential; and PR authorship can't
distinguish routine from human under the shared identity). Confirm reality before scoping a
fix to an assumption:

- [ ] Trigger the live **request-triage** routine manually (or wait for its `:17` run) and
  read its logs for the push/PR step. Confirm it currently **`403`s on push / can't open a
  PR** (or, if it *can* already, the write-access question is narrower than [[work-088]]
  assumes and this checklist is trued-up against that).
- [ ] Confirm live branch protection matches the CRO's finding, so the Part 1 hardening is
  scoped right:
  ```bash
  gh api repos/dimays/scope-creep/branches/main/protection
  gh api repos/dimays/scope-creep-console/branches/main/protection
  ```
  Expect `required_approving_review_count: 0` and (separately) `gh api repos/dimays/scope-creep/contents/.github/CODEOWNERS` → 404 on both repos.

---

## Part 1 — close the merge gate BEFORE granting write (the safety preconditions)

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
checks out — *not* the design/extension repos) → **Install**. The URL ends in
`/settings/installations/<INSTALLATION_ID>` — note the **Installation ID**.

**D. Land three secrets in the `scope-creep-local` cloud env** (same place as `DATABASE_URL` /
`DATABASE_AUTH_TOKEN`):
- `GH_APP_ID` = the App ID
- `GH_APP_INSTALLATION_ID` = the Installation ID
- `GH_APP_PRIVATE_KEY` = the **full** `.pem` contents (keep the `-----BEGIN/END-----` lines and
  newlines)

**E. Token minting (runner impl — [[work-086]]/[[work-088]], not an Owner step; stated so the
wiring is complete):** at run start the routine mints a ~1h installation token from the three
secrets and exports it, then `git` / `gh` authenticate as `scope-creep-routine[bot]`:
```
// @octokit/auth-app
const auth = createAppAuth({ appId: GH_APP_ID, privateKey: GH_APP_PRIVATE_KEY, installationId: GH_APP_INSTALLATION_ID });
process.env.GH_TOKEN = (await auth({ type: "installation" })).token;
// then: gh auth setup-git  →  git push + gh pr create both act as the bot
```

**F. Expiry / rotation posture:**
- **Installation tokens auto-expire (~1h)** — minted fresh each run, never stored. A leaked
  `GH_TOKEN` is dead within the hour.
- **The private key has no expiry** — the only standing secret. Rotate annually as hygiene, or
  immediately on suspicion (generate a new key, replace `GH_APP_PRIVATE_KEY`, delete the old).
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
  two repos. Store its credential **only** as a secret named **`GH_TOKEN`** in the existing
  **`scope-creep-local`** claude.ai cloud environment (the same place `DATABASE_URL` /
  `DATABASE_AUTH_TOKEN` live, `*.turso.io` allowlisted). Never in the repo, a committed
  `.env`, a ledger entry, or an Artifact ([[tech-sops]] §6).
- [ ] The runner wires `git push` to the same token via `gh auth setup-git` in its setup step
  (impl detail of [[work-086]]; your action is only pasting the secret).
- [ ] Set a **bounded expiry** (90 days recommended) and a rotation reminder. An expired
  credential surfaces as a `needs-you` **blocker** (honest-degradation below), never a silent
  drop.

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
  `Bash(gh pr merge *)` revocation ([[docs/owner-apply-adr-022-floor]]) are per-checkout,
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
