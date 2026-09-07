---
id: work-058
title: Gate gh pr merge + revoke the blanket merge grant
type: feature
status: proposed
priority: high
owner: cto
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
The second floor rail for [[adr-022]] (CRO fix #2). Today `Bash(gh pr merge *)` is
allow-listed and `guard-gates` does not inspect merges, so the harness merges any PR
with no prompt — the policy is optional from the harness's view.

- Extend `guard-gates` (or a CI precondition) so an autonomous merge fires only when the
  required checks (incl. [[work-057]]) are green and the path-check is clean.
- **Revoke** the blanket `Bash(gh pr merge *)` grant in `settings.local.json`; replace
  with the gated path.

**Acceptance:** an un-reviewed / escalation-class PR cannot be merged by the harness
without tripping a prompt/gate. Blocks [[adr-022]] activation. See [[adr-022]].
