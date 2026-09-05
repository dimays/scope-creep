#!/usr/bin/env python3
"""UserPromptSubmit capture (work-020, ADR-010).

Reads the hook JSON on stdin ({prompt, cwd, session_id}) and appends one NDJSON
line to the LOCAL, gitignored human-input/YYYY-MM.ndjson under ROOT (argv[1]).
Redacts obvious secrets first. Prints nothing (stdout would be injected into the
prompt). Never raises to the caller — a capture failure must never block a prompt.
"""
import sys, json, os, time, re

root = sys.argv[1] if len(sys.argv) > 1 else "."
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

prompt = data.get("prompt") or ""
# Redact obvious secrets so a pasted key never lands in the log (content is not guaranteed clean).
prompt = re.sub(
    r"(sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})",
    "[redacted]",
    prompt,
)
d = os.path.join(root, "human-input")
os.makedirs(d, exist_ok=True)
rec = {
    "source": "operator-session",
    "ts": int(time.time() * 1000),
    "session": data.get("session_id", ""),
    "cwd": data.get("cwd", ""),
    "text": prompt,
}
with open(os.path.join(d, time.strftime("%Y-%m") + ".ndjson"), "a") as f:
    f.write(json.dumps(rec) + "\n")
