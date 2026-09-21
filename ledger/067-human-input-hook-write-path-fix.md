---
name: ledger-067-human-input-hook-write-path-fix
description: Core-hook change record (INVARIANTS §8) — the Owner applied the one-line write-path convergence fix to .claude/hooks/log-human-input.sh (work-095), the twin of the log-activity.sh fix (ledger-057). Worktree-rooted sessions now log human input into the SCOPE_CREEP_HOME main checkout the Console reads, instead of the worktree dir. Owner-authored (the .claude/** gate surface an agent may not write); committed by the assistant onto PR #93 as mechanical propagation.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-21
---

# Ledger 067 — human-input hook write-path fix (core-hook change)

**Date:** 2026-09-21 · **Ticket:** [[work-095]] · **PR:** #93 · **Twin:**
[[ledger-057-transparent-delegation-visibility-fix]] (the activity-log fix this mirrors).

## Change
Per [[invariants]] §8, this records a change to a **core `.claude/` hook**. The Owner applied a
one-line write-path convergence to `.claude/hooks/log-human-input.sh`. After the existing
`ROOT="$(cd … )"` line:

```sh
ROOT="${SCOPE_CREEP_HOME:-${ROOT%%/.claude/worktrees/*}}"
```

Byte-identical to the line already at `log-activity.sh:13`. It makes the human-input hook write to
the **same directory the Console reads** (`readHumanInput` → `SCOPE_CREEP_HOME`, [[adr-011]]): use
`SCOPE_CREEP_HOME` when set, else strip any `/.claude/worktrees/<name>` suffix so a worktree-rooted
session still lands in the one main checkout the Console tails.

## Why
`.claude/hooks/log-human-input.sh` derived `ROOT` from the hook's own location, so **worktree
sessions logged human input into the worktree dir** — invisible to the Console, which reads only the
main checkout ([[ledger-062-work-sweep-first-run]] surfaced this; whole checkpoint session's inputs
were captured but not shown). The org's loops and interactive sessions run in worktrees, so this was
the common case. Verified: `${ROOT%%/.claude/worktrees/*}` resolves a worktree path back to the main
checkout, and `SCOPE_CREEP_HOME` overrides when set.

## Provenance / governance
`.claude/**` is a **locked gate surface an agent may not author** ([[invariants]] §8, [[adr-023]]).
The **Owner authored** the edit by hand; the assistant only committed the identical bytes onto the
PR branch (mechanical propagation) and added this ledger note. The change is therefore
escalation-class under [[adr-022]] trigger (d) — PR #93 correctly **HOLDs** for the Owner's
`owner-approved` label + review as `@scope-creep-review`.

## Follow-through
This session's worktree inputs were **already backfilled** into the main
`human-input/2026-09.ndjson` (so the Console shows them now); this fix prevents recurrence. See
[[work-095]], [[work-020]], [[adr-010]], [[adr-011]], [[ledger-057-transparent-delegation-visibility-fix]].
