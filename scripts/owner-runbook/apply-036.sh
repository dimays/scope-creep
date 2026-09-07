#!/usr/bin/env bash
# apply-036.sh — OWNER-RUN. Wires the work-036 activity-capture hook into .claude/.
# An agent can't do this (the gate surface is locked, work-059); you run it by hand.
# Idempotent: safe to run twice. Operates on repo root $1 (default: current dir).
set -euo pipefail
ROOT="${1:-$(pwd)}"
cd "$ROOT"

# 1. Install the capture hook + wrapper into .claude/hooks/
cp scripts/owner-runbook/log-activity.py scripts/owner-runbook/log-activity.sh .claude/hooks/
chmod +x .claude/hooks/log-activity.sh .claude/hooks/log-activity.py

# 2. Wire the PreToolUse:Task hook into .claude/settings.json (idempotent)
python3 - "$ROOT" <<'PY'
import json, sys, os
p = os.path.join(sys.argv[1], ".claude", "settings.json")
d = json.load(open(p))
pre = d.setdefault("hooks", {}).setdefault("PreToolUse", [])
if any(h.get("matcher") == "Task" for h in pre):
    print("  settings.json: Task hook already present")
else:
    pre.append({"matcher": "Task", "hooks": [
        {"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/log-activity.sh\""}]})
    json.dump(d, open(p, "w"), indent=2); open(p, "a").write("\n")
    print("  settings.json: Task hook added")
PY

echo "OK — 036 hook installed."
echo "NEXT: start a FRESH Claude Code session (the hook loads at session start), let it"
echo "spawn any agent, then:  cat $ROOT/activity/*.ndjson   → a spawn line should appear."
echo "The Console → Explore → Activity feed then lights up. (Commit .claude/settings.json"
echo "when you're happy — it's a .claude/ file, so it's yours to commit, not the agent's.)"
