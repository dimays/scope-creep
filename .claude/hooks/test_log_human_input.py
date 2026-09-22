#!/usr/bin/env python3
"""Positive guard for the human-input capture classifier (recurrence guard, ledger)."""
import importlib.util
import os
import sys

HOOK = os.path.join(os.path.dirname(__file__), "log-human-input.py")
spec = importlib.util.spec_from_file_location("log_human_input", HOOK)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
oit, br = m.owner_input_text, m.build_record


def check(name, cond):
    if not cond:
        print("FAIL:", name)
        sys.exit(1)
    print("ok:", name)


check("plain owner text kept", oit("  scrap light mode  ") == "scrap light mode")
check(
    "owner text with quoted tag mid-sentence kept",
    oit("why do <task-notification> lines show as mine?")
    == "why do <task-notification> lines show as mine?",
)
check("owner text mentioning bash in prose kept", oit("run the bash-input check first") == "run the bash-input check first")

check(
    "leading system-reminder stripped",
    oit("<system-reminder>hi</system-reminder>\n\nKick off executions.") == "Kick off executions.",
)
check(
    "stacked wrappers stripped",
    oit("<system-reminder>a</system-reminder>\n<ci-monitor-event>b</ci-monitor-event>\nreal directive")
    == "real directive",
)
check("bare task-notification dropped", oit("<task-notification><task-id>x</task-id></task-notification>") == "")

check(
    "bash bang-command dropped",
    oit("<bash-input>gh pr merge 96 --squash</bash-input><bash-stdout>done</bash-stdout>") == "",
)
check(
    "curl bang-command dropped",
    oit("<bash-input>curl -s https://x/health</bash-input><bash-stdout>ok</bash-stdout>") == "",
)
check("slash-command dropped", oit("<command-name>/review</command-name><command-args>PR 98</command-args>") == "")
check("local-command-stdout dropped", oit("<local-command-stdout>done</local-command-stdout>") == "")
check(
    "tool block behind a reminder dropped",
    oit("<system-reminder>fyi</system-reminder>\n<bash-input>gh pr view 99</bash-input>") == "",
)

check("build_record None for injected", br({"prompt": "<task-notification>x</task-notification>"}) is None)
_r = br({"prompt": "ship it", "session_id": "s1", "cwd": "/c"})
check("build_record dict for genuine", _r is not None and _r["text"] == "ship it" and _r["source"] == "operator-session")
check("secret redaction", br({"prompt": "key ghp_ABCDEFGHIJKLMNOPQRSTUVWX"})["text"] == "key [redacted]")

print("\nALL PASS")
