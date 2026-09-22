# Owner-apply runbook — safely un-pause `work-sweep` (work-117)

> **Goal:** turn on autonomous cadenced execution of the work board — un-pause the [[work-sweep]]
> cloud routine — **without** weakening "propose, never dispose."
>
> **Status right now: work-sweep STAYS PAUSED.** Every decisive gate below is **Owner-read or
> cloud-only** and cannot be done from an automated/local session. This runbook is the ordered
> `needs-you` checklist. Decision record: [[ledger-072-work-sweep-unpause-safety-gates]]. Decided
> via the [[decision]] loop: **CTO owns · [[chief-reality-officer]] verifies · [[chief-of-staff]]
> ratifies.**
>
> **Legend:** **[You]** = Owner-only (credentials / cloud env / GitHub UI — an agent cannot).
> **[Me]** = an agent can do it (drafts, agent-authored PRs, in-sandbox canary). Do the phases in
> order; **do not skip a `[You]` gate.**
>
> **Sequencing (CTO call, CRO-concurred): Phase-2-FIRST.** work-sweep is **Tier-2 by nature** —
> its charter drives *any* ready ticket, so it will touch escalation/core/gate paths; there is no
> mechanical path-filter that could safely bound it to Tier-1. So ADR-023 Phase-2 must land before
> work-sweep un-pauses at all. (Tier-1 stays reserved for `board-hygiene`, already canaried —
> [[ledger-071-board-hygiene-first-run-canary]].)

---

## Gate 0 — Resolve the HARD BLOCK: the reviewer PAT in the cloud env **[You]**

`docs/owner-apply-reviewer-identity.md` **step 11** instructed adding the `@scope-creep-review`
PAT to the **`scope-creep-local` cloud env** (work-sweep's own env). If it is there, an unattended
merge-capable reviewer identity sits in the sandbox — the ADR-023 Phase-2 residual, live.

**Disposition (CTO — do BOTH, not either):**

1. **[You] Remove** the `@scope-creep-review` PAT from the `scope-creep-local` cloud env at
   `https://claude.ai/code` (Environments → `scope-creep-local` → env vars). This is **free**: per
   [[adr-026]] parts 3/5 the reviewer PAT is **moot for the cloud path** — the egress proxy
   re-authenticates every `api.github.com` call as the shared Claude App and discards the bearer
   token, so review/merge happen **off-sandbox** as `@scope-creep-review`, never from the routine.
   Removing it costs nothing operationally and closes the "one config change from a live
   merge-capable credential" gap that a proxy-wall canary alone does **not** close (the canary
   tests the proxy, not env-var reachability).
2. **[Me] Re-verify** `gh secret list` empty + `environments.total_count = 0` on both repos after
   the change (already empty this session; re-check post-change).
3. The supervised canary (Phase 3) then **proves-inert** as defense-in-depth.

> **Gate 0 does not clear until step 1 is Owner-confirmed.** Until then → **HARD BLOCK**, work-sweep
> stays paused.

---

## Gate 1 — Re-confirm ADR-026 compensating controls **[You] + [Me]**

- **[Me] gate #3(ii) — re-verified clean this session:** `gh secret list` empty both repos;
  `environments.total_count = 0` both; `main` protection LIVE both
  (`require_code_owner_reviews`=true, `require_last_push_approval`=true, escalation-check a
  required status check, `enforce_admins`=true).
- **[You] gate #3(i) — NOT verifiable by CLI, still open:** confirm in the GitHub UI that
  **`Administration` / branch-protection write is ABSENT** from the shared Claude GitHub App grant
  on both repos. Do **not** treat ADR-026's 2026-09-21 Owner-report as a standing verification —
  re-read it now. If Administration write is present → **HARD BLOCK** (the identity could rewrite
  the code-owner rule).

---

## Phase 2 — Close ADR-023 Phase-2 (unlocks Tier-2)

### 2a. Land work-094 — the escalation-check CODEOWNERS case **[You applies / Owner-approved]**

`scripts/escalation-check.sh` is on the locked gate surface (`guard-writes.sh` + `permissions.deny`)
— an agent may **not** edit it. **[You]** apply this exact one-line patch to the **control-plane**
`scripts/escalation-check.sh`, inside `is_escalation()`, immediately after the
`.github/workflows/*)` case (line 67), matching the console's shipped form:

```sh
    .github/CODEOWNERS)                          return 0 ;;
```

Commit on a branch; `@scope-creep-review` approves; **[You]** add the `owner-approved` label
(this PR self-flags escalation) → merge. (The console already covers CODEOWNERS — line 122 — so
this only closes the control-plane asymmetry, [[work-094]].)

### 2b. The CODEOWNERS split — both repos **[Me authors → You disposes]**

Replace the current `* @scope-creep-review` (no split) with a genuine split: **escalation set →
`@dimays` (human-only); periphery → `@scope-creep-review`.**

- **`dimays/scope-creep` escalation set → `@dimays`:** `charter/INVARIANTS.md`, `charter/`,
  `.claude/`, `standards/`, `agents/`, `loops/`, `registry/`, `.github/workflows/`,
  `.github/CODEOWNERS`, `scripts/escalation-check*.sh`, `ledger/README.md` — **NOT** all of
  `ledger/**` (routine append entries stay periphery; only the README/policy file escalates).
- **`dimays/scope-creep-console` escalation set → `@dimays`:** `.github/`, `.claude/`,
  `scripts/escalation-check.sh`, infra/lock manifests, `drizzle.config.ts`, `app/db/config.ts`,
  `.env*`.
- **Periphery → `@scope-creep-review`** on both.

> **`require_last_push_approval` trap (CTO — must heed):** `main` protection has
> `require_last_push_approval=true`, and `@dimays` is the sole human code owner for the escalation
> set. So `@dimays` **cannot be both the last pusher and the approver** — his own push dismisses
> his approval. **Mitigation (preferred): [Me]/`git-manager` authors the split PR** so `@dimays` is
> never the last pusher and disposes as pure code-owner + `owner-approved` label. (Alternative: add
> a second human code owner.) Do **not** let the human code-owner also be the last committer.

### 2c. Bump ADR-023 status + ledger + live-verify gate **[Me drafts → You disposes]**

- `standards/adr/023` status → **Phase-2 active** (escalation-class change — Owner-approved).
- **Reviewer-identity live-verify gate** (`docs/owner-apply-reviewer-identity.md` Phase 4 / live
  checklist): a CODEOWNERS-only PR shows escalation-check **RED** without `owner-approved`;
  `@scope-creep-review` **cannot** approve an escalation-set change; **`@dimays` can**. Capture the
  evidence in the ledger.

---

## Phase 3 — Un-pause work-sweep per ADR-026 (supervised canary) **[Me runs cloud canary → You un-pauses]**

Run a supervised cloud canary modeled on `board-hygiene`/[[ledger-071-board-hygiene-first-run-canary]],
capturing ADR-026 un-pausing criteria **1 / 2 / 4 / 6** — and, unlike ledger-071, **the direct
in-sandbox probe** that was previously only observed indirectly:

- **Criterion 1:** `POST /git/refs` (throwaway branch) → **201**.
- **Criterion 2:** `POST /pulls` → **201**; PR `user.login` == the proxy identity (Claude App /
  `dimays`), **not** `@scope-creep-review`.
- **Criterion 4 (the gap ledger-071 left):** a **direct** `PUT /repos/{owner}/{repo}/pulls/{n}/merge`
  from the sandbox → **405/409** (required code-owner review unsatisfied). This is the empirical
  proof the reviewer PAT is **inert in-sandbox** (Gate 0 defense-in-depth) — ledger-071 only had
  the indirect `mergeable_state: "blocked"`.
- **Criterion 6:** honest degradation — a forced 403 leaves the ticket `ready` + a `needs-you`
  card, never silent/done.
- **Plus:** propose-only proof, **escalation-refusal** proof (an escalation-class ticket HOLDS for
  the Owner even at Tier-2), and the **WIP-cap** (≤2 active) proof.

Then flip the routine live:

- **[You] Un-pause the routine at its `manage_url`** (`https://claude.ai/code/routines/trig_01Aw7cBgWjGTER2FeAe9tyeT`).
  **This is the real switch** — the routine's system of record is **claude.ai, not the repo**
  ([[adr-016]]).
- **[Me] Mirror the state:** flip `registry/routines.json` `paused → active` as a **separate**
  Owner-approved control-plane PR (work-sweep may **not** un-pause itself; `registry/*` is
  escalation-class), and **refresh its stale note** (it still cites the superseded work-092/093 bot
  path — the live gate is ADR-026 + ADR-023 Phase-2).

---

## Un-pause gate summary (ALL must hold)

- [ ] **Gate 0** — reviewer PAT removed from the `scope-creep-local` cloud env **[You]**.
- [ ] **Gate 1(i)** — Administration/branch-protection write ABSENT from the Claude App grant, re-confirmed **[You]**.
- [ ] **Gate 1(ii)** — secrets empty + environments 0 both repos (re-verified) **[Me]**.
- [ ] **Phase 2a** — work-094 CODEOWNERS case landed on the control-plane escalation-check **[You]**.
- [ ] **Phase 2b** — CODEOWNERS split landed both repos (escalation → `@dimays`) **[You disposes]**.
- [ ] **Phase 2c** — ADR-023 → Phase-2 active; live-verify gate captured.
- [ ] **Phase 3** — ADR-026 canary criteria 1/2/4/6 + propose-only + escalation-refusal + WIP-cap captured.
- [ ] **Phase 3** — routine un-paused at claude.ai `manage_url` **[You]**; `registry/routines.json` mirrored via a separate Owner-approved PR.

Only when every box is checked does `work-sweep` run unattended — and even then, **escalation-class
tickets ALWAYS hold for the Owner.** Any permission denial at any step → the ticket stays `ready` +
a `needs-you` card, **never silent, never done** ([[invariants]], [[adr-022]], [[adr-026]]).

## Reference
[[adr-026]] (write path / tiered un-pause) · [[adr-023]] (Phase-2 residual) · [[adr-022]]
(escalation) · [[work-sweep]] · [[work-117]] · [[work-094]] ·
`docs/owner-apply-reviewer-identity.md` (step 11 + live-verify) ·
`docs/owner-apply-board-hygiene-routine.md` (canary model) ·
[[ledger-072-work-sweep-unpause-safety-gates]] · [[ledger-071-board-hygiene-first-run-canary]] ·
[[ledger-066-cloud-sandbox-proxy-identity-wall]].
