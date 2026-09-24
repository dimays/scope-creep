---
name: owner-apply-autonomy-charter
description: The Owner's steps to apply the ADR-028 autonomy charter. Copy the three staged gate-surface files into place (INVARIANTS v2.0.0, escalation-check v2, guard-gates v2), run the checks, then apply the owner-approved label by hand and merge. Agents cannot write these files.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-24
---

# Owner-apply: the autonomy charter ([[adr-028]])

> **Why you, and not an agent:** these three files are the gate surface. Agents can't write
> them: `guard-writes`, the `permissions.deny` rules and the harness classifier all block it.
> That's correct, and it's the [[ledger-050-adr-022-activated]] precedent.

| Staged file | Copy over | What changes |
|---|---|---|
| `scripts/owner-runbook/INVARIANTS-v2.0.0.md` | `charter/INVARIANTS.md` | §4 safety kernel · §4a autonomy by default · §4b real Owner evidence · §3 standing ratification · §7 metered compute counts as spend, local builds don't count as deploys |
| `scripts/owner-runbook/escalation-check.v2.sh` | `scripts/escalation-check.sh` | Holds **only** the safety kernel. Keeps the gate-script cases the routine-reviewer greps for. |
| `scripts/owner-runbook/guard-gates.v2.sh` | `.claude/hooks/guard-gates.sh` | Phase A: blocks agents from applying `owner-approved` |

## Steps

```bash
cd ~/code/scope-creep/.claude/worktrees/c-suite-owner-checkin-7082f4
git pull
cp scripts/owner-runbook/INVARIANTS-v2.0.0.md   charter/INVARIANTS.md
cp scripts/owner-runbook/escalation-check.v2.sh scripts/escalation-check.sh
cp scripts/owner-runbook/guard-gates.v2.sh      .claude/hooks/guard-gates.sh
git rm -q scripts/owner-runbook/INVARIANTS-v2.0.0.md scripts/owner-runbook/escalation-check.v2.sh scripts/owner-runbook/guard-gates.v2.sh
bun run docs:lint && bun run work:check && bun run registry:check
git commit -am "Owner applies the autonomy charter (ADR-028)"
git push
```

Then **add the `owner-approved` label yourself** on the PR. Once the checks are green, merge.

## Verified before staging

- **escalation-check v2 classification**, tested on a synthetic path list:
  - **HOLD:** INVARIANTS, PRINCIPLES, `decision-rights`, `agents/cto.md`, `.claude/**`, CODEOWNERS, `package.json`, `ledger/README.md`, `scripts/owner-runbook/*`, `guard-*`
  - **routine:** `charter/PRD.md`, `standards/staffing.md`, `loops/*`, `agents/employees/*`, `agents/templates/*`, `registry/*`, `work/*`
- **guard-gates v2** blocks `--add-label owner-approved` and the labels-API form, and passes ordinary commands.
- **Both scripts** pass `bash -n`.
