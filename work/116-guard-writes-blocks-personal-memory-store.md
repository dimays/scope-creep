---
id: work-116
title: Fix guard-writes.sh (and its settings.json twin) false-positive that blocks the personal cross-session memory store
type: bug
status: proposed
priority: medium
owner: cto
spec: adr-022
created: 2026-09-22
updated: 2026-09-22
---
**The gate hook that protects the project's `.claude/**` gate surface also blocks writes to the
Owner's personal Claude memory store, so agents cannot persist cross-session memory at all.**

## Symptom
Every attempt by an agent to Write a memory file under
`~/.claude/projects/<project-slug>/memory/` is BLOCKED. Observed 2026-09-22:

    PreToolUse:Write hook error: [bash "$CLAUDE_PROJECT_DIR/.claude/hooks/guard-writes.sh"]:
    BLOCKED by Scope Creep gate: edit/write to the gate surface (.claude/** ...)

## Impact
No cross-session continuity via memory. Each new session must re-derive context from the repo
(ledgers / tickets / ADRs) instead of loading durable, curated memories — the exact gap felt when
handing a long session off to a fresh one (e.g. the work-115 handoff).

## Root cause
`.claude/hooks/guard-writes.sh` (line ~75) blocks on the glob:

    .claude/*|*/.claude/*)   ->   block ".claude/** — the hooks and permission config"

The `*/.claude/*` arm matches ANY absolute path containing `/.claude/`. The personal memory
store lives under the Owner's HOME (`/Users/<user>/.claude/projects/<slug>/memory/...`), NOT under
the project repo (`$CLAUDE_PROJECT_DIR/.claude/...`). The normalization just above only strips the
`$CLAUDE_PROJECT_DIR` prefix and the isolated-worktree prefix; a home-dir `~/.claude/` path stays
absolute and is then caught by `*/.claude/*`. So the guard — meant to protect the PROJECT's gate
surface — also swallows the unrelated home memory dir. A parallel `permissions.deny` `.claude/**`
rule in `.claude/settings.json` (noted in the hook header, "defense in depth") may over-match the
same way and must be checked too.

## Recommendation
Add a NARROW carve-out for the personal memory store while keeping every real gate intact:

1. **guard-writes.sh** — before the `.claude/*` block, allow the memory subtree explicitly: a path
   matching `*/.claude/projects/*/memory/*` -> `exit 0` (permitted). Keep blocking:
   - the project's `.claude/**` (repo-relative `.claude/*` after normalization);
   - user-level gate/permission files: `~/.claude/settings.json`, `~/.claude/settings.local.json`,
     and any `~/.claude/hooks/**`. The carve-out MUST be only the `.../memory/` subtree — never all
     of `~/.claude/**`, which would let an agent widen its own global permissions.
2. **.claude/settings.json** — audit the parallel `permissions.deny` `.claude/**` rule for the same
   over-match; apply the equivalent carve-out, or confirm it does not catch the absolute home path.
3. **Guard test** — add a positive test (mirror `.claude/hooks/test_log_human_input.py`, wire into
   `hooks:check`) asserting: a project `.claude/hooks/x` path BLOCKED; `~/.claude/settings.json`
   BLOCKED; `~/.claude/projects/<slug>/memory/x.md` ALLOWED.

## Gate class — Owner-applied
This modifies the gate-enforcement surface (`.claude/hooks/guard-writes.sh` + `.claude/settings.json`),
which no agent may write (guard-writes blocks it — correctly). Ship it as a `docs/owner-apply-*.md`
proposal; the Owner applies the change by hand, then runs `hooks:check`. Do NOT weaken the gate:
the only behavior change is permitting writes to the personal memory subtree; every existing
protection must still hold.

## Acceptance
- An agent Write to `~/.claude/projects/<slug>/memory/foo.md` succeeds.
- Writes to the project's `.claude/**`, `.github/workflows/**`, the guard/escalation scripts,
  `charter/INVARIANTS.md`, and user-level `~/.claude/settings*.json` are STILL blocked.
- A guard test proves all of the above and is wired into `hooks:check`.
- Delivered as an owner-apply proposal (agent proposes; Owner applies); recorded in the ledger.
