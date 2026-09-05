---
id: work-003
title: Adopt PRs + branch protection (CI red blocks merge)
type: chore
status: done
priority: high
owner: cto
spec: engineering-policy
branch: work-003-branch-protection
created: 2026-09-04
updated: 2026-09-04
---
CI runs today as a push/PR tripwire but doesn't block merges — the Owner pushes to
`main` directly. Adopt PR flow and require the checks so red actually blocks
([[engineering-policy]] §3, §7).

**Acceptance:** branch protection on both repos requires the CI/registry checks.

**Done (2026-09-04):** classic branch protection + rulesets are Pro-gated on private
repos (a real limitation we hit — see [[ledger-009-branch-protection]]). Owner chose
to make both repos **public**; applied an active `main-gate` **ruleset** to each
(required status check + required PR, no force-push/deletion, admin bypass).
`guard-gates.sh` widened (publish/release). Run mode → **gated-autonomous**.
