#!/usr/bin/env python3
"""UserPromptSubmit capture — appends ONE NDJSON line per genuine Owner-typed prompt
to the local, gitignored human-input/YYYY-MM.ndjson under ROOT (argv[1]).

Resilient fix (recurrence guard of work-095/096): classify at capture. Strip leading
harness-injected wrapper blocks, and DROP any prompt that is empty after stripping or
begins with a tool/command block. Prints nothing to stdout; never raises to the caller.
"""
from __future__ import annotations

import json
import os
import re
import sys
import time

INJECTED_WRAPPER_TAGS = ("task-notification", "system-reminder", "ci-monitor-event")

TOOL_COMMAND_TAGS = (
    "bash-input",
    "bash-stdout",
    "bash-stderr",
    "local-command-stdout",
    "local-command-caveat",
    "command-name",
    "command-message",
    "command-args",
)

SECRET_RE = re.compile(
    r"(sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})"
)

_LEADING_WRAPPER_RE = re.compile(
    r"^\s*<(" + "|".join(INJECTED_WRAPPER_TAGS) + r")\b[^>]*>[\s\S]*?</\1>\s*",
    re.IGNORECASE,
)
_LEADING_TOOL_RE = re.compile(
    r"^\s*<(" + "|".join(TOOL_COMMAND_TAGS) + r")\b",
    re.IGNORECASE,
)


def owner_input_text(prompt):
    out = (prompt or "").strip()
    while out:
        stripped = _LEADING_WRAPPER_RE.sub("", out, count=1).strip()
        if stripped == out:
            break
        out = stripped
    if not out:
        return ""
    if _LEADING_TOOL_RE.match(out):
        return ""
    return out


def redact(text):
    return SECRET_RE.sub("[redacted]", text)


def build_record(data):
    text = owner_input_text(data.get("prompt") or "")
    if not text:
        return None
    return {
        "source": "operator-session",
        "ts": int(time.time() * 1000),
        "session": data.get("session_id", ""),
        "cwd": data.get("cwd", ""),
        "text": redact(text),
    }


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    rec = build_record(data)
    if rec is None:
        return
    d = os.path.join(root, "human-input")
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, time.strftime("%Y-%m") + ".ndjson"), "a") as f:
        f.write(json.dumps(rec) + "\n")


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
