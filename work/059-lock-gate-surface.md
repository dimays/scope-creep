---
id: work-059
title: Block Edit/Write to the gate surface + bring permission grants in-band
type: feature
status: active
priority: high
owner: cto
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
CRO fix #3 for [[adr-022]]. Today the `guard-gates` hook only inspects Bash, so an agent
can neuter the hook or widen its own permissions with the Edit/Write tool, no prompt —
and the strongest grants live in a **gitignored** `settings.local.json` the review can
never see.

- Add an `Edit`/`Write` matcher (or extend the hook) blocking un-prompted writes to
  `.claude/**`, `charter/INVARIANTS.md`, and `guard-gates` itself.
- Bring the `settings.local.json` permission grants **in-band** (a tracked, PR-reviewed
  file) so escalation trigger (d) can actually see permission changes.

**Acceptance:** an agent cannot edit a gate file or widen a permission without a gate/
prompt; permission grants appear in PR diffs. Blocks [[adr-022]] activation. See [[adr-022]].

## Status — 2026-09-06 (active / partial; lands under Owner review, do NOT merge)

**Shipped in this PR (the two write-side rails — acceptance met):**
- **Block Edit/Write to the gate surface.** New PreToolUse hook
  `.claude/hooks/guard-writes.sh` blocks Edit/Write/MultiEdit/NotebookEdit to
  `charter/INVARIANTS.md`, `.claude/**`, `.github/workflows/**`, and the
  `scripts/escalation-check.sh` / `scripts/guard-*.sh` gate logic. Wired in
  `.claude/settings.json` (`Edit|Write|MultiEdit|NotebookEdit` matcher). Unit-tested:
  every gate-surface path blocks (exit 2); ordinary core-upgrade edits (standards,
  agents, loops, work, ledger, ADRs, non-guard scripts) pass. This is deliberately
  **narrow** — it guards the enforcement *mechanisms*, not all core content, so
  normal governed edits (including this very PR) still work.
- **Permission grants in-band.** `.claude/settings.json` now carries a tracked
  **`permissions.deny`** block for the same gate-surface paths (defense-in-depth
  alongside the hook, and native+PR-visible). A permission change on the gate surface
  now appears in a PR diff and is seen by the escalation-check, instead of hiding in
  the gitignored `settings.local.json`.

**Owner-manual (cannot ship in a diff) — see `docs/owner-apply-work-059.md`:**
- Clean the gitignored `.claude/settings.local.json` down to `{"permissions":{"allow":[]}}`
  (the old gate-surface grants are already dead — deny + hook override them — but the
  file should not state anything misleading).

**Design + partial, awaits Owner GitHub infra — see [[adr-023]]:**
- The **forgeable `owner-approved` marker** is a shared-identity problem. The real fix
  is a **restricted agent identity** (a bot/App token that cannot self-label,
  self-approve, or merge escalation-class PRs), plus an Owner-only approval mechanism.
  Designed and specced in [[adr-023]]; the Owner-only setup steps are in the owner-apply
  doc. **Not delivered here** — creating tokens/apps and branch protection are Owner
  account actions and depend on [[work-060]].

**Residual (honest):** until the restricted identity lands, the `owner-approved` marker
stays **agent-forgeable** under the shared identity. These rails make escalation
mechanical, auditable, and fail-closed against *accidental/unreviewed* merges — **not**
un-spoofable against a *deliberate* agent. ADR-022 does not activate on the marker alone.
Remainder for `done`: local-file cleanup (Owner) + [[adr-023]] activation (Owner infra +
[[work-060]]).
