---
id: work-124
title: board-hygiene — exempt trigger-gated / backlog tickets from age-based staleness flag
type: debt
status: proposed
priority: low
owner: chief-of-staff
spec: adr-021
created: 2026-09-24
updated: 2026-09-24
---

[[board-hygiene]]'s stale-`proposed` flag is purely **age-based**, so it re-catches tickets it
cannot distinguish from rot: intentionally **trigger-gated** items (e.g. [[work-072]]–[[work-076]],
`prd-end-user-feedback-at-scale` — awaiting a 2nd app / volume breach) and valid **unstarted
backlog** (the org-activity cluster, owner-action-notifications). [[ledger-075-stale-proposed-dispositions]] had to re-review
the same aged set by hand. Surfaced as an open, unticketed option by the 2026-09-24 work-board audit.

## Acceptance
board-hygiene distinguishes "gated/backlog, not rot" from "genuinely stale" — e.g. a `blocked`
side-state, a body-declared trigger/exemption marker it reads, or an age exemption for tickets that
declare a revival trigger — so it stops re-flagging intentional backlog. False-positive stale flags
drop across consecutive runs.

## Notes
Low priority (cosmetic noise, not a safety issue). Owner: CoS. Consider alongside [[work-120]] if
board-hygiene becomes the host for the doc-freshness checks.
