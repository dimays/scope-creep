---
id: work-125
title: Resolve Quill's durably-idle status — restaff onto doc-debt work or retire
type: chore
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: adr-020
created: 2026-09-28
updated: 2026-09-28
---

The first-ever scheduled [[staffing-review]] run (2026-09-28, [[ledger-081-staffing-review-first-run]])
re-surfaced a gap the 2026-09-24 system audit ([[ledger-079-system-audit]], PR #138) already
flagged and left open: `quill` (technical-writer, reports_to `chief-knowledge-manager`, created
2026-09-06) has sat `idle` for its entire ~22-day existence — summoned but never staffed to a
single ticket. `staffing.md` §2 is explicit that a durably-idle employee is a retirement-or-
restaff candidate, and the decision was held for the CKM.

There is now queued work that plausibly fits the technical-writer template: [[work-123]]
(console + design doc-debt refresh — genesis docs, CHANGELOG catch-up, design README), still
`proposed` and owned by the CKM. Reusing the already-summoned, still-fresh-context Quill is
cheaper than retiring and later re-summoning the same role ([[staffing]] §3).

## Acceptance
- The CKM either:
  (a) **Restaffs** Quill onto some or all of [[work-123]] (add `quill` to that ticket's
      `assignees`, flip Quill's `metadata.status` `idle` → `active`) — scoping Quill's slice to
      the writing/doc-freshness portions specifically (re-verifying frozen docs, CHANGELOG
      catch-up, README version bumps), not the sub-items that need engineering judgment (e.g.
      reconciling ADR-003's reference to a deleted function, confirming the design-package pin) —
      or
  (b) **Retires** Quill (`metadata.status` → `retired` + a one-line reason) if the CKM judges
      the fit isn't right, leaving [[work-123]] to be staffed fresh when picked up.
- Either way, `agents/employees/quill.md` no longer carries an open "held for CoS/Owner" callout —
  the decision is made and recorded.
- `bun run work:check` and `bun run registry:check` stay green.

## Notes
Gated change per [[staffing]] §2 (summon/restaff is proposed → PR, never a hand-edited registry).
This ticket only proposes the resolution; the CKM (as Quill's `reports_to`) makes and executes the
call, not the Chief of Staff. CRO-spot-checked before ticketing (see [[ledger-081-staffing-review-first-run]]).
