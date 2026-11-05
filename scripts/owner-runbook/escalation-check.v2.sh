#!/usr/bin/env bash
# escalation-check.sh — the FLOOR mechanical rail for ADR-022 trigger (d) (work-057).
#
# v2 (ADR-028, INVARIANTS v2.0.0 §4): escalates ONLY the safety kernel. Standards,
# loops, registries, ADRs, employees/templates, PRD and glossary are org-governed.
# STAGED for the Owner to copy over scripts/escalation-check.sh (agents cannot write it).
#
# Classifies a PR's changed paths and, if the diff touches an ESCALATION-CLASS
# path (the safety rails / core / infra / paid-dependency manifests) WITHOUT the
# Owner-approval marker, exits non-zero to HOLD the PR for the Owner. This makes
# ADR-022 trigger (d) — and much of (a) — mechanical rather than reviewer
# judgment. See standards/adr/022-autonomous-merge-with-escalation.md.
#
# Usage:
#   escalation-check.sh <base-ref> <head-ref> [--marker-present]
#     base-ref / head-ref  any git revisions (e.g. a base sha and a head sha).
#                          The changed set is the three-dot diff base...head
#                          (i.e. changes introduced on head since the merge-base).
#     --marker-present     the CALLER verified the Owner-approval marker is present
#                          (the CI workflow checks the `owner-approved` PR label).
#                          When present, escalation-class touches are ALLOWED — the
#                          Owner has approved — and the script reports them, exit 0.
#
# Exit codes:
#   0  no escalation-class path touched, OR the marker is present -> may proceed.
#   1  escalation-class path touched and NO marker -> HOLD for the Owner.
#   2  usage / internal error.
#
# ---------------------------------------------------------------------------
# LOAD-BEARING HONESTY — the marker is FORGEABLE under today's shared identity.
# ---------------------------------------------------------------------------
# The Owner-approval marker enforced today is the `owner-approved` GitHub label
# (checked by .github/workflows/escalation-check.yml, not by this script). Under
# the current setup ALL agents act through the Owner's ONE GitHub identity, so an
# agent with `gh` can add that label itself (`gh pr edit --add-label
# owner-approved`) and clear this hold. That is a real residual gap: this rail
# stops the *accidental / unreviewed* escalation merge and forces the decision to
# be an explicit, auditable label event, but it is NOT un-spoofable against a
# deliberate agent. TRUE un-forgeability requires identity/token separation — a
# restricted agent token that CANNOT self-label/self-approve, distinct from the
# Owner's token (work-059's domain). Do not represent this marker as un-spoofable.
# ---------------------------------------------------------------------------

set -u

usage() {
  echo "usage: escalation-check.sh <base-ref> <head-ref> [--marker-present]" >&2
  exit 2
}

base="${1:-}"
head="${2:-}"
marker="${3:-}"
[ -z "$base" ] || [ -z "$head" ] && usage
if [ -n "$marker" ] && [ "$marker" != "--marker-present" ]; then usage; fi

# is_escalation <path> -> return 0 if the path is escalation-class, else 1.
# The ledger carve-out is handled inline: a routine append / new ledger entry is
# NOT escalation; a NON-append change to the ledger (deletions => a format/policy
# rewrite) IS. Everything else is a straight path match.
is_escalation() {
  f="$1"
  case "$f" in
    # --- ADR-028 / INVARIANTS v2.0.0 §4: the SAFETY KERNEL only ---
    # (a) the two Owner-held charter docs. The rest of charter/ (PRD, GLOSSARY) is org-governed.
    charter/INVARIANTS.md)                       return 0 ;;
    charter/PRINCIPLES.md)                       return 0 ;;
    AGENTS.md)                                   return 0 ;;
    # (b) the gate-enforcement surface
    .claude/*)                                   return 0 ;;
    .github/workflows/*)                         return 0 ;;
    .github/CODEOWNERS)                          return 0 ;;
    # gate scripts (align is_escalation with CODEOWNERS; the routine-reviewer greps for these two cases)
    scripts/escalation-check*.sh)                return 0 ;;
    scripts/guard-*.sh)                          return 0 ;;
    scripts/routine-reviewer*)                   return 0 ;;
    scripts/owner-runbook/*)                     return 0 ;;
    docs/owner-apply-routine-reviewer.md)        return 0 ;;
    # (c) the escalation model
    standards/decision-rights.md)                return 0 ;;
    # (e) dependency / infrastructure manifests (supply chain; overlaps spend trigger (a))
    #     Listed BEFORE the agents/ carve-out so a manifest nested anywhere is still held.
    package.json|*/package.json)                 return 0 ;;
    package-lock.json|*/package-lock.json)       return 0 ;;
    npm-shrinkwrap.json|*/npm-shrinkwrap.json)   return 0 ;;
    yarn.lock|*/yarn.lock)                       return 0 ;;
    pnpm-lock.yaml|*/pnpm-lock.yaml)             return 0 ;;
    bun.lockb|*/bun.lockb)                       return 0 ;;
    bun.lock|*/bun.lock)                         return 0 ;;
    Dockerfile|*/Dockerfile|Dockerfile.*|*/Dockerfile.*) return 0 ;;
    fly.toml|*/fly.toml)                         return 0 ;;
    Procfile|*/Procfile)                         return 0 ;;
    *.tf|*.tfvars)                               return 0 ;;
    # (d) executive + standing-function charters: TOP-LEVEL agents/*.md only.
    #     agents/employees/* and agents/templates/* are org-governed (standing ratification, §3).
    #     (bash `case` * matches '/', so the nested carve-out must come first.)
    agents/*/*)                                  return 1 ;;
    agents/*.md)                                 return 0 ;;
    # --- ledger: POLICY is kernel-adjacent; append/new entries are routine ---
    ledger/README.md)                            return 0 ;;
    ledger/*)
      dels="$(git diff --numstat "$base...$head" -- "$f" 2>/dev/null | awk 'NR==1{print $2}')"
      # numstat prints "-" for binary; treat non-numeric / 0 as append-only.
      case "$dels" in
        ''|-|0) return 1 ;;
        *[!0-9]*) return 1 ;;
        *) return 0 ;;   # >0 deletions => a non-append (format/policy) change
      esac
      ;;
  esac
  # Everything else (standards/**, loops/**, registry/**, ADRs, agents/employees|templates,
  # charter/PRD.md, charter/GLOSSARY.md, work/**, product/**, roadmap/**, docs/**) is
  # ORG-GOVERNED per INVARIANTS v2.0.0 §4: independent org review, not the Owner.
  return 1
}

# --no-renames: a rename is reported as delete(old) + add(new), so MOVING a safety-kernel
# file out of its held path is itself held (INVARIANTS v2.0.0 §4; CRO 2026-09-24 finding).
changed="$(git diff --name-only --no-renames "$base...$head" 2>/dev/null)"
if [ -z "$changed" ]; then
  echo "escalation-check: empty diff for $base...$head — nothing to classify."
  exit 0
fi

esc=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  if is_escalation "$f"; then
    esc="${esc}  - ${f}"$'\n'
  fi
done <<EOF
$changed
EOF

if [ -z "$esc" ]; then
  echo "escalation-check: PASS — no escalation-class paths touched (routine PR)."
  exit 0
fi

echo "escalation-check: escalation-class paths touched (ADR-022 trigger (d)):"
printf '%s' "$esc"

if [ "$marker" = "--marker-present" ]; then
  echo "escalation-check: Owner-approval marker present (owner-approved label) — ALLOW."
  echo "  (Reminder: under shared identity this label is agent-forgeable; see work-059.)"
  exit 0
fi

echo "escalation-check: HOLD — escalation-class change with NO Owner-approval marker."
echo "  This PR edits the safety rails / core / infra and must be approved by the Owner."
echo "  The Owner clears the hold by adding the 'owner-approved' label to this PR."
echo "  (Residual gap: that label is agent-forgeable under the shared GitHub identity"
echo "   until identity/token separation lands — work-059. It is not un-spoofable today.)"
exit 1
