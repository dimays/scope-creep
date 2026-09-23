#!/usr/bin/env bash
# routine-reviewer.sh — the ADR-027 automated routine-reviewer (and manual batch tool).
#
# WHAT IT IS
#   The "separated reviewer" from ADR-027: it reviews + merges the safe, ROUTINE pull
#   requests so the Owner isn't disposing them one at a time. It runs OFF-CLOUD, as
#   `@scope-creep-review` — never inside a routine's cloud sandbox (Gate 0 / ledger-072).
#   Two modes, one tool:
#     * MANUAL   (default / --yes): the Owner runs it on demand ("one click for many").
#     * UNATTENDED (--unattended):  a scheduled job runs it with no human in the loop
#                                   (see scripts/routine-reviewer.launchd.plist).
#
# THE SAFETY MODEL (fail-closed — it refuses rather than risk a wrong merge)
#   For each open PR it INDEPENDENTLY re-derives "routine + safe" from a TRUSTED
#   checkout — it re-runs this repo's own scripts/escalation-check.sh against
#   base...head and does NOT trust the PR's own CI classification or labels (both
#   forgeable from the cloud — ADR-026). A PR is approved + merged ONLY if ALL hold:
#     1. the trusted escalation-check classifies the diff ROUTINE (exit 0);
#     2. NO changed path is owned by @dimays in the trusted CODEOWNERS (the two
#        rails can disagree — e.g. charter/* is @dimays in CODEOWNERS but only
#        charter/INVARIANTS.md is caught by escalation-check — so per ADR-027
#        Part 3(b) the reviewer consults BOTH and holds if EITHER says escalation);
#     3. the author is NOT the reviewer identity (author != approver);
#     4. GitHub reports it green + mergeable;
#     5. it is not a draft.
#   Anything escalation-class, ambiguous, or not-green is SKIPPED and left for @dimays.
#
#   Before it touches ANY PR it runs two whole-run preconditions and ABORTS if either
#   fails (this is what makes it safe to install before those preconditions are met):
#     A. RAILS ALIGNED (ADR-027 precondition #1 / PR #124): the trusted
#        escalation-check must carry the gate-script cases, or it would misclassify a
#        gate-script change as routine. If they're absent, the reviewer refuses to run.
#     B. GATE #3(ii) (ADR-026): no code-owner-capable credential may sit in this repo's
#        Actions secrets or Environments (both must be empty), or a forged workflow
#        could authenticate as the reviewer. If either is non-empty, the reviewer refuses.
#
# MERGE MECHANISM
#   Direct approve-then-merge (proven working). It does NOT rely on GitHub-native
#   auto-merge, so it needs no `allow_auto_merge` repo setting. PRs whose CI is still
#   pending are skipped and picked up on the next run. (This diverges from ADR-027
#   Part 5's proposed native-auto-merge; author != merger still holds. Flagged for the
#   ADR to be reconciled — see docs/owner-apply-routine-reviewer.md.)
#
# SAFETY DEFAULTS
#   * DRY-RUN by default. Prints what it WOULD do, changes nothing. --yes to act;
#     --unattended implies --yes and adds timestamped logging + no prompts.
#   * Refuses to run unless `gh` is authenticated as @scope-creep-review.
#   * Escalation-class PRs are never approved, labelled, or merged.
#
# ⚠️  FIRST run must be SUPERVISED (--yes, watched) and its output signed off by the
#     CRO before it is scheduled --unattended. See docs/owner-apply-routine-reviewer.md.
#
# USAGE
#   scripts/routine-reviewer.sh [--repo owner/name] [--yes | --unattended]
#   (defaults: --repo dimays/scope-creep, dry-run)
#
# See: standards/adr/027-autonomous-routine-merge.md · ADR-022 · ADR-023 ·
#      ledger/072-work-sweep-unpause-safety-gates.md (Gate 0) ·
#      docs/owner-apply-routine-reviewer.md (install / schedule).

set -euo pipefail

REPO="dimays/scope-creep"
MODE="dry"   # dry | yes | unattended
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --yes)  [ "$MODE" = dry ] && MODE="yes"; shift ;;
    --unattended) MODE="unattended"; shift ;;
    -h|--help) sed -n '2,50p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
log() { if [ "$MODE" = unattended ]; then echo "$(ts) $*"; else echo "$*"; fi; }
die() { log "ABORT: $*"; exit 2; }

command -v gh  >/dev/null || die "gh CLI not found"
command -v jq  >/dev/null || die "jq not found"

# --- Identity guard: must be the reviewer, never the Owner's own account -----------
me="$(gh api user -q .login 2>/dev/null || true)"
[ "$me" = "scope-creep-review" ] || die "authenticated as '${me:-none}', not '@scope-creep-review' — refusing (author must != approver)."

# --- Concurrency guard (portable — mkdir is atomic; flock is absent on macOS) ------
# We record the holder's PID inside the lock dir so a stale lock from a *dead* run is
# cleared immediately, while a *live* long run is NEVER clobbered regardless of age
# (CRO robustness #4). A pid-less legacy lock still falls back to a 60-min age sweep.
RR_LOCKDIR="${TMPDIR:-/tmp}/.routine-reviewer.$(echo "$REPO" | tr '/' '_').lock.d"
if [ -d "$RR_LOCKDIR" ]; then
  lp="$(cat "$RR_LOCKDIR/pid" 2>/dev/null || true)"
  if [ -n "$lp" ] && kill -0 "$lp" 2>/dev/null; then
    :  # a live run holds it — our mkdir below fails and we exit 0
  elif [ -z "$lp" ] && [ -z "$(find "$RR_LOCKDIR" -maxdepth 0 -mmin +60 2>/dev/null)" ]; then
    :  # no pid but fresh (<60 min): be conservative, leave it
  else
    rm -rf "$RR_LOCKDIR" 2>/dev/null || true  # dead pid, or pid-less + stale
  fi
fi
mkdir "$RR_LOCKDIR" 2>/dev/null || { echo "another routine-reviewer run is active ($RR_LOCKDIR) — exiting."; exit 0; }
echo "$$" > "$RR_LOCKDIR/pid" 2>/dev/null || true

# Register cleanup NOW — before any fetch/mktemp can fail and leave the lock behind
# (CRO robustness #3). The temp-file vars may be unset here; ${VAR:-} makes that safe,
# and the trap body is evaluated at EXIT, by which point they hold their real values.
TRUSTED_ESC=""; TRUSTED_CODEOWNERS=""
trap 'rc=$?; rm -f "${TRUSTED_ESC:-}" "${TRUSTED_CODEOWNERS:-}"; rm -rf "$RR_LOCKDIR" 2>/dev/null || true; exit $rc' EXIT

# --- Trusted rails: run MAIN's copies, never the working tree ----------------------
# (CRO finding: the working-tree copy could be stale or a checked-out PR's version.
# We extract main's copies to private temp files and use THOSE for every decision;
# escalation-check is self-contained — it only shells out to `git diff` on the SHAs,
# sources nothing, and never checks out or executes the PR tree.)
git fetch --quiet origin main
BASE_SHA="$(git rev-parse origin/main)"
TRUSTED_ESC="$(mktemp)"
TRUSTED_CODEOWNERS="$(mktemp)"
git show "origin/main:scripts/escalation-check.sh" > "$TRUSTED_ESC" 2>/dev/null || die "cannot read origin/main's escalation-check.sh"
git show "origin/main:.github/CODEOWNERS"          > "$TRUSTED_CODEOWNERS" 2>/dev/null || die "cannot read origin/main's CODEOWNERS"

# --- Precondition A: rails aligned (ADR-027 #1 / PR #124) --------------------------
# The trusted classifier must catch gate scripts, or it would wave through a change to
# its own trust anchor. Refuse until main's escalation-check carries those cases.
if ! grep -qE 'scripts/guard-\*\.sh\)' "$TRUSTED_ESC" \
   || ! grep -qE 'scripts/escalation-check\*\.sh\)' "$TRUSTED_ESC"; then
  die "main's escalation-check.sh is missing the gate-script cases (ADR-027 precondition #1 / PR #124 not landed) — refusing until the rails are aligned."
fi

# --- Precondition B: gate #3(ii) — no code-owner credential in CI (ADR-026) --------
# FAIL-CLOSED: an unreadable check is treated as "refuse", never "safe". Environments
# are readable by the reviewer identity; the Actions-secrets list requires ADMIN, which
# the (correctly) non-admin reviewer identity lacks — so that sub-check cannot be done
# per-run from here. It is verified at INSTALL by the Owner (admin) and held stable by
# gate #3(i) (the cloud has no Administration write to add secrets). We surface that
# explicitly rather than pretend to have verified it. See docs/owner-apply-routine-reviewer.md.
if env_json="$(gh api "repos/$REPO/environments" 2>/dev/null)"; then
  env_count="$(jq -r '.total_count // 0' <<<"$env_json")"
  [ "$env_count" = "0" ] || die "gate #3(ii): $env_count Environment(s) present on $REPO — refusing."
else
  die "gate #3(ii): cannot read Environments on $REPO — refusing (fail-closed)."
fi
if sec_out="$(gh secret list --repo "$REPO" 2>/dev/null)"; then
  sec_count="$(grep -c . <<<"$sec_out" || true)"
  [ "${sec_count:-0}" = "0" ] || die "gate #3(ii): $sec_count Actions secret(s) present on $REPO — refusing."
  SEC_STATUS="verified empty"
else
  SEC_STATUS="NOT re-verifiable from the non-admin reviewer identity — relying on install-time check + gate #3(i)"
fi

# --- Second rail: CODEOWNERS consult (ADR-027 Part 3(b)) ---------------------------
# Returns 0 (escalation) if $1 is owned by @dimays in the trusted CODEOWNERS. This is
# deliberately CONSERVATIVE (fail toward HOLD): a changed path that matches any @dimays
# pattern holds for the Owner, even if escalation-check would have called it routine.
# CODEOWNERS is last-match-wins; every @dimays pattern here is more specific than the
# `*` periphery default and none is later re-assigned to @scope-creep-review, so
# "matches any @dimays pattern" == "owned by @dimays" for this file. Over-holding (if
# that ever changed) is the safe direction.
codeowners_escalation() {
  f="$1"
  while read -r pat owner _; do
    case "$pat" in ''|\#*) continue ;; esac
    [ "$owner" = "@dimays" ] || continue
    p="${pat#/}"                        # strip the leading anchor slash
    case "$pat" in
      */) case "$f" in "$p"*) return 0 ;; esac ;;   # directory pattern → prefix match
      *)  case "$f" in  $p ) return 0 ;; esac ;;     # file / glob (unquoted for globbing)
    esac
  done < "$TRUSTED_CODEOWNERS"
  return 1
}

log "== routine-reviewer =="
log "repo:      $REPO"
log "reviewer:  $me"
log "mode:      $MODE"
log "base:      origin/main @ $BASE_SHA"
log "checks:    rails-aligned OK · environments empty · secrets: $SEC_STATUS · CODEOWNERS consulted"

# Head-pinned merge if this gh supports it (CRO robustness #6) — closes the residual
# window between the TOCTOU re-check and the merge. If unsupported, the re-check still
# guards it and branch protection's require_last_push_approval is the backstop.
MERGE_PIN=""
if gh pr merge --help 2>&1 | grep -q -- '--match-head-commit'; then MERGE_PIN="yes"; fi

# Collect open PR numbers. NOT `mapfile`/`readarray` — those are bash 4+ builtins and
# macOS ships bash 3.2 as /bin/bash, so this must stay 3.2-portable (a while-read into
# an array append). The `${#PRS[@]}` guard below runs before any `"${PRS[@]}"` expansion,
# which sidesteps bash 3.2's "unbound variable" bug on an empty array under `set -u`.
PRS=()
while IFS= read -r _pr; do
  [ -n "$_pr" ] && PRS+=("$_pr")
done < <(gh pr list --repo "$REPO" --state open --base main --json number --jq '.[].number' 2>/dev/null || true)
[ "${#PRS[@]}" -gt 0 ] || { log "no open PRs targeting main."; exit 0; }

acted=0; skipped=0
for n in "${PRS[@]}"; do
  meta="$(gh pr view "$n" --repo "$REPO" --json number,title,isDraft,author,headRefOid,mergeStateStatus,mergeable)"
  title="$(jq -r .title <<<"$meta")"; draft="$(jq -r .isDraft <<<"$meta")"
  author="$(jq -r .author.login <<<"$meta")"; head_sha="$(jq -r .headRefOid <<<"$meta")"
  state="$(jq -r .mergeStateStatus <<<"$meta")"; mergeable="$(jq -r .mergeable <<<"$meta")"

  skip() { log "SKIP  #$n  ($1)  — $title"; skipped=$((skipped+1)); }

  [ "$draft" = "true" ] && { skip "draft"; continue; }
  [ "$author" = "$me" ] && { skip "authored by reviewer"; continue; }

  git fetch --quiet origin "pull/$n/head" || { skip "cannot fetch head"; continue; }

  # FAIL-CLOSED on an unresolvable head (CRO robustness #5): if the exact commit we
  # classify isn't present (head moved between the meta read and the fetch), defer —
  # never fall through to escalation-check's "empty diff => routine" behavior.
  git cat-file -e "${head_sha}^{commit}" 2>/dev/null || { skip "head $head_sha not present after fetch — deferring"; continue; }

  changed="$(git diff --name-only "$BASE_SHA" "$head_sha" 2>/dev/null || true)"
  [ -n "$changed" ] || { skip "no classifiable diff for $head_sha — deferring"; continue; }

  # SELF-MODIFICATION GUARD: never auto-merge a change to the reviewer's OWN files.
  # (Belt-and-suspenders: these files should ALSO be in the escalation set — CODEOWNERS
  # + escalation-check — so any merge of them requires @dimays. Until that lands, this
  # guard, running from the trusted main copy, keeps the AUTOMATED reviewer from self-merging.)
  if grep -qE '(^|/)scripts/routine-reviewer|(^|/)docs/owner-apply-routine-reviewer' <<<"$changed"; then
    skip "touches the reviewer's own files — holds for @dimays (self-modification guard)"; continue
  fi

  # RAIL 2 — CODEOWNERS: hold if ANY changed path is @dimays-owned (charter/*, gate
  # scripts, standards, etc.) even when escalation-check would call it routine.
  while IFS= read -r cf; do
    [ -z "$cf" ] && continue
    if codeowners_escalation "$cf"; then
      skip "CODEOWNERS routes '$cf' to @dimays (escalation) — holds"; continue 2
    fi
  done <<EOF
$changed
EOF

  # RAIL 1 — the trust anchor: routine-ness from MAIN's escalation-check (extracted
  # above), never the working-tree copy — base...head over the fetched git objects.
  if ! bash "$TRUSTED_ESC" "$BASE_SHA" "$head_sha" >/dev/null 2>&1; then
    skip "escalation-class — holds for @dimays"; continue
  fi

  # Gate on what must hold INDEPENDENT of the review we are about to give: no merge
  # conflict, and all REQUIRED checks green. Do NOT gate on mergeStateStatus==CLEAN —
  # a routine PR still awaiting the code-owner review is BLOCKED, not CLEAN, and would
  # be skipped before we ever approve it (the whole point of the reviewer). GitHub still
  # refuses the final merge unless branch protection is fully satisfied, so approving
  # here cannot force an unsafe merge.
  [ "$mergeable" = "MERGEABLE" ] || { skip "not mergeable (mergeable=$mergeable state=$state)"; continue; }
  gh pr checks "$n" --repo "$REPO" --required >/dev/null 2>&1 || { skip "required checks not green"; continue; }

  if [ "$MODE" = dry ]; then
    log "WOULD MERGE #$n  (routine + checks green)  — $title"; acted=$((acted+1)); continue
  fi

  # TOCTOU guard: ensure the head hasn't moved since we classified it.
  cur_head="$(gh pr view "$n" --repo "$REPO" --json headRefOid -q .headRefOid 2>/dev/null || true)"
  [ "$cur_head" = "$head_sha" ] || { skip "head moved during review — deferring to next run"; continue; }
  log "MERGE #$n  (routine + checks green)  — $title"
  if [ -n "$MERGE_PIN" ]; then
    gh pr review "$n" --repo "$REPO" --approve -b "Routine (re-verified via trusted escalation-check + CODEOWNERS); auto-approved by routine-reviewer." \
      && gh pr merge "$n" --repo "$REPO" --squash --delete-branch --match-head-commit "$head_sha" \
      && acted=$((acted+1)) \
      || { log "WARN #$n approve/merge failed — left for a human"; skipped=$((skipped+1)); }
  else
    gh pr review "$n" --repo "$REPO" --approve -b "Routine (re-verified via trusted escalation-check + CODEOWNERS); auto-approved by routine-reviewer." \
      && gh pr merge "$n" --repo "$REPO" --squash --delete-branch \
      && acted=$((acted+1)) \
      || { log "WARN #$n approve/merge failed — left for a human"; skipped=$((skipped+1)); }
  fi
done

log "== done: $acted $([ "$MODE" = dry ] && echo 'mergeable (dry-run)' || echo merged), $skipped skipped =="
[ "$MODE" = dry ] && log "(dry-run — re-run with --yes to approve + merge the above)"
exit 0
