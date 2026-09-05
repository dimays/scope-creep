---
name: ledger-013-work-intake-request
description: Owner request captured mid-flight — Work History + Work Requests — groomed into the backlog as proposed tickets + a PRD.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 013 — Work-intake request captured

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## The request (Owner, mid-work-006)
Add to the Work surface: **Work History** (condensed shipped-features log, linking to
tickets/PRs) and **Work Requests** (a place to submit/discuss requests; the system
declines/modifies/routes/tickets them — its own loop).

## Handled per the loop (not dropped — the very point of the feature)
- Captured, did **not** abandon the in-flight ticket (work-006 finished first).
- Groomed into `proposed`: [[work-008]] (History) + [[work-009]] (Requests, inbox
  v1), traced to a new CPO spec [[prd-work-intake]].
- **Structural call (CPO):** sections under the Work tab (Board / History / Requests),
  not new top-level tabs.
- **Chatbot overlap resolved:** Work Requests and the flagship chatbot ([[work-001]])
  share a *conversation primitive*; Requests is the scoped intake (backlog changes),
  the chatbot the powerful one (code changes). Requests-v1 is an inbox (no in-app
  agent runtime); Requests-v2 (live chat) folds into work-001.

## Awaiting Owner
Priority/sequence for work-008 / work-009 vs. the flagship work-001, and confirmation
of the Work-tab-sections structure.
