# Owner-apply runbook — the reviewer/merger identity (ADR-023 Phase 1)

> **Goal:** stand up a dedicated **machine account** (`@scope-creep-review`) as the code
> owner on both repos, so it — not you — is the independent approver of routine PRs. This
> **unjams the control plane** (today every `dimays`-authored PR deadlocks: sole code owner =
> author, and GitHub forbids self-approval) and makes author≠merger mechanically real.
>
> **What this does NOT do (honest):** it does not close ADR-023. The `owner-approved` label
> stays forgeable by any write-holder until **Phase 2** (a human-only code owner for core
> paths, once authoring agents are off the shared identity). ADR-023 stays `PROPOSED`.
>
> **Legend:** **[You]** = you do it (credentials/clicks — an agent can't). **[Me]** =
> automated; I do it. Do the phases in order.

---

## Phase 1 — Provision the machine account **[You, ~15 min]**

**Order matters (CRO F5):** a CODEOWNERS entry pointing at an account that hasn't *accepted*
Write access is silently ignored — which would re-create today's deadlock under a new name. So
finish 1–3 **fully** before we touch CODEOWNERS in Phase 2.

1. **Create the account.** Sign up for a new GitHub account, username **`scope-creep-review`**,
   on a dedicated email alias (e.g. `you+screview@…`). Turn on **2FA** and save the recovery
   codes. (A machine/bot account is allowed under GitHub ToS.)

2. **Add it as a Write collaborator on both repos** — logged in as **`dimays`**:
   - `dimays/scope-creep` → Settings → Collaborators → **Add people** → `scope-creep-review`
     → role **Write** (not Admin).
   - `dimays/scope-creep-console` → same.
   Then **log in as `scope-creep-review`** and **accept both invitations** (email links or
   the repo pages). Confirm it can see both repos before continuing.

3. **Mint its credential — a classic `repo`-scoped PAT** (CRO F4: a fine-grained token can't
   reach another personal account's repos, so classic is required). Logged in as
   `scope-creep-review`: Settings → Developer settings → **Personal access tokens → Tokens
   (classic)** → **Generate new token (classic)** → note "scope-creep reviewer" → **scope: tick
   only `repo`** → set an expiry (90 days) → **Generate** → copy it.

4. **Hand me the token without pasting it in chat.** Save it to a local file only you and I can
   read, then tell me "saved":
   ```bash
   mkdir -p ~/.config/scope-creep && umask 177 && cat > ~/.config/scope-creep/review-pat
   # paste the token, press Enter, then Ctrl-D
   chmod 600 ~/.config/scope-creep/review-pat
   ```
   I'll read it from there for the machine-account operations (authoring the CODEOWNERS PR and
   approving PRs) and never echo it. It lives outside any repo, so it's never committed.

---

## Phase 2 — Swap CODEOWNERS to the reviewer & unjam **[Me authors → You approve]**

5. **[Me]** Using the token from step 4, I author a tiny PR **as `@scope-creep-review`** on each
   repo changing CODEOWNERS from `* @dimays` to:
   ```
   *   @scope-creep-review
   ```
   Authored by the machine account (not `dimays`), so **you can approve it** under the current
   rules — no protection relax needed (CRO's recommended bootstrap; the temporary-relax path was
   rejected because the unattended routine could merge into an open window).

6. **[You]** Approve each PR (as `dimays`, still the code owner at that moment). CODEOWNERS-only
   is routine, so **no `owner-approved` label needed** — just your review. I merge them.
   → **Reviewer identity live; control plane unjammed.**

---

## Phase 3 — Verify, then drain the parked PRs **[Me drives; you spot-check]**

7. **[Me] Live-verify** (the load-bearing check, CRO): on a throwaway no-op PR I confirm
   (a) `@scope-creep-review` approving a `dimays`-authored PR flips it `REVIEW_REQUIRED →
   APPROVED` and `BLOCKED → CLEAN`, and (b) it **cannot** approve a PR it authored. Go/no-go.

8. **[Me] Drain the backlog** (approve as `@scope-creep-review`, merge as the git-manager):
   - **#80** — doc reconciliation (clears `ledger/059`).
   - **console #64** — the escalation-check port. After it merges, **[You]** run the one command
     to require its check (it's in `docs/owner-apply-github-write-access.md` §1c; I'll paste it).
   - **#84** — the two follow-up tickets (`work-090`, `work-091`).

---

## Phase 4 — Close the gap the CRO found **[You apply → Me/You land]**

> **CRO F2 (must-fix):** `.github/CODEOWNERS` is **not** in the escalation path-set today, so
> the new sole code owner could approve a PR that *rewrites CODEOWNERS itself* as routine —
> self-disposing the gate's own definition. There is a short, unavoidable window between Phase 2
> and this step (it can only land *through* the now-unjammed flow, and `scripts/escalation-check.sh`
> is on the locked gate surface an agent may not write). The window's only write-capable actors
> are our own controlled identities; land this as the **first** PR after Phase 3.

9. **[You] Edit `scripts/escalation-check.sh`** — inside `is_escalation()`, next to the
   `.github/workflows/*` line, add:
   ```sh
   .github/CODEOWNERS|*/.github/CODEOWNERS)      return 0 ;;
   ```
   (I'll hand you the exact patch + do the same for the console's copy once #64 is in.) Commit on
   a branch and open the PR; `@scope-creep-review` approves + you add `owner-approved` (this PR
   self-flags escalation) → it merges.

---

## Phase 5 — Resume activation **[Me builds; You register]**

10. Build **`work-086`** (work-sweep runner), **`work-087`** (milestone + cadence), **`work-089`**
    (launched-thread bug) — now mergeable through the reviewer flow.
11. **[You]** Add the reviewer PAT to the `scope-creep-local` **cloud env** (so the work-sweep
    routine's review step can approve autonomously), then **register the `work-sweep` cloud
    routine**. → the autonomous execution loop runs.

---

## Live-verify gate (before trusting the unjam — CRO)

Proven on the throwaway PR in Phase 3, not assumed:
- [ ] `@scope-creep-review` review flips a `dimays`-authored PR `REVIEW_REQUIRED → APPROVED`,
  `BLOCKED → CLEAN` (proves a user-collaborator code-owner review satisfies the gate).
- [ ] `@scope-creep-review` **cannot** approve a PR it authored (author≠merger holds).
- [ ] the classic PAT actually reaches `dimays`-owned repos as a collaborator (proves F4).
- [ ] after Phase 4, a PR touching `.github/CODEOWNERS` shows the escalation check **RED**
  without `owner-approved`.

## Reference
- Spec: the CTO's ADR-023 Phase-1 proposal (relayed 2026-09-21); `standards/adr/023-restricted-agent-identity.md` (stays `PROPOSED`).
- Prior gate: `docs/owner-apply-github-write-access.md` (the App identity + branch protection this builds on).
