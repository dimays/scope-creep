---
name: ledger-057-transparent-delegation-visibility-fix
description: Records the triage and fix of the transparent-delegation visibility gap — the Console's Activity surface was permanently empty because the capture hook wrote to the session's own working copy (a worktree) while the Console reads the main checkout (SCOPE_CREEP_HOME). Documents the core-hook change itself (Owner-applied to .claude/hooks/log-activity.sh, out-of-band per the locked gate surface) for replayability, plus the PR-side landing (work/077 + a work/036 DONE-note correction). CTO-approved; work-036 stays done.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-07
---

# Ledger 057 — Transparent-delegation visibility fix (activity write path)

**Date:** 2026-09-07 · **Repo:** `dimays/scope-creep` · **Status:** **PR LANDED; core-hook change handed to Owner (owner-apply, pending).**

## The gap
The Console's Explore → Activity surface ([[work-037]], [[prd-transparent-delegation]]) was
permanently empty on localhost. The capture hook ([[work-036]]) fires and appends correctly —
but to **the session's own working copy**: `.claude/hooks/log-activity.sh` derives its write
dir relative to the hook script (`$CLAUDE_PROJECT_DIR/.claude/hooks/..`), so a **worktree**-
rooted session writes to `<checkout>/.claude/worktrees/<name>/activity/`. The Console reads
only the **main checkout** via `SCOPE_CREEP_HOME` (`readActivity`, mirroring the human-input
read path, [[adr-011]]). The org's loops (dev-cycle, ticket-cycle) and interactive sessions run
in worktrees, so their events landed where the Console never reads — and worktrees are
ephemeral, so the lines vanished. Verified 2026-09-07: zero `activity/*.ndjson` anywhere.

**Not** a gitignore/public-repo/deploy issue (the Console is run locally; the log stays local +
gitignored per [[adr-013]] §6). Purely write-path ≠ read-path.

## The core-hook change (recorded here for replayability, INVARIANTS §8)
`.claude/**` is on the **locked gate-enforcement surface** (`guard-writes.sh` +
`permissions.deny`, fail-closed) — an agent may not write it, and the rule is *the Owner
applies such changes directly*. So this change is **Owner-applied out-of-band**, and this entry
records it so the git history reflects that the core changed (a PR diff cannot).

In `.claude/hooks/log-activity.sh`, after the existing `ROOT=…` line:

```bash
# Converge on the exact dir the Console reads (readActivity → SCOPE_CREEP_HOME, ADR-011);
# fall back to stripping a worktree suffix so a worktree-rooted session still lands in the
# one checkout the Console tails. `%%` collapses even a nested worktree to the true checkout.
ROOT="${SCOPE_CREEP_HOME:-${ROOT%%/.claude/worktrees/*}}"
```

Full patch + apply/verify steps: `docs/owner-apply-activity-write-path.md`.

- **No [[adr-013]] amendment** (CTO-confirmed): reverses no decision — the log stays local,
  gitignored, in-session; it only corrects *which* local dir. A bug fix implementing ADR-013's
  intent, not a new decision.
- **Safe:** `activity/` is gitignored in the main checkout (`.gitignore:17`), so redirecting
  writes into the (non-ephemeral) checkout carries no accidental-commit risk.

## What landed in the PR (agent-mergeable, non-escalation)
- `work/077-activity-write-path-convergence.md` — the follow-up bug ticket (owner: cto).
- `work/036-delegation-event-capture.md` — DONE-note **correction**: capture is met and 036
  stays `done`; the earlier "the feed populates as hook-enabled sessions run in the
  control-plane dir" was over-broad; the visibility gap is carved to [[work-077]].
- `docs/owner-apply-activity-write-path.md` — the Owner-apply patch (this core change).
- this ledger entry.

Paths touched are `work/` + `docs/` + `ledger/` — **none escalation-class** ([[adr-022]]) — so
the PR was green on its own; landed on the Owner's explicit in-conversation approval ("If CTO
approves, please just push and merge") + the CTO's technical sign-off.

## Review
- **CTO:** APPROVE. Confirmed the root cause, the `SCOPE_CREEP_HOME`-preferred fix (worktree-
  strip with `%%` as fallback), no ADR amendment, and work-036 staying `done`. Recommended the
  env-anchor form (folded in) and that this ledger record the core-hook change (done here).
- **Author ≠ merger** honest caveat (carried from [[ledger-056-merge-068-feedback-at-scale]]):
  the harness runs under one shared GitHub identity (`dimays`), so the separation is an
  org-role one, not yet per-identity ([[adr-023]] pending).

## Update (2026-09-08) — verification found two more causes; backfill shipped
While verifying live capture, two further facts surfaced (recorded here for replayability):
- **Wrong hook matcher (primary cause in the desktop app).** `settings.json` matches
  `PreToolUse: "Task"`, but the Claude Desktop / Code app names the spawn tool **`Agent`** (CLI
  uses `Task`). Across 10 scope-creep* transcripts: 65 `Agent` spawns, 0 `Task` — so the hook
  never fired here. Second Owner-applied core change: matcher → `"Task|Agent"`. And both hook
  files must be **committed** (not just working-tree-edited) to reach git worktrees, where the
  loops run. Full instructions folded into `docs/owner-apply-activity-write-path.md`.
- **The first owner-apply edit did not persist** — no `log-activity.sh` on disk carried the
  patch at verification time; it must be re-applied. Live capture is therefore still pending the
  Owner re-applying + committing both `.claude/**` changes.
- **Historical backfill shipped (independent of the hook).** `scripts/backfill-activity.py`
  reconstructed **63** past spawns from session transcripts (matches `Agent`+`Task`, live schema
  + `backfill:true`, idempotent) into `activity/2026-09.ndjson` at `SCOPE_CREEP_HOME` — so the
  Console's Activity surface renders the real org history now, including the 2026-09-06
  four-themes round the [[prd-transparent-delegation]] success signal was written around.

## Residual (honest)
- Still captures only **in-session `Task` spawns** — blind to a separate `claude` terminal, a
  cloud routine, or an SDK process (same limitation human-input carries; backfill is the net).
- A session in an **unrelated clone** with no `SCOPE_CREEP_HOME` exported still writes to that
  clone. The env-preference covers the case where it *is* exported; the worktree-strip covers
  worktrees under this checkout.
- The core-hook change is **not live until the Owner applies it** and starts a **new** session
  (hooks load at session start). Until then, Activity stays honest-empty.
