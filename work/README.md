---
name: work-readme
description: The work-item system of record — schema and lifecycle. Backend-first per ADR-005; surfaced in the Console.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-04
---

# Work items

The project-management system of record ([[adr-005]]). Where the [[ledger]] records
what *happened*, `work/` records what's *intended and in-flight*. Backend-first:
each item is a versioned markdown file; the Console surfaces them as a board.

## File & schema
One file per item: `work/NNN-slug.md`, flat frontmatter, markdown body for
description / acceptance / notes.

```
---
id: work-001            # stable id, matches NNN
title: Build the chatbot extension
type: feature           # feature | bug | debt | chore
status: proposed        # proposed | active | blocked | done
priority: high          # high | medium | low
owner: chief-designer   # an agent slug
spec: prd-console-explore   # optional: a product/ PRD or ADR name (a [[link]] target)
created: 2026-09-04
updated: 2026-09-04
---
Body: the problem, the acceptance signal, notes.
```

## Lifecycle
`proposed → active → done`, with `blocked` as a side state. Transitions are edits to
`status` + `updated`, committed like any change; milestones also land in the
[[ledger]]. Validated in CI by `bun run work:check`.

## Notes
- Work items are **not** scanned by the Console's Explore/Docs (their `status`
  vocabulary differs from the doc manifest's). They live on the **Work** board.
- Creating/editing from the Console (write-back) is a later iteration; today items
  are authored as files by agents or the Owner.
