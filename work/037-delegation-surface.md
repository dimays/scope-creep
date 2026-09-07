---
id: work-037
title: Agents / delegation activity surface (Explore)
type: feature
status: done
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

> **DONE — console read-side shipped (2026-09-06, console #49).** `/explore/activity`
> (global feed) + a "Recent activity" section on every agent profile, built on the design
> `ActivityRow` primitive, projecting the [[work-036]] log read-only and **honest-empty**.
> Connected artifacts (staffing, loops, contributions) already render. **Live delegation
> data lights up when [[work-036]]'s capture hook lands** (Owner action — the hook lives in
> `.claude/`). See [[ledger-051-overnight-eng-loop]].
