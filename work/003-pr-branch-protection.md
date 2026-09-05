---
id: work-003
title: Adopt PRs + branch protection (CI red blocks merge)
type: chore
status: proposed
priority: medium
owner: cto
spec: engineering-policy
created: 2026-09-04
updated: 2026-09-04
---
CI runs today as a push/PR tripwire but doesn't block merges — the Owner pushes to
`main` directly. Adopt PR flow and require the checks so red actually blocks
([[engineering-policy]] §3, §7).

**Acceptance:** branch protection on both repos requires the CI/registry checks.
