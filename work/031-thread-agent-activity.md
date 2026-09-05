---
id: work-031
title: Inline agent activity in threads (ledger-projected)
type: feature
status: proposed
priority: medium
owner: chief-product-officer
spec: prd-cos-threads
created: 2026-09-05
updated: 2026-09-05
---
Phase 3 of [[prd-cos-threads]]. Let the Owner watch the org work inside a thread.

- Project **C-suite spin-ups**, **delegations to employee agents**, and
  **CoS↔executive confers** into the thread timeline as read-only activity events.
- Sourced from the [[ledger]] (INVARIANTS §III.8 already requires every consequential
  agent action to be recorded), and later the in-app agent runtime — the thread never
  invents activity, it reflects what was already logged.

**Acceptance:** a thread that triggered agent work shows the spin-ups/delegations/confers
inline, each deep-linking to its ledger entry. See [[prd-cos-threads]].
