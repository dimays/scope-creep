# Owner-apply — install & schedule the routine-reviewer (ADR-027)

**What this is:** turning on the ADR-027 **automated routine-reviewer** so ordinary
(non-escalation) pull requests get reviewed + merged **without you** — while sensitive
changes still hold for your `@dimays` review. The tool is `scripts/routine-reviewer.sh`; it
runs **off-cloud, on your Mac, as `@scope-creep-review`** (never in a routine's cloud sandbox).

> **Why Owner-applied:** it runs with your reviewer credential and installs a scheduled job on
> your machine — neither is something an agent can (or should) do. The agent builds the tool and
> this runbook; you install and turn it on.

## Preconditions

1. **Rails aligned (PR #124) — ✅ landed.** The gate-script cases are merged into
   `scripts/escalation-check.sh` on `main`. The reviewer verifies this on startup (against
   **main's** copy) and **aborts** if they're ever missing.

   > **Two rails, both consulted (CRO re-audit, ADR-027 Part 3(b)).** `escalation-check.sh`
   > and `.github/CODEOWNERS` currently *disagree*: CODEOWNERS routes **all of `/charter/`**
   > to `@dimays`, but `escalation-check.sh` only catches `charter/INVARIANTS.md` — so on its
   > own the check would call a `charter/PRD.md` edit "routine". The reviewer therefore reads
   > **both** trusted copies from `main` and **holds if either** says escalation, so charter
   > (and every other `@dimays`-owned path) is safe **before** the source fix in #4 lands.
2. **`gh` authenticated as `@scope-creep-review`** on your machine (the review PAT at
   `~/.config/scope-creep/review-pat`). The reviewer refuses to run as any other identity.
3. **Gate #3(ii) clean — split by who can see it.** No code-owner-capable credential may sit in
   the repo's Actions secrets or Environments.
   - *Environments* are readable by the reviewer identity, so the reviewer **re-checks them every
     run and aborts fail-closed** (any read error → refuse).
   - *Actions secrets* require **admin** to list, which the (correctly non-admin) reviewer
     identity lacks — so it cannot re-verify them per run. **You verify this once at install**
     (below), and it stays true because the cloud has no Administration write to add a secret
     (gate #3(i)). The reviewer logs `secrets: NOT re-verifiable…` so this is never silently
     assumed. *(This is a small, reasoned deviation from ADR-027 residual (c), which assumed a
     per-run secrets check — flag it for CRO/Owner ratification.)*

   Verify secrets empty now (as admin):
   ```sh
   gh secret list --repo dimays/scope-creep      # expect: no rows
   gh api repos/dimays/scope-creep/environments -q .total_count   # expect: 0
   ```
4. **The reviewer's own files must be in the escalation set (Owner-applied gate patch).** Until
   this lands, a *manual* `@scope-creep-review` approval could merge a change to the reviewer
   itself (the in-script self-guard only covers the automated path). Add these — `escalation-check.sh`
   is guard-blocked, so apply by hand (the PR #124 pattern):

   **`.github/CODEOWNERS`** — under the escalation set (`@dimays`):
   ```
   /scripts/routine-reviewer*          @dimays
   /docs/owner-apply-routine-reviewer.md   @dimays
   ```
   **`scripts/escalation-check.sh`** — in `is_escalation()`, after the `scripts/guard-*.sh)` case:
   ```sh
   scripts/routine-reviewer*)                   return 0 ;;
   docs/owner-apply-routine-reviewer.md)        return 0 ;;
   ```
   **While you're in `scripts/escalation-check.sh`, also close the charter rail-disagreement**
   the CRO found — widen the existing `charter/INVARIANTS.md)` case to the whole directory so
   the check agrees with CODEOWNERS (`/charter/ → @dimays`). Replace:
   ```sh
   charter/INVARIANTS.md)                       return 0 ;;
   ```
   with:
   ```sh
   charter/*)                                   return 0 ;;
   ```
   *(The reviewer already holds charter via the CODEOWNERS rail; this makes the CI check itself
   correct too, so the two rails stop disagreeing. Optional-but-recommended — not a live-safety
   blocker.)*
5. **Live branch protection on `main` re-confirmed (Owner UI — not readable from the cloud).** The
   direct-merge safety rests on it: `require_code_owner_reviews` + `require_last_push_approval` +
   `escalation-check` as a required status check + `enforce_admins`. Confirm these are on before
   the first `--yes` run.

## Step 1 — Supervised first run (DRY-RUN, then a watched real run)

From your scope-creep checkout, authenticated as `@scope-creep-review`:

```sh
# 1a. dry-run — shows exactly what it WOULD merge, changes nothing:
scripts/routine-reviewer.sh

# 1b. watched real run — actually approves + merges the routine + green PRs it listed:
scripts/routine-reviewer.sh --yes
```

Confirm by eye that it merged only **ordinary** PRs and **skipped every sensitive one**
(anything touching the safety rails, gate scripts, roster, or the routine config). Keep the
output.

## Step 2 — CRO sign-off (ADR-027 build gate)

Hand the Step-1 output to the Chief Reality Officer to confirm the three un-spoofability
preconditions held in practice (trusted re-run used, escalation held for `@dimays`, gate #3(ii)
verified). **Do not schedule it unattended until this sign-off exists.**

## Step 3 — Schedule it unattended (launchd)

```sh
# copy the template, fill in your checkout path, install it:
sed "s#__CHECKOUT__#$HOME/code/scope-creep#g" \
  scripts/routine-reviewer.launchd.plist > ~/Library/LaunchAgents/com.scope-creep.routine-reviewer.plist
launchctl load  ~/Library/LaunchAgents/com.scope-creep.routine-reviewer.plist
# watch it:
tail -f ~/code/scope-creep/.routine-reviewer.log
```

It runs every 30 minutes, reads the review PAT at run time (the token is never stored in the
plist), logs each pass, and merges only what is cleanly routine + green.

## Turning it off / reverting

```sh
launchctl unload ~/Library/LaunchAgents/com.scope-creep.routine-reviewer.plist
rm ~/Library/LaunchAgents/com.scope-creep.routine-reviewer.plist
```

Everything falls back to the manual 2-click. Nothing about the cloud routine's own access
changes.

## What it deliberately never does

- It never touches an **escalation-class** PR (safety rails / gate scripts / roster / routine
  config) — those always hold for your `@dimays` review.
- It never trusts a PR's own CI-green or label (both forgeable from the cloud); it re-derives
  routine-ness itself from **two** trusted rails read from `main` — `escalation-check` **and**
  `CODEOWNERS` — and holds if either flags any changed path.
- It uses **direct approve-then-merge**, not GitHub-native auto-merge (ADR-027 Part 5 proposed
  the native path; this drops the unproven `allow_auto_merge` dependency and still keeps
  author ≠ merger). *Reconcile ADR-027's text to match before it leaves "proposed".*
- It never runs **inside** a routine's cloud sandbox — that would undo Gate 0
  ([[ledger-072-work-sweep-unpause-safety-gates]]).

See ADR-027 (PR #122) · [[adr-022]] · [[adr-023]] · `scripts/routine-reviewer.sh` ·
`scripts/routine-reviewer.launchd.plist`.
