#!/usr/bin/env python3
"""One-time backfill of the Scope Creep human-input history (work-020, ADR-010).

The live UserPromptSubmit hook only captures prompts going forward. This tool
reconstructs the Owner's *earlier* terminal inputs — back to the very first
ideation — from a Claude Code session transcript, and emits them as
operator-session NDJSON into human-input/, so the Human-Input Log shows the full
history rather than starting the day the hook was installed.

It is intentionally conservative about what counts as a genuine human input:
  - drops tool_result turns, task-notifications, interrupt markers, and any
    compaction-summary turn (all share the "user" role but are not the Owner);
  - strips injected <system-reminder>/<command-*> wrappers;
  - unwraps a slash-command expansion to just the argument the Owner typed;
  - redacts obvious secrets (same guard as the live hook);
  - de-dupes by (ts, text) so re-running never double-writes, and appends
    alongside live captures rather than clobbering them.

Reads only from the transcript; the only writes are the NDJSON files.

Usage:
  backfill-human-input.py <transcript.jsonl> <session-cwd> <out-dir> [--write]

Without --write it is a dry run: it prints a summary + one-line preview of every
input it would emit, so the result can be eyeballed before anything is written.
"""
import sys
import os
import re
import json
from datetime import datetime, timezone


def parse_args(argv):
    if len(argv) < 4:
        sys.exit(__doc__)
    return argv[1], argv[2], argv[3], ("--write" in argv[4:])


SECRET = re.compile(
    r"(sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})"
)
WRAPPERS = [
    re.compile(r"<system-reminder>.*?</system-reminder>", re.S),
    re.compile(r"<command-name>.*?</command-name>", re.S),
    re.compile(r"<command-message>.*?</command-message>", re.S),
    re.compile(r"<command-args>.*?</command-args>", re.S),
    re.compile(r"<local-command-stdout>.*?</local-command-stdout>", re.S),
    re.compile(r"<ide_selection>.*?</ide_selection>", re.S),
    re.compile(r"<ide_opened_file>.*?</ide_opened_file>", re.S),
]
# Greedy to the final quote so a nested quote in the argument isn't truncated;
# the search is scoped to the "## User Request" tail before this is applied.
USER_SAID = re.compile(r'The user said:\s*"(.*)"', re.S)


def unwrap_slash_command(txt):
    """A slash-command expansion is an assistant-directed template, not the Owner's
    words. If it embeds the typed argument, return just that; if it's a bare
    template, return None (drop it). Non-command text passes through unchanged."""
    t = txt.lstrip()
    looks_like_command = t.startswith("# ") and (
        "You are helping the user" in txt or "## User Request" in txt
    )
    if not looks_like_command:
        return txt
    tail = txt[txt.find("## User Request"):] if "## User Request" in txt else txt
    m = USER_SAID.search(tail)
    if m and m.group(1).strip():
        return m.group(1).strip()
    return None


def clean(txt):
    for w in WRAPPERS:
        txt = w.sub("", txt)
    return SECRET.sub("[redacted]", txt).strip()


def is_noise(txt):
    t = txt.strip()
    if not t:
        return True
    if "SYSTEM NOTIFICATION - NOT USER INPUT" in t or t.startswith("<task-notification>"):
        return True
    if t.startswith("This session is being continued from a previous conversation"):
        return True
    if re.fullmatch(r"\[Request interrupted by user[^\]]*\]", t):
        return True
    return False


def message_text(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        if all(isinstance(b, dict) and b.get("type") == "tool_result" for b in c):
            return None
        return "\n".join(
            b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"
        )
    return None


def extract(src, cwd):
    session = os.path.basename(src).split(".")[0]
    records = []
    with open(src) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                o = json.loads(line)
            except json.JSONDecodeError:
                continue
            if o.get("type") != "user" or o.get("isSidechain"):
                continue
            msg = o.get("message", {})
            if msg.get("role") != "user":
                continue
            txt = message_text(msg)
            if not txt or is_noise(txt):
                continue
            unwrapped = unwrap_slash_command(txt)
            if unwrapped is None:
                continue
            cleaned = clean(unwrapped)
            ts_iso = o.get("timestamp")
            if not cleaned or not ts_iso:
                continue
            ms = int(
                datetime.strptime(ts_iso, "%Y-%m-%dT%H:%M:%S.%fZ")
                .replace(tzinfo=timezone.utc)
                .timestamp()
                * 1000
            )
            records.append({
                "source": "operator-session",
                "ts": ms,
                "session": session,
                "cwd": cwd,
                "text": cleaned,
                "backfill": True,
            })
    records.sort(key=lambda r: r["ts"])
    return records


def iso(ms):
    return datetime.fromtimestamp(ms / 1000, tz=timezone.utc).strftime("%Y-%m-%d %H:%M")


def main():
    src, cwd, out, write = parse_args(sys.argv)
    records = extract(src, cwd)
    print(f"source:  {src}")
    print(f"inputs:  {len(records)} genuine human inputs")
    if records:
        print(f"range:   {iso(records[0]['ts'])} .. {iso(records[-1]['ts'])} UTC")
        print(f"redacted: {sum('[redacted]' in r['text'] for r in records)} record(s)")
    print("--- preview ---")
    for r in records:
        first = re.sub(r"\s+", " ", r["text"]).strip()
        print(f"  {iso(r['ts'])} | {len(r['text']):5d}c | {first[:92]}")
    if not write:
        print("\n(dry run — pass --write to emit NDJSON)")
        return
    os.makedirs(out, exist_ok=True)
    by_month = {}
    for r in records:
        by_month.setdefault(iso(r["ts"])[:7], []).append(r)
    for key, rs in by_month.items():
        path = os.path.join(out, f"{key}.ndjson")
        existing = []
        if os.path.exists(path):
            with open(path) as f:
                existing = [json.loads(x) for x in f if x.strip()]
        seen = {(e.get("ts"), e.get("text")) for e in existing}
        added = 0
        with open(path, "a") as f:
            for r in rs:
                if (r["ts"], r["text"]) in seen:
                    continue
                f.write(json.dumps(r) + "\n")
                added += 1
        print(f"wrote {added} record(s) -> {path} ({len(existing)} already present)")


if __name__ == "__main__":
    main()
