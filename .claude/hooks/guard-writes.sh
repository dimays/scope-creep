#!/usr/bin/env bash
# guard-writes.sh — block Edit/Write to the gate-enforcement surface (work-059).
# INVARIANTS §I.2 (only the Owner amends INVARIANTS), §I.4 (the core changes only
# via governed upgrade), §III (gates are mechanical, not goodwill).
#
# Wired as a PreToolUse hook for Edit|Write|MultiEdit|NotebookEdit in
# .claude/settings.json. The Bash-side gates live in guard-gates.sh; this closes
# the PARALLEL hole for the file-writing tools that CRO fix #3 named: the
# guard-gates hook only ever inspected Bash, so an agent could neuter a gate or
# widen its own permissions with the Edit/Write tool, no prompt (ADR-022
# activation rail #3; ledger/048).
#
# Reads the hook JSON on stdin, extracts the target path, and BLOCKS (exit 2) a
# write whose target is on the gate-enforcement surface:
#   - charter/INVARIANTS.md      the locked law (only the Owner amends, §I.2)
#   - .claude/**                 hooks + the permission config themselves
#   - .github/workflows/**       CI gates (they run with repo secrets)
#   - scripts/escalation-check.sh + scripts/guard-*.sh   the gate logic
#
# The Owner edits these directly (outside an agent's file-writing tool), or an
# agent PROPOSES the change in a docs/owner-apply-*.md for the Owner to apply.
# This is deliberately NARROW — it guards the enforcement mechanisms, not all of
# the core. Ordinary core-upgrade edits (standards/**, agents/**, loops/**,
# work/**, ledger/**, ADRs) stay allowed: they land via PR + the escalation-check
# + Owner review, which is exactly how this very change lands.
#
# Defense in depth: settings.json also carries native `permissions.deny` rules for
# the same paths. This hook is the robust layer (it normalizes worktree/absolute
# paths and gives an explanatory message); the deny rules are the in-band,
# PR-visible declaration. Either alone blocks; both together fail closed.

payload="$(cat)"

# Extract the target path without requiring jq. Edit/Write/MultiEdit carry
# "file_path"; NotebookEdit carries "notebook_path". Take whichever is present.
path="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
if [ -z "$path" ]; then
  path="$(printf '%s' "$payload" | sed -n 's/.*"notebook_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
fi
# No path found -> nothing this hook guards; let permissions/other gates decide.
[ -z "$path" ] && exit 0

# Normalize to a repo-relative path. Tool file paths are absolute; strip the
# project-dir prefix when present, then collapse an isolated-worktree prefix so a
# write inside .claude/worktrees/<id>/ is judged by its IN-REPO path.
rel="$path"
proj="${CLAUDE_PROJECT_DIR:-}"
if [ -n "$proj" ]; then
  case "$path" in
    "$proj"/*) rel="${path#"$proj"/}" ;;
  esac
fi
rel="${rel#./}"
case "$rel" in
  */.claude/worktrees/*)
    rel="${rel#*/.claude/worktrees/}"   # drop everything up to the worktrees dir
    rel="${rel#*/}"                      # drop the <id>/ segment -> repo-relative
    ;;
esac

block() {
  echo "BLOCKED by Scope Creep gate: edit/write to the gate surface ($1)." >&2
  echo "The gate-enforcement surface (charter/INVARIANTS.md, .claude/**, the CI" >&2
  echo "gate workflows, and the guard/escalation scripts) may NOT be modified with" >&2
  echo "a file-writing tool — an agent must not neuter a gate or widen its own" >&2
  echo "permissions. The Owner applies such a change directly, or an agent proposes" >&2
  echo "it in a docs/owner-apply-*.md for the Owner (INVARIANTS §I.2/§I.4, §III;" >&2
  echo "ADR-022 activation rail #3). Do not route around this gate." >&2
  exit 2
}

case "$rel" in
  charter/INVARIANTS.md|*/charter/INVARIANTS.md)
    block "charter/INVARIANTS.md — locked; only the Owner amends (§I.2)" ;;
  .claude/*|*/.claude/*)
    block ".claude/** — the hooks and permission config" ;;
  .github/workflows/*|*/.github/workflows/*)
    block ".github/workflows/** — CI gates run with repo secrets" ;;
  scripts/escalation-check.sh|*/scripts/escalation-check.sh)
    block "scripts/escalation-check.sh — the escalation-gate logic" ;;
  scripts/guard-*.sh|*/scripts/guard-*.sh)
    block "a guard-gate script" ;;
esac

exit 0
