#!/usr/bin/env python3
"""One-time backfill of the Scope Creep delegation-activity history (work-036/077).

The live PreToolUse capture hook (`.claude/hooks/log-activity.py`) only records
sub-agent spawns going forward — and only in sessions whose spawn tool matches its
hook matcher. This tool reconstructs the *earlier* spawns from Claude Code session
transcripts and emits them as `activity/YYYY-MM.ndjson`, so the Console's Activity
surface (work-037) shows the real delegation history instead of starting empty.

It mirrors `backfill-human-input.py`:
  - reconstructs from the transcript only; the only writes are the NDJSON files;
  - matches BOTH spawn tool names — `Agent` (Claude Desktop / Code app) and `Task`
    (Claude Code CLI) — since the delegation tool differs by harness;
  - emits exactly the live record shape { ts, actor, type:"spawn", summary,
    sessionId, threadId? } plus `backfill:true` (honest marker), so the Console
    projects backfilled and live events identically;
  - redacts obvious secrets (same guard as the live hook);
  - de-dupes by (sessionId, ts, actor, summary) so re-running never double-writes,
    and appends alongside live captures rather than clobbering them.

Attribution matches the live hook's v1: `actor` is the sub-agent spun up (the field
mechanically present in the payload); the delegating parent is not cleanly knowable.

Usage:
  backfill-activity.py <out-dir> [--write] [transcript.jsonl ...]

With no explicit transcripts it auto-discovers every scope-creep* session under
~/.claude/projects/. Without --write it is a dry run: prints a summary + one-line
preview of every event it would emit, so it can be eyeballed before anything lands.
"""
import sys
import os
import re
import glob
import json
from collections import Counter
from datetime import datetime, timezone

SPAWN_TOOLS = {"Agent", "Task"}  # desktop/Code app = Agent; CLI = Task
SECRET = re.compile(
    r"(sk-ant-[A-Za-z0-9_-]{8,}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})"
)
THREAD = re.compile(r"scope-creep-thread:(\d+)")


def discover():
    pat = os.path.expanduser("~/.claude/projects/*scope-creep*/*.jsonl")
    return sorted(glob.glob(pat))


def norm_ts(iso):
    """Transcript ts is ISO with ms ('...T03:17:55.581Z'); normalize to the live
    hook's second-precision '%Y-%m-%dT%H:%M:%SZ'. Returns None if unparseable."""
    if not iso:
        return None
    for fmt in ("%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ"):
        try:
            dt = datetime.strptime(iso, fmt).replace(tzinfo=timezone.utc)
            return dt.strftime("%Y-%m-%dT%H:%M:%SZ")
        except ValueError:
            continue
    return None


def extract(src):
    session_fallback = os.path.basename(src).split(".")[0]
    out = []
    with open(src) as f:
        for line in f:
            if '"tool_use"' not in line:
                continue
            try:
                o = json.loads(line)
            except json.JSONDecodeError:
                continue
            content = (o.get("message") or {}).get("content")
            if not isinstance(content, list):
                continue
            ts = norm_ts(o.get("timestamp"))
            session = o.get("sessionId") or session_fallback
            for b in content:
                if not (isinstance(b, dict) and b.get("type") == "tool_use"):
                    continue
                if b.get("name") not in SPAWN_TOOLS:
                    continue
                inp = b.get("input") or {}
                actor = inp.get("subagent_type") or ""
                if not actor or not ts:
                    continue  # not an attributable spawn — mirror the live hook
                summary = SECRET.sub("[redacted]", (inp.get("description") or "").strip())
                rec = {
                    "ts": ts,
                    "actor": actor,
                    "type": "spawn",
                    "summary": summary,
                    "sessionId": session,
                    "backfill": True,
                }
                m = THREAD.search(inp.get("prompt") or "")
                if m:
                    rec["threadId"] = int(m.group(1))
                out.append(rec)
    return out


def main():
    argv = sys.argv[1:]
    if not argv:
        sys.exit(__doc__)
    out_dir = argv[0]
    write = "--write" in argv[1:]
    explicit = [a for a in argv[1:] if a != "--write"]
    sources = explicit or discover()

    records = []
    per_src = []
    for src in sources:
        recs = extract(src)
        per_src.append((len(recs), os.path.basename(src)))
        records.extend(recs)
    records.sort(key=lambda r: (r["ts"], r["sessionId"]))

    actors = Counter(r["actor"] for r in records)
    print(f"transcripts scanned: {len(sources)}")
    print(f"spawn events found:  {len(records)}")
    if records:
        print(f"range:   {records[0]['ts']} .. {records[-1]['ts']}")
        print(f"redacted: {sum('[redacted]' in r['summary'] for r in records)} record(s)")
        print(f"threaded: {sum('threadId' in r for r in records)} tied to a thread")
        print("by actor: " + ", ".join(f"{a}={n}" for a, n in actors.most_common()))
    print("--- preview ---")
    for r in records:
        s = re.sub(r"\s+", " ", r["summary"]).strip()
        tag = f" thread:{r['threadId']}" if "threadId" in r else ""
        print(f"  {r['ts']} | {r['actor']:24s} | {s[:70]}{tag}")
    if not write:
        print("\n(dry run — pass --write to emit NDJSON)")
        return

    os.makedirs(out_dir, exist_ok=True)
    by_month = {}
    for r in records:
        by_month.setdefault(r["ts"][:7], []).append(r)
    for key, rs in sorted(by_month.items()):
        path = os.path.join(out_dir, f"{key}.ndjson")
        existing = []
        if os.path.exists(path):
            with open(path) as f:
                existing = [json.loads(x) for x in f if x.strip()]
        seen = {(e.get("sessionId"), e.get("ts"), e.get("actor"), e.get("summary")) for e in existing}
        added = 0
        with open(path, "a") as f:
            for r in rs:
                k = (r["sessionId"], r["ts"], r["actor"], r["summary"])
                if k in seen:
                    continue
                seen.add(k)
                f.write(json.dumps(r) + "\n")
                added += 1
        print(f"wrote {added} record(s) -> {path} ({len(existing)} already present)")


if __name__ == "__main__":
    main()
