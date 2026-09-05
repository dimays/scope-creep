---
id: work-004
title: Auto-open the heal loop on CI failure
type: feature
status: proposed
priority: medium
owner: cto
spec: engineering-policy
created: 2026-09-04
updated: 2026-09-04
---
When CI goes red, automatically open the [[heal]] loop (budgeted) instead of waiting
for a human. Needs an agent runner with Claude auth in CI ([[engineering-policy]] §2).

**Acceptance:** a red gate triggers a heal attempt; on budget exhaustion it escalates
to the Owner with the diagnosis.
