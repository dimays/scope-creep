#!/usr/bin/env bash
# guard-gates.sh — mechanical enforcement of Scope Creep's human-gated actions.
# INVARIANTS §III: deploy / spend / delete / publish require Owner confirmation.
# Wired as a PreToolUse(Bash) hook in .claude/settings.json.
#
# Reads the hook JSON on stdin, inspects the proposed shell command, and BLOCKS
# (exit 2) the irreversible/outward-facing ones so an agent cannot run them
# silently. The Owner runs these themselves, or explicitly authorizes them.

payload="$(cat)"
# Extract the command without requiring jq: grab the "command" field value.
cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"

block() {
  echo "BLOCKED by Scope Creep gate: $1" >&2
  echo "This is a human-gated action (INVARIANTS §III). Propose it to the Owner; do not run it yourself." >&2
  exit 2
}

case "$cmd" in
  *"fly deploy"*|*"fly apps destroy"*|*"fly volumes destroy"*)
    block "production deploy/destroy (fly)";;
  *"npm publish"*|*"bun publish"*|*"pnpm publish"*|*"yarn publish"*)
    block "package publish (outward-facing)";;
  *"gh release create"*)
    block "GitHub release (publish)";;
  *"git push --force"*|*"git push -f"*)
    block "force-push (history rewrite)";;
  *"rm -rf /"*|*"rm -rf ~"*)
    block "recursive delete of a root/home path";;
  # --- work-058: spend/deploy/publish blocklist gaps the CRO flagged (§7) ---
  *"terraform apply"*|*"terraform destroy"*)
    block "terraform apply/destroy (provision/deploy/spend/destroy)";;
  *"docker push"*)
    block "docker push (publish an image to a registry)";;
  *"git push heroku"*)
    block "git push heroku (production deploy)";;
  *"heroku create"*|*"heroku apps:create"*|*"heroku addons:create"*|*"heroku addons:add"*|*"heroku ps:scale"*)
    block "heroku create/scale/addons (deploy/spend)";;
  *"gcloud app deploy"*|*"gcloud run deploy"*|*"gcloud functions deploy"*|*"gcloud builds submit"*)
    block "gcloud deploy (production deploy/spend)";;
  *"aws cloudformation deploy"*|*"aws cloudformation create-stack"*|*"aws cloudformation update-stack"*)
    block "aws cloudformation deploy/create/update (provision/spend)";;
esac

# --- work-058: gate `gh pr merge` on green required checks -------------------
# ADR-022's autonomous-merge model must not be optional from the harness's view.
# An autonomous merge may proceed ONLY when EVERY required check is green — this
# includes the work-057 escalation-check, which stays RED on an escalation-class
# PR until the Owner adds the `owner-approved` label. Any red/pending check, or
# any error reaching GitHub, BLOCKS the merge (fail-closed). The blanket
# `Bash(gh pr merge *)` grant in settings.local.json is revoked in the same
# change, so this gated path is the only way an agent merges.
#
# NOTE (shared identity, load-bearing): with all agents on the Owner's one
# GitHub identity, an agent could still add the `owner-approved` label itself to
# turn the escalation-check green. This gate makes a red gate un-mergeable and
# forces an explicit, auditable approval event, but full un-forgeability needs
# identity/token separation (work-059). Do not treat this as un-spoofable.
case "$cmd" in
  *"gh pr merge"*)
    # First non-flag token after `gh pr merge` is an explicit PR target
    # (number | url | branch); if there is none, gh (and we) use the current
    # branch's PR.
    target="$(printf '%s' "$cmd" | sed -n 's/.*gh pr merge//p' | awk '{for(i=1;i<=NF;i++){if($i !~ /^-/){print $i; exit}}}')"
    if ! command -v gh >/dev/null 2>&1; then
      block "cannot verify PR checks (gh not found) — refusing merge (fail-closed)."
    fi
    # shellcheck disable=SC2086
    # work-062: carry the PR's repo through so we verify the RIGHT repo's checks, not a
    # same-numbered PR in the CWD's repo. A URL target self-resolves; --repo covers the
    # bare-number form (accepts `--repo x/y` and `--repo=x/y`).
    repo="$(printf '%s' "$cmd" | sed -n 's/.*--repo[ =]\([^ ][^ ]*\).*/\1/p')"
    repo_arg=""
    [ -n "$repo" ] && repo_arg="--repo $repo"
    checks_out="$(gh pr checks $target $repo_arg 2>&1)"; rc=$?
    if [ "$rc" -ne 0 ]; then
      echo "----- gh pr checks (rc=$rc) -----" >&2
      printf '%s\n' "$checks_out" >&2
      block "merge blocked — PR required checks are not all green (rc=$rc). The work-057 escalation-check and every other required check must pass first; an escalation-class PR stays red until the Owner adds the 'owner-approved' label. Fix red/pending checks or route to the Owner. A red gate is never waivable by an agent (INVARIANTS §III.10)."
    fi
    ;;
esac

exit 0
