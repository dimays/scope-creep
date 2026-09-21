---
id: work-095
title: Converge log-human-input.sh write path on SCOPE_CREEP_HOME (worktree sessions bypass the Console)
type: bug
status: done
priority: medium
owner: cto
spec: prd-human-input-log
created: 2026-09-21
updated: 2026-09-21
---
> **Done — merged via PR #93** (2026-09-21). The Owner-authored one-line write-path fix landed in
> `.claude/hooks/log-human-input.sh` (recorded in [[ledger-067-human-input-hook-write-path-fix]]);
> this session's worktree inputs were backfilled into the main log. Worktree-rooted sessions now log
> human input to the `SCOPE_CREEP_HOME` main checkout the Console reads.
The Human-Input Log ([[adr-010]], [[work-020]]) is empty in the Console for any session run from a
**git worktree** — including this whole checkpoint session. Root cause is the exact write-path ≠
read-path divergence [[ledger-057-transparent-delegation-visibility-fix]] fixed for the **activity**
log, but the fix was **never applied to the human-input hook**.

`.claude/hooks/log-human-input.sh` derives its write dir from the hook script's own location:

```sh
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
```

In a worktree session the hook lives at `<checkout>/.claude/worktrees/<name>/.claude/hooks/…`, so
`ROOT` = the **worktree**, and inputs land in `<worktree>/human-input/…ndjson`. The Console reads
only the **main checkout** via `SCOPE_CREEP_HOME` (`readHumanInput`, [[adr-011]]) — so worktree-
session inputs are captured but never surfaced. The org's loops and interactive sessions run in
worktrees, so this is the common case, not the edge case.

**Fix (Owner-applied — `.claude/**` is the locked gate surface an agent may not write):** mirror
the [[ledger-057-transparent-delegation-visibility-fix]] activity-log fix. After the `ROOT=…` line
in `.claude/hooks/log-human-input.sh`, add:

```sh
# Converge on the dir the Console reads (readHumanInput → SCOPE_CREEP_HOME, ADR-011); fall back to
# stripping a worktree suffix so a worktree-rooted session still lands in the one checkout the
# Console tails. Twin of the log-activity.sh fix (ledger-057).
ROOT="${SCOPE_CREEP_HOME:-${ROOT%%/.claude/worktrees/*}}"
```

`human-input/` is gitignored in the main checkout, so redirecting writes there carries no
accidental-commit risk (same as activity). Both hook files must be **committed** to reach worktrees.

**Backfill (already done this session):** the checkpoint session's inputs were merged from the
worktree ndjson into the main `human-input/2026-09.ndjson` (+81 entries), so the Console shows them
now; the hook fix prevents recurrence.

**Acceptance:** a human input typed in a worktree-rooted session appears in the Console's Human-Input
tab without a manual backfill; the fix is committed to both `.claude/hooks/log-human-input.sh` copies;
a [[ledger]] note records the core-hook change (per [[invariants]] §8, like [[ledger-057-transparent-delegation-visibility-fix]]).
See [[work-077]] (the activity twin), [[adr-010]], [[adr-011]].
