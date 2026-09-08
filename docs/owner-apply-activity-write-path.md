# Owner-manual steps — make delegation-activity capture actually fire + reach the Console (work-077)

**Why this is Owner-applied, not in a PR diff:** the fixes edit `.claude/hooks/log-activity.sh`
and `.claude/settings.json`, both on the **locked gate-enforcement surface** (`.claude/**`).
`guard-writes.sh` + the `permissions.deny` rules block any agent file-writing tool there,
fail-closed, and the rule is explicit: *the Owner applies `.claude/**` changes directly; an
agent only proposes them here.* So these files are yours to apply by hand.

> **Status (verified 2026-09-08) — there are now TWO problems, and the first patch didn't take.**
> 1. **The earlier hook edit is not on disk.** Every `log-activity.sh` on the machine (main
>    checkout, all worktrees, the `scripts/owner-runbook/` copy) still has the old `ROOT=` line,
>    and `git status` shows no modification. Re-apply **Fix 1** below and save.
> 2. **The hook matcher is wrong for this harness (the real reason it's empty).** In the Claude
>    **Desktop / Code app**, the sub-agent spawn tool is named **`Agent`**, not `Task` — 65
>    real spawns across your sessions are all `Agent`, zero are `Task`. But `settings.json`
>    matches `"Task"` (the Claude Code *CLI* name), so the capture hook **never fires** in the
>    desktop app. Apply **Fix 2** below so it matches both.
> 3. **Commit them (see Fix 3)** — an uncommitted working-tree edit does not reach git
>    worktrees (each has its own checkout), and worktrees are where the org's loops run.
>
> Independently, the **historical** data is already populated: `scripts/backfill-activity.py`
> reconstructed 63 past spawns into `activity/2026-09.ndjson`, so the Console's Activity tab is
> no longer empty even before these hook fixes land. The fixes are what make *new* activity
> capture going forward.

## The bug (confirmed, not a guess)
The capture hook writes to **the session's own working copy** — `ROOT` is derived relative to
the hook script's location (`$CLAUDE_PROJECT_DIR/.claude/hooks/..`), so a **worktree**-rooted
session writes to `<checkout>/.claude/worktrees/<name>/activity/…`. The Console reads only the
**main checkout** (`SCOPE_CREEP_HOME = /Users/davidmays/code/scope-creep`). Since the org's
loops (dev-cycle, ticket-cycle) and most interactive sessions run in worktrees, their spawn
events land where the Console never looks — and worktrees are ephemeral, so those lines vanish.
That is why the Activity surface is empty on localhost. (Verified 2026-09-07: zero
`activity/*.ndjson` exist anywhere right now; this session's hook `ROOT` resolves to the
worktree, not the checkout.)

This is **not** a gitignore/public-repo/deploy problem — the log stays local + gitignored, as
ADR-013 §6 intends. It is purely a write-path vs. read-path mismatch.

## Fix 1 — converge the write path (edit `.claude/hooks/log-activity.sh`)
After the existing `ROOT=…` line, strip a worktree suffix / prefer `SCOPE_CREEP_HOME`
so every scope-creep-rooted session appends to the one checkout the Console reads.

**Before (line 8):**
```bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
python3 "$ROOT/.claude/hooks/log-activity.py" "$ROOT" 2>/dev/null || true
```

**After:**
```bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# Converge on the exact dir the Console reads (readActivity → SCOPE_CREEP_HOME, ADR-011);
# fall back to stripping a worktree suffix so a worktree-rooted session still lands in the
# one checkout the Console tails. `%%` (longest match) collapses even a nested worktree
# straight to the true checkout.
ROOT="${SCOPE_CREEP_HOME:-${ROOT%%/.claude/worktrees/*}}"
python3 "$ROOT/.claude/hooks/log-activity.py" "$ROOT" 2>/dev/null || true
```

> **CTO-reviewed (2026-09-07).** Prefers `SCOPE_CREEP_HOME` because that is the read
> anchor the Console actually uses; the worktree-strip is the fallback when it's unset
> (which resolves to the same canonical checkout on this single-user box). `%%` over `%`
> guards a nested-worktree (loops-spawning-loops) edge case. Safe under INVARIANTS §5
> (single-user → one consistent `SCOPE_CREEP_HOME`).

`log-activity.py` already `os.makedirs(activity, exist_ok=True)`, so the checkout's `activity/`
is created on first write and stays gitignored — no accidental commit.

> **When it takes effect:** hooks load at **session start**. This takes effect in your **next**
> scope-creep session after you apply it; it does not alter a running session.

## Fix 2 — match the spawn tool this harness actually uses (edit `.claude/settings.json`)
In the `PreToolUse` array, the entry that wires `log-activity.sh` currently has
`"matcher": "Task"`. Change it to match both harness names:

```json
{ "matcher": "Task|Agent",
  "hooks": [ { "type": "command",
    "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/log-activity.sh\"" } ] }
```

`Task` = Claude Code CLI; `Agent` = Claude Desktop / Code app. Matching both means capture
fires wherever you work. (`log-activity.py` already reads `tool_input.subagent_type` /
`description` / `prompt`, which both tools provide — no Python change needed; verified against a
real `Agent` payload.)

## Fix 3 — commit both files so worktrees inherit them
`.claude/**` is **tracked** in git, and a git **worktree** has its own checkout — an uncommitted
working-tree edit in the main checkout does **not** reach worktree sessions, which is exactly
where the org's loops run. So after applying Fix 1 + Fix 2, commit them (you, by hand — an agent
cannot write `.claude/**`):

```bash
cd /Users/davidmays/code/scope-creep
git checkout -b owner/activity-hook-fix
git add .claude/hooks/log-activity.sh .claude/settings.json
git commit -m "activity capture: match Agent|Task, converge write path on SCOPE_CREEP_HOME (work-077)"
git push -u origin owner/activity-hook-fix
gh pr create --fill
```

`.claude/**` is escalation-class, so the PR's escalation-check will be red until **you** add the
`owner-approved` label (your hand-commit + label *is* the §I.4 approval); then merge. New
worktrees created after the merge inherit the fix. (Applying to your working tree alone is
enough for **main-checkout** sessions immediately; the commit is what covers worktrees.)

## How to verify after applying
1. In your **next** session (from the main checkout or any worktree), run one real delegation.
2. `cat /Users/davidmays/code/scope-creep/activity/$(date +%Y-%m).ndjson` — expect a
   `{"ts",…,"type":"spawn",…}` line, regardless of whether the session was worktree-rooted.
3. Open the Console's Explore → Activity tab (local) — the event renders.

## Residual (honest scope — unchanged from ADR-013)
- Still captures only **in-session `Task` spawns** — blind to a separate `claude` terminal, a
  cloud routine, or an SDK process. Same limitation `human-input` carries (ADR-011); backfill
  is the accepted safety net.
- A scope-creep session run from a **different clone** is now covered **iff** it exports the
  same `SCOPE_CREEP_HOME` the Console reads (the patch prefers it). If `SCOPE_CREEP_HOME` is
  unset, the worktree-strip fallback still lands worktree sessions in the parent checkout; a
  session in an unrelated clone with no env still writes to that clone (the same "work from
  the repo" discipline ADR-011 documents — backfill is the safety net).
