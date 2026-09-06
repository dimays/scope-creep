---
id: work-037
title: Agents / delegation activity surface (Explore)
type: feature
status: proposed
priority: high
owner: chief-designer
spec: prd-transparent-delegation
created: 2026-09-06
updated: 2026-09-06
---
The Owner's named #1: a standing, high-level view of who broke off, decided, spun up, and
staffed what ([[prd-transparent-delegation]]). The **entity lens** — under Explore, next to
the agent profiles + timeline, **not** the Work board (delegation is events, not tickets).

- Enrich each agent's page: recent activity (spawns/delegations/confers from the activity
  log), plus what it connects to — owned tickets, loops, docs, ledger entries.
- A global org-activity feed rendering the same source. Read-only projection; honest when
  empty ("no activity captured yet").
- Reuse a scannable **ActivityRow** primitive (actor · verb · object · time → deep link).

- **Depends on:** [[work-036]] (nothing real to render until capture lands).

**Acceptance:** an executive's page truthfully shows its recent delegations and its
connected artifacts, each deep-linking to the ledger/ticket; the surface never invents
activity or a rationale. See [[prd-transparent-delegation]].
