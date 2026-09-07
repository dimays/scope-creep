#!/usr/bin/env bash
# work-060 — Branch protection on every Scope-Creep repo (CRO fix #4 for ADR-022).
# OWNER-RUN: this changes repo security settings, so it must be run by the Owner,
# not an agent. Requires `gh` authed as dimays with `repo` scope (already present).
#
# What it sets on each repo's `main`:
#   - require a PR before merging (0 approvals — a single GitHub identity can't
#     self-approve; author≠merger is enforced at the session/ledger level + the
#     escalation check, not by GitHub review approvals)
#   - require that repo's real status checks to be green
#   - enforce_admins=true  <-- the point: the shared identity cannot bypass the rail
#   - block force-pushes and branch deletion
# Fully reversible: re-run with different values, or delete protection in repo Settings.
set -euo pipefail

apply() {
  local repo="$1"; shift
  local contexts="[]"
  if [ "$#" -gt 0 ]; then
    contexts=$(printf '%s\n' "$@" | jq -R . | jq -sc .)
  fi
  printf '  %-26s ' "$repo"
  jq -nc --argjson ctx "$contexts" '{
    required_status_checks: { strict: true, contexts: $ctx },
    enforce_admins: true,
    required_pull_request_reviews: { required_approving_review_count: 0 },
    restrictions: null,
    allow_force_pushes: false,
    allow_deletions: false
  }' | gh api --method PUT "repos/dimays/$repo/branches/main/protection" --input - \
     -q '"OK  enforce_admins=" + (.enforce_admins.enabled|tostring)
         + "  checks=[" + ([.required_status_checks.contexts[]]|join(", ")) + "]"'
}

echo "Applying branch protection to all Scope-Creep repos..."
apply scope-creep              "Path-based auto-escalation (ADR-022 trigger d)" "Registry sync + work-item schema"
apply scope-creep-console      "App Contract test gate"
apply scope-creep-design       "Package test gate"
apply scope-creep-ext-chatbot  "Package test gate"
apply scope-creep-ext-feedback "Package test gate"
echo "Done. Verify any repo with:  gh api repos/dimays/scope-creep/branches/main/protection"
