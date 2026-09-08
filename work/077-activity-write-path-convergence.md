---
id: work-077
title: Activity write path must converge on the Console's read path
type: bug
status: proposed
priority: high
owner: cto
spec: prd-transparent-delegation
created: 2026-09-07
updated: 2026-09-07
---
The [[prd-transparent-delegation]] surface ([[work-037]]) is permanently empty on localhost —
not because of gitignore/deploy, but because [[work-036]]'s capture hook writes to the
**session's own working copy** while the Console reads only the **main checkout**.

## Update (2026-09-08) — two more causes found while verifying
1. **Wrong hook matcher (the primary cause in the desktop app).** `settings.json` matches
   `PreToolUse: "Task"`, but in the Claude Desktop / Code app the spawn tool is named **`Agent`**
   (the CLI uses `Task`). Across 10 scope-creep* session transcripts: **65 `Agent` spawns, 0
   `Task`.** So the capture hook never fired in the desktop app at all — independent of the
   write-path bug below. Fix: matcher → `"Task|Agent"`. (`log-activity.py` needs no change;
   verified against a real `Agent` payload.)
2. **Worktree propagation.** `.claude/**` is tracked; a git worktree has its own checkout, so an
   uncommitted owner-apply edit never reaches worktree sessions (where the loops run). The hook
   fixes must be **committed**, not just applied to the working tree.
3. **Historical backfill shipped.** `scripts/backfill-activity.py` reconstructs past spawns from
   session transcripts (matches `Agent`+`Task`, live schema + `backfill:true`, idempotent) and
   populated 63 events into the checkout's `activity/2026-09.ndjson` — the Console's Activity
   surface is no longer empty even before the hook fixes land. Going-forward capture still needs
   fixes 1+2 committed (see `docs/owner-apply-activity-write-path.md`).

## Root cause (confirmed 2026-09-07)
- `.claude/hooks/log-activity.sh` sets `ROOT` relative to the hook script's own path
  (`$CLAUDE_PROJECT_DIR/.claude/hooks/..`). A **worktree**-rooted session therefore writes to
  `<checkout>/.claude/worktrees/<name>/activity/…`.
- The Console tails only `SCOPE_CREEP_HOME` = the main checkout (`readActivity()`, mirroring
  the `human-input` read path, [[adr-011]]).
- The org's loops (dev-cycle, ticket-cycle) and most interactive sessions run in worktrees, so
  their spawn events land where the Console never reads — and worktrees are ephemeral, so the
  lines vanish. Net: zero `activity/*.ndjson` exist anywhere; the surface is honest-empty for a
  mechanical reason, not because delegation isn't happening.
- **Not** a gitignore/public-repo/deploy issue. The log stays local + gitignored per
  [[adr-013]] §6; this is purely write-path ≠ read-path.

## Fix
In `log-activity.sh`, converge the write dir onto the Console's read anchor:
`ROOT="${SCOPE_CREEP_HOME:-${ROOT%%/.claude/worktrees/*}}"` — prefer the exact dir the Console
reads (`SCOPE_CREEP_HOME`, [[adr-011]]); fall back to stripping a worktree suffix (`%%` handles
nested worktrees) so a worktree-rooted session still lands in the one checkout the Console
tails. No new infra, no `.gitignore` change, no Console change, no public exposure.

- **GATED:** touches `.claude/**` — on the locked gate-enforcement surface (`guard-writes.sh`
  + `permissions.deny`), so it is **Owner-applied**, not agent-merged. The exact patch is in
  `docs/owner-apply-activity-write-path.md`.
- **No ADR amendment** (CTO-confirmed): reverses no [[adr-013]] decision — the log stays local,
  gitignored, in-session; it only corrects *which* local dir. Rides as the owner-apply patch +
  a [[ledger]] note that records the core-hook change itself (replayability, INVARIANTS §8).

**Acceptance:** after the patch, a real delegation from a worktree-rooted session appends a
well-formed line to the checkout's `activity/*.ndjson` (`SCOPE_CREEP_HOME`), and the Console's
Explore → Activity tab renders it. The surface stays honest-empty when nothing has been
captured, and still never fabricates activity. Residual scope limits (in-session `Task` spawns
only; a session in an unrelated clone with no `SCOPE_CREEP_HOME`) documented, not silently
implied.
