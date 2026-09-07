---
id: work-060
title: Branch protection on every Scope-Creep repo
type: feature
status: owner-action
priority: high
owner: git-manager
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
> **STAGED FOR OWNER (2026-09-06).** An agent applying branch protection is modifying
> repo security settings; the safety classifier correctly blocks it. Ship as an
> Owner-run script: `scripts/owner-runbook/060-branch-protection.sh` (exact per-repo
> check names resolved; `enforce_admins=true`; 0 required approvals). See
> [[ledger-049-rails-060-061-activation-gate]]. Reopen/close on the Owner's run.

CRO fix #4 for [[adr-022]]. `main` has NO branch protection on any repo today, so a plain
`git push origin HEAD:main` bypasses PR + review + escalation entirely. With all agents
sharing one git identity, branch protection is the only mechanical author≠merger backstop.

- Enable on `main` for scope-creep, scope-creep-console, scope-creep-design, scope-creep-ext-*:
  require a PR, require the status checks from [[work-057]], block direct + force pushes.
- Record, in the ledger at merge, distinct author/reviewer/merger agent slugs.

**Acceptance:** direct push to `main` is blocked; a PR needs the required checks green.
Blocks [[adr-022]] activation. See [[adr-022]].
