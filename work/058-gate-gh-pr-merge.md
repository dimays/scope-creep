---
id: work-058
title: Gate gh pr merge + revoke the blanket merge grant
type: feature
status: active
priority: high
owner: cto
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
> **Partially shipped 2026-09-06.** `guard-gates.sh` now gates `gh pr merge`: it
> blocks (exit 2, fail-closed) unless every required PR check — incl. the
> [[work-057]] escalation-check — is green, and closes the CRO's spend/deploy
> blocklist gaps (terraform apply/destroy, docker push, git push heroku, heroku
> create/scale/addons, gcloud deploy, aws cloudformation). **Remainder (Owner-manual,
> can't ship in a PR):** `.claude/settings.local.json` is **gitignored**, so
> revoking the blanket `Bash(gh pr merge *)` grant is a paste-step for the Owner —
> exact snippet in `docs/owner-apply-adr-022-floor.md` and the PR body; takes effect
> next session (the hook loads at session start). Flip to `done` once the grant is
> revoked. Bringing the grant in-band so it is reviewable is [[work-059]].
The second floor rail for [[adr-022]] (CRO fix #2). Today `Bash(gh pr merge *)` is
allow-listed and `guard-gates` does not inspect merges, so the harness merges any PR
with no prompt — the policy is optional from the harness's view.

- Extend `guard-gates` (or a CI precondition) so an autonomous merge fires only when the
  required checks (incl. [[work-057]]) are green and the path-check is clean.
- **Revoke** the blanket `Bash(gh pr merge *)` grant in `settings.local.json`; replace
  with the gated path.

**Acceptance:** an un-reviewed / escalation-class PR cannot be merged by the harness
without tripping a prompt/gate. Blocks [[adr-022]] activation. See [[adr-022]].
