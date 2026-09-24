---
id: work-126
title: Owner evidence Phase B — bot authorship everywhere, escalation reads @dimays review, retire the label
type: feature
status: proposed
priority: high
owner: cto
spec: adr-028
created: 2026-09-24
updated: 2026-09-24
---

[[adr-028]] decision 5, Phase B. Once all org work is authored as `scope-creep-routine[bot]`,
including interactive sessions and [[work-125]]:

- Owner approval on kernel changes becomes a real GitHub review by `@dimays`
  ([[invariants]] §4b).
- The `owner-approved` label is retired.

## Acceptance
- **Workflow change, staged for the Owner to apply because it's a gate surface.** The escalation workflow checks for an APPROVED review from `dimays` instead of the label.
- **Guard update, also staged.** `guard-gates` drops the label rule.
- **Test.** A kernel-touching PR authored by the bot:
  - is held without a dimays review;
  - clears with one;
  - cannot be cleared by any agent-producible signal.
- **Scope.** Applies to scope-creep, scope-creep-console and scope-creep-design.
