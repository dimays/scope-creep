---
id: work-090
title: Scope guard-writes / guard-gates hooks to the control-plane repo root (fix sibling-repo & home-dir false positives)
type: debt
status: proposed
priority: medium
owner: cto
spec: adr-022
created: 2026-09-21
updated: 2026-09-21
---
The control-plane gate hooks `.claude/hooks/guard-writes.sh` and `.claude/hooks/guard-gates.sh`
match by **basename / path-suffix / literal-command string**, not by the control-plane repo
root. So they fire on legitimate work that is *outside* this repo's gate surface, producing
false positives that either block real work or — worse — tempt an agent to route around the
gate (see [[work-091]]).

Two observed instances (2026-09-21):
1. **Home-dir memory write blocked.** A `Write` to the session memory store under
   `~/.claude/.../memory/` was blocked by `guard-writes` because the path *contains* `.claude/`
   — but that is the user's home memory dir, not this repo's `.claude/**` gate surface.
2. **Sibling-repo clone in scratch blocked / dodged.** A CTO session authoring the console
   escalation-check into a **separate `scope-creep-console` clone in the scratchpad** was
   blocked by `guard-writes` on `escalation-check.yml` / `escalation-check.sh` (basename match,
   regardless of repo), and `guard-gates` matched a literal `fly deploy` string inside a heredoc
   *comment*. Neither touched this repo's gate surface or ran any gated command.

**Fix:** scope the matchers to the control-plane repo root — the hooks should guard paths only
when the target resolves **inside this checkout's** gate surface (`charter/INVARIANTS.md`,
`.claude/**`, `standards/**`, the guard/escalation scripts, `.github/workflows/**`), and not
fire on identically-named files in other repos, in the scratchpad, or under `$HOME`. Preserve
fail-closed behavior for genuine in-repo gate edits and for worktrees under this checkout.

**Note — this edits the locked `.claude/**` gate surface**, so it ships as an Owner-applied
change via a `docs/owner-apply-*.md` patch (the [[ledger-057-transparent-delegation-visibility-fix]]
pattern), not a plain agent PR.

**Acceptance:** the hooks still block writes/commands against **this** repo's gate surface and
still fail-closed; they no longer false-positive on (a) `~/.claude/**` home paths, (b) a
sibling repo checked out in the scratchpad, or (c) literal gate-command strings appearing inside
comments; the two instances above are covered by a regression check. See [[adr-022]], [[work-091]].
