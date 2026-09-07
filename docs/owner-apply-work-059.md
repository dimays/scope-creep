# Owner-manual steps — lock the gate surface + identity separation (work-059)

work-059 closes CRO fix #3 for ADR-022. Most of it ships **in this PR** (a
PreToolUse block on file-writing tools, and the permission grants brought in-band
as tracked `permissions.deny` rules). Three pieces **cannot** ship in a PR diff and
must be applied by the Owner. This file is the checklist.

---

## What shipped in the PR (no Owner action needed to land, but review it)

1. **`.claude/hooks/guard-writes.sh`** — a new PreToolUse hook that BLOCKS
   Edit/Write/MultiEdit/NotebookEdit to the gate-enforcement surface
   (`charter/INVARIANTS.md`, `.claude/**`, `.github/workflows/**`, and the
   `scripts/escalation-check.sh` / `scripts/guard-*.sh` gate logic). Closes the
   hole where `guard-gates.sh` only ever inspected Bash.
2. **`.claude/settings.json`** — wires that hook (`Edit|Write|MultiEdit|NotebookEdit`
   matcher) and adds a tracked **`permissions.deny`** block for the same paths.
   This is the **in-band** fix: a permission change on the gate surface now shows up
   in a PR diff and is visible to the escalation-check, instead of hiding in the
   gitignored `settings.local.json`.

> **When it takes effect:** hooks and permissions load at **session start**. Both
> changes take effect on your **next session** after this PR merges. They do not
> alter the currently running session.

---

## Owner-manual step 1 — clean up the gitignored local grants

`.claude/settings.local.json` is **gitignored** (`.gitignore`) and per-checkout, so
it cannot appear in a PR diff. It currently holds the exact grants work-059 is
retiring — gate-surface writes that let an agent neuter a hook or widen its own
permissions:

```json
{
  "permissions": {
    "allow": [
      "Edit(.claude/settings.local.json)",
      "Write(.claude/settings.local.json)",
      "Write(.claude/hooks/**)"
    ]
  }
}
```

Once this PR is in, the tracked `permissions.deny` in `settings.json` **overrides**
these allows (deny beats allow) and the `guard-writes.sh` hook blocks them anyway —
so they are already dead. Remove them so the local file states nothing misleading.
Edit `.claude/settings.local.json` to read **exactly**:

```json
{
  "permissions": {
    "allow": []
  }
}
```

Keep `settings.local.json` for **machine-local-only** grants (a path that differs
per checkout, a personal convenience allow) — never for anything that touches the
gate surface. Durable, safe grants belong in the tracked `settings.json` so they
are PR-reviewed and escalation-check-visible.

> You must edit `settings.local.json` in your **own editor**, not via an agent's
> Edit tool — the new deny rules + `guard-writes.sh` will (correctly) block an agent
> from touching it.

---

## Owner-manual step 2 — provision a restricted agent identity (ADR-023)

This is the real fix for the **forgeable marker**. Today all agents act through your
ONE GitHub identity, so an agent with `gh` can add the `owner-approved` label itself
and clear its own escalation hold. The marker is not un-forgeable until a **separate,
restricted agent identity** exists. See `standards/adr/023-restricted-agent-identity.md`
for the full design. The Owner-only setup:

1. **Create a machine/bot identity** — a dedicated GitHub App (preferred) installed
   on the Scope-Creep repos, or a fine-grained PAT on a bot account. This is the
   credential **agents** authenticate with for all `gh`/git operations.
2. **Scope it so it CANNOT:**
   - add/remove the `owner-approved` label (no label-write, or govern the label via
     step 4);
   - approve pull-request reviews that count toward a required approval;
   - merge escalation-class PRs (enforced with branch protection, work-060);
   - push to protected branches or change branch-protection settings.
3. **Keep your personal token human-only** — never hand it to an agent. Agents use
   the restricted credential; you use your token.
4. **Make the approval an act only your principal can perform** (pick one, they
   compose):
   - a **required review from a team the bot identity is NOT in** (CODEOWNERS +
     "require review from Code Owners" branch protection); or
   - a **protected `owner-approval` GitHub Environment** with you as the sole
     required reviewer, gating the escalation-class merge job.
5. **Then** the escalation-check can verify the **approver's identity**, not just a
   label's presence — and the marker becomes un-forgeable.

**Depends on work-060 (branch protection).** Without it, a "can't merge" scope is
unenforceable.

---

## Residual (honest, until step 2 is done)

Until the restricted identity is provisioned, the `owner-approved` marker remains
**agent-forgeable** under the shared identity. The work-057/058/059 rails make
escalation **mechanical, auditable, and fail-closed against accidental/unreviewed
merges** — they are **not** un-spoofable against a **deliberate** agent. Do not
represent the marker as un-forgeable, and do not activate ADR-022 on the strength of
the marker alone.
