---
id: work-059
title: Block Edit/Write to the gate surface + bring permission grants in-band
type: feature
status: proposed
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
