#!/usr/bin/env bash
# PreToolUse:Task hook (work-036) — appends the spawn to the LOCAL (gitignored)
# activity NDJSON log. Fires in Scope-Creep-rooted sessions when an agent uses the
# Task tool. Must print nothing to stdout (stdout would be injected into context).
# The tool-call JSON arrives on stdin; the Python does the extraction + append.
# Never blocks a tool call: any failure is swallowed and we exit 0.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
python3 "$ROOT/.claude/hooks/log-activity.py" "$ROOT" 2>/dev/null || true
exit 0
