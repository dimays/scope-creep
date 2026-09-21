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

### 1a. Provision the write credential as a *separate* machine identity — not the shared token

**DECIDED (Owner, 2026-09-20): a dedicated bot identity — a GitHub App installation (or a
dedicated machine account), not a fine-grained PAT under `dimays`.** This is the safe path;
the PAT bridge below was explicitly *not* taken.

- The safety property depends on a **required review from a party the routine is not**. A PAT
  minted under `dimays` is the *same principal* as every interactive session and the
  git-manager, so a required review can't tell them apart — it buys nothing. A **separate
  identity** is what lets branch protection enforce author≠merger (1b) and lets CODEOWNERS
  exclude the routine.
- **Scope (least privilege), on both `dimays/scope-creep` and `dimays/scope-creep-console`
  only** (the two repos [[adr-025]] checks out — *not* the design/extension repos):
  - **Contents: Read & write** (push the feature branch)
  - **Pull requests: Read & write** (open the PR)
  - **Metadata: Read** (auto)
  - **Everything else: No access** — in particular **Administration: none** (can't touch
    branch protection) and **Workflows: none** (can't edit `.github/workflows/**`, itself an
    escalation-class path).
- **Honest limit (both CTO and CRO flag this):** there is *no* scope that grants "open PRs"
  without also granting label add/remove on PRs. So the credential **can** self-label. That
  is exactly why 1b (a required review the routine can't satisfy) is non-optional — label
  forgery alone must not be enough to merge.

> *Footnote (decision record): the CTO's original position was a fine-grained PAT now with the
> GitHub App deferred to [[adr-023]], to unblock faster. The CRO demonstrated that deferring
> the separate identity while granting write to an unattended cron agent is what opens the
> forge+merge path. The Owner chose the separate identity (2026-09-20), which folds
> [[adr-023]]'s "separate principal" into this step — so the write grant and its mechanical
> backstop ship together.*

### 1b. Require a real review the routine cannot give — on **both** repos

- [ ] Set `required_approving_review_count: 1` (or more) on `main` for **both** repos.
- [ ] Add a **CODEOWNERS** file naming an approving team/identity that the **routine identity
  is not a member of** (e.g. the Owner, or a `git-manager`/human reviewer identity). Now the
  routine can open a PR but **cannot approve it**, so it cannot merge — author≠merger becomes
  a GitHub rule, not a convention.

### 1c. Give the console repo the escalation rail it's missing

- [ ] Add the **path-based escalation check** (`Path-based auto-escalation (ADR-022 trigger
  d)`, the [[work-057]] check) as a **required status check** on `scope-creep-console`'s
  `main`. Today it has none — so escalation-class console changes aren't caught at all.

> When 1a–1c are in place, the credential can push branches and open PRs on both repos, but a
> merge requires a review from an identity the routine isn't — and an escalation-class diff
> stays RED and unmergeable on **both** repos without a genuine `owner-approved`. That is
> "propose, never dispose," enforced by GitHub rather than by goodwill.

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
