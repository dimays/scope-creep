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
  *"git push --force"*|*"git push -f"*)
    block "force-push (history rewrite)";;
  *"rm -rf /"*|*"rm -rf ~"*)
    block "recursive delete of a root/home path";;
esac

exit 0
