---
name: ledger-008-operating-loop
description: Operating loop ratified (ADR-006 / ticket-cycle); backlog reranked; work-003 started and blocked on the Owner for branch protection.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 008 — Operating loop ratified; work-003 in flight

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Decision ([[adr-006]])
CoS convened the CPO (lifecycle/priority) and CTO (safety/resumability) to review
the Owner's proposed loop. Both, briefed separately, put `work-003` first. Adopted
the loop as [[ticket-cycle]] with revisions: supersede-not-delete, machine-checkable
termination + backlog-growth alarm, human-gated new scope, Definition of Done, WIP
cap, evidence-gated reprioritization, resumability from records, and two run modes
(propose-PR now → gated-autonomous after work-003).

## Backlog reranked
Sequence **003 → 005 → 006 → 001 → 004 → 007**. `work-003` raised to high. `work-001`
flagged to split (three-clause acceptance). Schema: `spec` now required, `branch`
added, terminal states `superseded`/`dropped`; `work:check` updated.

## work-003 — in flight (blocked on Owner)
- **Done:** `guard-gates.sh` widened (publish/release); schema + validator updated.
- **Blocked on Owner:** enabling GitHub branch protection is a repo-settings change
  — a STOP per the loop. Branch `work-003-branch-protection`.
- **Resume:** apply required-status-check protection to both repos, then flip run
  mode to gated-autonomous. Core-path Write-fence for unattended sessions to be
  designed within this ticket (must not block Owner-driven core edits).
