# Owner-manual step — converge the activity write path onto the Console's read path (work-077)

**Why this is Owner-applied, not in a PR diff:** the fix edits `.claude/hooks/log-activity.sh`,
which is on the **locked gate-enforcement surface** (`.claude/**`). `guard-writes.sh` + the
`permissions.deny` rules block any agent file-writing tool there, fail-closed, and the rule is
explicit: *the Owner applies `.claude/**` changes directly; an agent only proposes them here.*
So this one file is yours to apply by hand. The rest of work-077 (the follow-up ticket, the
work-036 DONE-note correction) ships in the PR.

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

## The fix
Edit `.claude/hooks/log-activity.sh`. After the existing `ROOT=…` line, strip a worktree suffix
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
