#!/usr/bin/env python3
"""PreToolUse:Task capture (work-036) — the org-activity spike.

Reads the hook JSON on stdin when an agent spawns a subagent (the Task tool) and
appends one NDJSON line to the LOCAL, gitignored `activity/YYYY-MM.ndjson` under ROOT
(argv[1]). The schema matches exactly what the Console activity feed (work-037) reads:
{ts, actor, type, summary, threadId?, sessionId}. Prints nothing (stdout from a hook is
injected into the model's context). Never raises to the caller — a capture failure must
never block a tool call.

v1 attribution (honest, documented in work-036): `actor` is the subagent being spun up
(mechanically available in the payload); the *delegating* parent isn't cleanly knowable
from a PreToolUse hook, so this logs "<agent> was spun up to <summary>". Refining actor to
the delegator is a future step. Extend to SubagentStop for completion events if wanted.
"""
import sys, json, os, time, re

root = sys.argv[1] if len(sys.argv) > 1 else "."
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_input = data.get("tool_input") or {}
actor = tool_input.get("subagent_type") or ""
if not actor:
    sys.exit(0)  # not a subagent spawn we can attribute — skip

summary = (tool_input.get("description") or "").strip()
# Redact obvious secrets, mirroring the human-input hook (content isn't guaranteed clean).
summary = re.sub(
    r"(sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})",
    "[redacted]",
    summary,
)

rec = {
    "ts": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "actor": actor,
    "type": "spawn",
    "summary": summary,
    "sessionId": data.get("session_id", ""),
}
# If the Task prompt carries a thread marker (the Threads launcher embeds one), tie the
# event to that thread so it also shows inline in the thread (work-031).
m = re.search(r"scope-creep-thread:(\d+)", tool_input.get("prompt") or "")
if m:
    rec["threadId"] = int(m.group(1))

d = os.path.join(root, "activity")
os.makedirs(d, exist_ok=True)
with open(os.path.join(d, time.strftime("%Y-%m") + ".ndjson"), "a") as f:
    f.write(json.dumps(rec) + "\n")
