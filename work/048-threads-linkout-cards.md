---
id: work-048
title: Threads link-out cards (PRs, docs, tickets, PRDs, ledger)
type: feature
status: proposed
priority: medium
owner: chief-designer
spec: prd-cos-threads
created: 2026-09-06
updated: 2026-09-06
---
The link-out half of the [[adr-016]] reframe: render the artifacts a thread produced or
references as first-class cards that deep-link to the real thing — PRs, docs, work tickets,
PRDs, ledger entries. Extends the existing generated-request card ([[work-032]]) into a small
taxonomy.

- A card type per artifact class, each resolving to a stable URL/path (GitHub PR URLs;
  in-Console routes for docs/tickets/PRDs/ledger via the Explore projections that already exist).
- Sourced from the projected transcript/activity ([[work-047]]) + the ledger — never invented.

**Acceptance:** a thread renders cards linking to the actual PRs/docs/tickets/PRDs/ledger
entries it created or references, each navigating to the real artifact. See [[work-044]].
