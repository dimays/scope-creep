# Owner-apply — install & schedule the routine-reviewer (ADR-027)

**What this is:** turning on the ADR-027 **automated routine-reviewer** so ordinary
(non-escalation) pull requests get reviewed + merged **without you** — while sensitive
changes still hold for your `@dimays` review. The tool is `scripts/routine-reviewer.sh`; it
runs **off-cloud, on your Mac, as `@scope-creep-review`** (never in a routine's cloud sandbox).

> **Why Owner-applied:** it runs with your reviewer credential and installs a scheduled job on
> your machine — neither is something an agent can (or should) do. The agent builds the tool and
> this runbook; you install and turn it on.

## Preconditions (the reviewer self-enforces #1 and #3(ii) — it refuses to run otherwise)

1. **Rails aligned (PR #124).** The gate-script cases must be merged into
   `scripts/escalation-check.sh` first. The reviewer checks this on startup and **aborts** if
   they're missing — so it is safe to install now; it simply won't act until #124 lands.
2. **`gh` authenticated as `@scope-creep-review`** on your machine, and the review PAT present at
   `~/.config/scope-creep/review-pat`.
3. **Gate #3(ii) clean.** No code-owner-capable credential in the repo's Actions secrets or
   Environments (both empty). The reviewer re-verifies this every run and aborts if not.
4. **The reviewer's own files are in the escalation set.** `scripts/routine-reviewer*`, its
   `.launchd.plist`, and this runbook should be routed to `@dimays` in `.github/CODEOWNERS` and
   added to `escalation-check.sh` (fold into the PR #124 gate-file patch) — so no one can merge a
   change to the reviewer itself without your review. The script also self-guards (it skips any PR
   touching its own files), but the CODEOWNERS lock is the durable protection.

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
  routine-ness itself from the trusted `escalation-check`.
- It never runs **inside** a routine's cloud sandbox — that would undo Gate 0
  ([[ledger-072-work-sweep-unpause-safety-gates]]).

See ADR-027 (PR #122) · [[adr-022]] · [[adr-023]] · `scripts/routine-reviewer.sh` ·
`scripts/routine-reviewer.launchd.plist`.
