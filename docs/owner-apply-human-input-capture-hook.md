# Owner-apply: harden the Human-Input capture hook (stop internal/system prompts polluting the log)

**Status:** proposed — HOLDING for the Owner. This changes the **gate surface**
(`.claude/hooks/**`), which no agent may edit (guard-writes; INVARIANTS §I.2/§I.4,
§III). The Owner applies the files below directly, then verifies.

**Why this is a proposal, not a PR diff to `.claude/`:** the write-guard mechanically
blocks any agent file-write under `.claude/**` so an agent cannot neuter a gate or
widen its own permissions. The correct rail is exactly this: propose, Owner disposes.

---

## The regression (recurrence of work-095 / work-096, PR #93)

The Console's **Human-Input Log** must show **only genuine Owner-typed terminal
input** (see the human-input sync architecture: hook → local NDJSON → Console read via
`SCOPE_CREEP_HOME`). It was again showing internal/system content — verified in
`human-input/2026-09.ndjson`: entries tagged `operator-session` that are actually
`<task-notification>` blocks, `<bash-input>gh pr merge …</bash-input><bash-stdout>…`
bang-command I/O (the `gh`/`curl` noise), and `<system-reminder>` injections.

### Root cause (why it recurred)

`UserPromptSubmit` fires for **every** submitted prompt, and the harness/tooling
injects non-human content into that same stream — task-completion notifications,
system reminders, CI events, and (crucially) **bang-command / slash-command tool I/O
echoed as `<bash-input>…</bash-input><bash-stdout>…`**. The hook captured the **raw**
prompt, so all of it was logged as human input.

The prior fixes (work-095/096) corrected the write **path** (worktree → the dir the
Console reads). They never addressed content **classification**, so the moment a
session ran bang-commands / accrued notifications, the log re-polluted. **Re-patching
the write path again would not stop this.** The resilient fix is to classify at the
point of capture and log only the Owner's own prose.

---

## The resilient fix (two layers)

1. **Capture-side (this proposal, core):** the hook classifies and logs only genuine
   Owner text — strip leading harness-injected wrapper blocks, and **drop** any prompt
   that is empty after stripping or that begins with a tool/command block.
2. **Read-side (already shipped in the Console PR, periphery):**
   `app/lib/human-input.ts › operatorInputText` applies the **same** filter as
   defense-in-depth, so lines captured *before* this hook lands stop rendering too.

**Recurrence guard:** `test_log_human_input.py` (below) is a positive test that fails
loudly if indiscriminate capture is ever reintroduced. Wire it into `bun run
hooks:check` so it runs with the rest of the checks. (Verified locally: **ALL PASS**,
14 assertions.)

---

## Apply — 3 files

### 1. Replace `.claude/hooks/log-human-input.py`

```python
#!/usr/bin/env python3
"""UserPromptSubmit capture (work-020, ADR-010; resilience hardening — see ledger).

Appends ONE NDJSON line per *genuine Owner-typed* prompt to the LOCAL, gitignored
human-input/YYYY-MM.ndjson under ROOT (argv[1]).

ROOT-CAUSE of the recurring "system/internal prompts pollute the Human-Input Log"
bug (a recurrence of work-095/096, PR #93): UserPromptSubmit fires for EVERY
submitted prompt, and the harness/tooling injects non-human content into that same
stream — background-task notifications, system reminders, CI events, and (crucially)
bang-command / slash-command tool I/O echoed as `<bash-input>…</bash-input>
<bash-stdout>…`. The old hook captured the *raw* prompt, so all of it was logged as
"operator-session" human input. The console had only a downstream, incomplete
read-side filter; the prior fixes touched the write PATH, never content CLASSIFICATION,
so the pollution recurred.

RESILIENT FIX — classify at CAPTURE. We log ONLY the Owner's own prose:
  1. Strip harness-injected wrapper blocks from the front (they stack).
  2. DROP the line entirely when nothing human remains, or when what remains begins
     with a tool/command block (a bang-command, slash command, or local-command
     output that rode in on UserPromptSubmit).
The console read path (app/lib/human-input.ts `operatorInputText`) applies the SAME
filter as defense-in-depth, so lines captured before this fix also stop rendering.
`test_log_human_input.py` (run via `bun run hooks:check`) is the positive guard that
fails loudly if indiscriminate capture is ever reintroduced.

Contract preserved: prints NOTHING to stdout (stdout is injected into the prompt as
context); never raises to the caller (a capture failure must never block a prompt).
"""
from __future__ import annotations

import json
import os
import re
import sys
import time

# Harness-injected wrapper blocks that may PRECEDE a genuine Owner message. We strip
# these from the front (repeatedly — they stack) and keep whatever human text follows.
INJECTED_WRAPPER_TAGS = ("task-notification", "system-reminder", "ci-monitor-event")

# Tool/command-driven blocks. A prompt that BEGINS with one of these is a bang-command
# execution, a slash-command expansion, or other tool I/O echoed into the prompt stream
# — never Owner prose. Such a prompt is dropped wholesale. (These are what flooded the
# log with `gh`/`curl` command lines.)
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

# One leading `<tag …>…</tag>` wrapper block, any attributes, non-greedy body,
# case-insensitive. The \1 backreference pins the close to the same tag so an unrelated
# later block isn't swallowed.
_LEADING_WRAPPER_RE = re.compile(
    r"^\s*<(" + "|".join(INJECTED_WRAPPER_TAGS) + r")\b[^>]*>[\s\S]*?</\1>\s*",
    re.IGNORECASE,
)
# The OPENING of a tool/command block at the front — its mere presence marks the whole
# prompt as tool-driven, so we drop it rather than partially salvage it.
_LEADING_TOOL_RE = re.compile(
    r"^\s*<(" + "|".join(TOOL_COMMAND_TAGS) + r")\b",
    re.IGNORECASE,
)


def owner_input_text(prompt):
    """Return the Owner's own typed text, or "" if the prompt is not genuine human input.

    1. Strip leading harness-injected wrapper blocks (they stack).
    2. Return "" if nothing remains, or if what remains begins with a tool/command block.
    """
    out = (prompt or "").strip()
    while out:
        stripped = _LEADING_WRAPPER_RE.sub("", out, count=1).strip()
        if stripped == out:
            break  # no leading wrapper block left
        out = stripped
    if not out:
        return ""
    if _LEADING_TOOL_RE.match(out):
        return ""  # tool/command I/O, not Owner prose
    return out


def redact(text):
    """Mask obvious secrets so a pasted key never lands in the log."""
    return SECRET_RE.sub("[redacted]", text)


def build_record(data):
    """Build the NDJSON record for a hook payload, or None if it is not Owner input."""
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
        return  # injected / tool-driven / empty — not human input
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
```

> **Note on subagent / scheduled prompts.** The `UserPromptSubmit` payload
> (`{prompt, cwd, session_id}`) exposes no reliable "is this a subagent / scheduled
> run vs. the Owner" discriminator, and the project-scoped hook already fires only in
> scope-creep-rooted sessions. The observed pollution is entirely tool/command and
> harness-injected **content**, which the content classifier above excludes
> categorically. If a future harness version adds a `source`/`agent` field to the
> payload, add a first check that drops non-owner sources — the tag filter stands as
> the durable floor.

### 2. Add `.claude/hooks/test_log_human_input.py` (the recurrence guard)

```python
#!/usr/bin/env python3
"""Positive guard for the human-input capture classifier (recurrence guard, ledger).

Fails loudly if indiscriminate capture is reintroduced. Run: python3 test_log_human_input.py
(or `bun run hooks:check`). No third-party deps."""
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


# genuine owner prose is kept (never over-filter real input)
check("plain owner text kept", oit("  scrap light mode  ") == "scrap light mode")
check(
    "owner text with quoted tag mid-sentence kept",
    oit("why do <task-notification> lines show as mine?")
    == "why do <task-notification> lines show as mine?",
)
check("owner text mentioning bash in prose kept", oit("run the bash-input check first") == "run the bash-input check first")

# harness wrappers stripped / dropped
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

# tool/command I/O dropped (the gh/curl flood)
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

# build_record: None for injected, dict for genuine; secret redaction preserved
check("build_record None for injected", br({"prompt": "<task-notification>x</task-notification>"}) is None)
_r = br({"prompt": "ship it", "session_id": "s1", "cwd": "/c"})
check("build_record dict for genuine", _r is not None and _r["text"] == "ship it" and _r["source"] == "operator-session")
check("secret redaction", br({"prompt": "key ghp_ABCDEFGHIJKLMNOPQRSTUVWX"})["text"] == "key [redacted]")

print("\nALL PASS")
```

### 3. Wire the guard into `package.json` scripts

```json
"hooks:check": "python3 .claude/hooks/test_log_human_input.py"
```

---

## Verify (after applying)

```bash
cd /Users/davidmays/code/scope-creep
bun run hooks:check          # → ALL PASS

# End-to-end: injected/tool content is not captured; real text is.
printf '%s' '{"prompt":"<bash-input>gh pr view 1</bash-input><bash-stdout>x</bash-stdout>","session_id":"t","cwd":"/tmp"}' \
  | python3 .claude/hooks/log-human-input.py /tmp/hi-test    # writes nothing
printf '%s' '{"prompt":"hello owner","session_id":"t","cwd":"/tmp"}' \
  | python3 .claude/hooks/log-human-input.py /tmp/hi-test    # writes one line
cat /tmp/hi-test/human-input/*.ndjson                        # → only "hello owner"
```

## Optional cleanup — the already-polluted log

The Console read-side filter (shipped in the console PR) already **hides** the
existing pollution from the rendered log, so no data-loss-risky rewrite is required.
If you want the on-disk NDJSON tidied too, filter it through the same classifier
(dry-run first; `human-input/` is local-only and gitignored, so this never touches
git history):

```bash
python3 - <<'PY'
import json, glob, importlib.util
spec = importlib.util.spec_from_file_location("h", ".claude/hooks/log-human-input.py")
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
for f in glob.glob("human-input/*.ndjson"):
    kept = []
    for line in open(f):
        line = line.strip()
        if not line: continue
        try: rec = json.loads(line)
        except Exception: continue
        if m.owner_input_text(rec.get("text", "")): kept.append(line)
    print(f, "→ keep", len(kept), "lines")   # add open(f,"w").write("\n".join(kept)+"\n") to write
PY
```

---

*Traceability:* human-input sync architecture · prd-console-operations · work-095 /
work-096 (PR #93) · ADR-010/011. Guard test proves the classifier; the Console PR
carries the read-side twin + tests.
