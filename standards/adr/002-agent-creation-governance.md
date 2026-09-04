---
name: adr-002
description: C-suite executives may create employee/app-bound agents, but agent org changes are ratified by the Chief of Staff.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# ADR-002: Agent-Creation Governance

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** Owner (amendment), Chief of Staff
- **Owner-gated:** yes (Owner proposed the amendment)

## Context
An early draft invariant said "only the Chief of Staff may create agents." The
Owner pushed back: C-suite executives should be able to staff their own needs —
spin up employee agents dynamically, or fully staff an app with a set of agents —
without a bottleneck. But an unbounded, self-staffing org can sprawl into
incoherence if no one keeps the map.

## Decision
Any C-suite executive **may create** employee or app-bound agents to staff their
needs. **Agent creation, destruction, and org restructuring must be ratified by
the Chief of Staff**, who records each change in the [[ledger]]. Only the Owner may
amend the locked [[invariants]].

## Consequences
- Executives move fast and staff dynamically; the CoS keeps the org coherent and
  the Ledger honest (a single source of truth for "who exists and why").
- The CoS may also collapse or split roles as demand shifts — likewise ratified and
  logged.
- Ratification is lightweight (a recorded approval), not a heavy gate; it exists for
  coherence and auditability, not to slow executives down.

## Alternatives considered
- **CoS-only creation** — rejected: a bottleneck that fights dynamic staffing.
- **Fully open creation, no ratification** — rejected: no coherent org map, silent
  sprawl, no audit trail.
