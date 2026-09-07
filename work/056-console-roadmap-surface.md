---
id: work-056
title: Console Roadmap surface — latest CEO presentation + history, projected read-only
type: feature
status: proposed
priority: low
owner: chief-designer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
Build the Console view for **Surface 3** of [[prd-console-operations]]: a **Roadmap** page that
projects roadmap-presentation artifacts read-only.

- Show the **latest** presentation prominently, with a **history** list beneath (supersession
  trail). Each theme's trace-links (PRDs, tickets, decisions, ledger entries) resolve via the
  existing cross-link/backlink machinery ([[work-039]]). Reuse Docs-browser rendering — no new
  authoring, exactly like projecting a PRD/ADR.
- **Empty is empty**: no presentation recorded yet → say so; never invent a deck ([[adr-016]]
  honesty rule).
- Read local artifacts via `SCOPE_CREEP_HOME` — no network, no Claude call.

**Depends on:** [[work-055]] (artifact shape + storage + a real presentation to project).

**Acceptance:** the Owner opens the Console's Roadmap view to see the CEO's latest board deck
plus the history, and clicks through each theme to its PRDs/tickets/decisions; an empty state
renders honestly. See [[prd-console-operations]].
