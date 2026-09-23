#!/usr/bin/env bash
# owner-batch-merge-routine.sh — "one click for many": batch-approve + merge the
# safe, routine PRs so the Owner isn't disposing them one at a time.
#
# WHAT IT IS
#   The interim softener from ADR-027 (autonomous routine-merge) — the "separated
#   reviewer" in its simplest, manual form. It runs OFF-SANDBOX, on the Owner's own
#   machine, as `@scope-creep-review` (the reviewer identity the cloud sandbox
#   deliberately cannot hold — Gate 0 / ledger-072). It does NOT run in a routine.
#
# WHAT IT GUARANTEES (fail-closed by design)
#   For every open PR it INDEPENDENTLY re-derives "routine + safe" from a TRUSTED
#   checkout — it re-runs this repo's own scripts/escalation-check.sh against
#   base...head and does NOT trust the PR's own CI classification or labels (both
#   forgeable from the cloud — ADR-026). A PR is approved + merged ONLY if ALL hold:
#     1. its diff is classified ROUTINE by the trusted escalation-check (exit 0);
#     2. its author is NOT the reviewer identity (so author != reviewer holds);
#     3. its required CI checks are green;
#     4. GitHub reports it mergeable.
#   Anything escalation-class, ambiguous, or not-green is SKIPPED and left for the
#   Owner. Skipping is always safe; the worst case is "a PR waited."
#
# SAFETY
#   * DRY-RUN by default. It prints what it WOULD do and changes nothing. Pass --yes
#     to actually approve + merge.
#   * Requires `gh` authenticated as @scope-creep-review (NOT @dimays) — it refuses
#     to run as the wrong identity.
#   * Escalation PRs are never touched; they continue to hold for @dimays.
#
# ⚠️  FIRST CUT — review this script before its first real (--yes) run. It performs
#     merges. Treat the dry-run output as the source of truth until you trust it.
#
# USAGE
#   scripts/owner-batch-merge-routine.sh [--repo owner/name] [--yes]
#   (defaults: --repo dimays/scope-creep, dry-run)
#
# See: standards/adr/027-autonomous-routine-merge.md (PR #122), ADR-022, ADR-023,
#      ledger/072-work-sweep-unpause-safety-gates.md (Gate 0).

set -euo pipefail

REPO="dimays/scope-creep"
APPLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --yes)  APPLY=1; shift ;;
    -h|--help) sed -n '2,40p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

command -v gh >/dev/null || { echo "error: gh CLI not found" >&2; exit 2; }

# --- Identity guard: must be the reviewer, never the Owner's own account ----------
me="$(gh api user -q .login)"
if [ "$me" != "scope-creep-review" ]; then
  echo "REFUSING: gh is authenticated as '$me', not '@scope-creep-review'." >&2
  echo "This tool must act as the reviewer identity (so author != reviewer holds)." >&2
  echo "Authenticate gh with the review PAT (~/.config/scope-creep/review-pat) and retry." >&2
  exit 2
fi

# --- Trusted checkout: run the gate script from THIS repo, against fresh main ------
# We are running from a real checkout of the control plane, so scripts/escalation-check.sh
# here IS the trusted copy. Make sure origin/main is current for base comparisons.
git fetch --quiet origin main
BASE_SHA="$(git rev-parse origin/main)"

echo "== owner-batch-merge-routine =="
echo "repo:     $REPO"
echo "reviewer: $me"
echo "mode:     $([ "$APPLY" = 1 ] && echo 'APPLY (will approve + merge)' || echo 'DRY-RUN (no changes)')"
echo "trusted base (origin/main): $BASE_SHA"
echo

# All open, non-draft PRs targeting main.
mapfile -t PRS < <(gh pr list --repo "$REPO" --state open --base main --json number \
  --jq '.[].number' 2>/dev/null || true)

if [ "${#PRS[@]}" -eq 0 ]; then echo "No open PRs targeting main."; exit 0; fi

merged=0; skipped=0
for n in "${PRS[@]}"; do
  meta="$(gh pr view "$n" --repo "$REPO" \
    --json number,title,isDraft,author,headRefOid,mergeable,mergeStateStatus,reviewDecision)"
  title="$(jq -r .title <<<"$meta")"
  draft="$(jq -r .isDraft <<<"$meta")"
  author="$(jq -r .author.login <<<"$meta")"
  head_sha="$(jq -r .headRefOid <<<"$meta")"
  mergeable="$(jq -r .mergeable <<<"$meta")"
  state="$(jq -r .mergeStateStatus <<<"$meta")"

  skip() { echo "SKIP  #$n  $1  — $title"; skipped=$((skipped+1)); }

  [ "$draft" = "true" ]        && { skip "draft"; continue; }
  [ "$author" = "$me" ]        && { skip "authored by reviewer (author==reviewer)"; continue; }

  # Fetch the PR head so escalation-check can diff base...head locally.
  git fetch --quiet origin "pull/$n/head" || { skip "could not fetch head"; continue; }

  # THE TRUST ANCHOR: re-derive routine-ness from the trusted gate script,
  # against the true base...head — NOT the PR's own CI result.
  if ! bash scripts/escalation-check.sh "$BASE_SHA" "$head_sha" >/dev/null 2>&1; then
    skip "escalation-class (trusted escalation-check HOLD) — holds for @dimays"; continue
  fi

  # Green + mergeable per GitHub (belt-and-suspenders; the trust anchor is above).
  case "$state" in
    CLEAN) : ;;                                   # green + mergeable + approved-or-ok
    BLOCKED) skip "blocked (needs review/checks) — state=$state"; continue ;;
    *) skip "not cleanly mergeable — state=$state, mergeable=$mergeable"; continue ;;
  esac

  if [ "$APPLY" = 1 ]; then
    echo "MERGE #$n  routine + green  — $title"
    gh pr review "$n"  --repo "$REPO" --approve -b "Routine (re-verified via trusted escalation-check); batch-approved."
    gh pr merge  "$n"  --repo "$REPO" --squash --delete-branch
    merged=$((merged+1))
  else
    echo "WOULD MERGE #$n  routine + green  — $title"
    merged=$((merged+1))
  fi
done

echo
echo "== done: $merged $([ "$APPLY" = 1 ] && echo merged || echo 'mergeable (dry-run)'), $skipped skipped =="
[ "$APPLY" = 1 ] || echo "(dry-run — re-run with --yes to approve + merge the above)"
