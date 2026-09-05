---
id: work-003
title: Adopt PRs + branch protection (CI red blocks merge)
type: chore
status: blocked
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

**Progress (2026-09-04):** `guard-gates.sh` widened (publish/release); work schema +
validator updated ([[ticket-cycle]] backstops). **Blocked on Owner:** enabling
GitHub branch protection is a repo-settings change — a STOP per the loop. Resume:
apply required-status-check protection to both repos, then flip the run mode to
gated-autonomous.
