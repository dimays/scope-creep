---
name: adr-005
description: Project management is proprietary and backend-first — versioned work records in the control plane surfaced in the Console, not an external SaaS.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-04
---

# ADR-005: Project management is proprietary & backend-first

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** CPO (recommendation), Chief of Staff, Owner (confirmed)
- **Owner-gated:** yes

## Context
Scope Creep needs a system of record for roadmap, specs, and work items. Options
weighed: an external SaaS (Linear), a proprietary in-platform system, or a hybrid.

## Decision
**Proprietary, backend-first.** Work items are versioned records in the control
plane — the sibling to the [[ledger]] (the ledger records what *happened*; PM
records what's *intended and in-flight*) — surfaced and eventually managed in the
Console. No external SaaS as the system of record. If a familiar board UI is ever
wanted, add a **one-way mirror**, never make it the source of truth.

Start minimal: work items as markdown-with-frontmatter under `work/` (same manifest
discipline as everything else, git-versioned, agent-native), graduating to DB
records + richer Console UI as volume demands. Minimal work-item shape:

```
id, title, type (feature|bug|debt|chore), status (proposed|active|blocked|done),
owner_agent, spec (link to a product/ PRD), priority, created, updated
```

## Consequences
- Honors the invariants: single-user, base-repo-is-the-product, agent-native,
  dogfooded, cloneable. No off-platform account required.
- The Console's Explore/PM views read the same control-plane source everything else
  does.
- We own the schema and the UX; nothing to integrate or keep in sync externally.

## Alternatives considered
- **Linear as system of record** — rejected: lives off-platform, needs its own
  account/integration, isn't part of the cloneable base repo, agents drive it via
  API. Fine as an optional future *mirror*, not the source of truth.
- **Hybrid now** — deferred: build the proprietary record first; add a mirror only
  if the Owner misses the SaaS UI.
