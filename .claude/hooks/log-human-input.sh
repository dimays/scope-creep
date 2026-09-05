#!/usr/bin/env bash
# UserPromptSubmit hook — appends the Owner's prompt to the LOCAL (gitignored)
# human-input NDJSON log (work-020, ADR-010). Fires in Scope-Creep-rooted sessions.
# Must print nothing to stdout (stdout would be injected into the prompt as context).
# The prompt JSON arrives on stdin; the Python does the redaction + append.
# Never blocks a prompt: any failure is swallowed and we exit 0.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
python3 "$ROOT/.claude/hooks/log-human-input.py" "$ROOT" 2>/dev/null || true
exit 0
