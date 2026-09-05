---
name: ledger-004-cpo-and-standards
description: Chief Product Officer created; CTO engineering policy written; Explore PRD drafted; PM-tooling decision pending Owner confirmation.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 004 — CPO created; engineering policy; Explore spec

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Org change (ratified)
- **Chief Product Officer created** as the fifth core C-suite agent ([[adr-004]]).
  Wired as a subagent; registered in `registry/agents.json`. Owner-directed,
  CoS-ratified.

## Standards
- **[[engineering-policy]] written** (CTO): CI-as-referee, bug→failing-test→heal,
  PR/commit hygiene, refactor separation, tech-debt flagging & CTO escalation,
  dev→staging→prod promotion (prod human-gated), and honest test definitions
  (tests assert PRD behavior, never written to dodge a bug).

## Product
- **[[prd-console-explore|Explore PRD]] drafted** (CPO, status: proposed) — the
  Owner's first requested Console feature: browse docs, agent profiles (ledger-
  derived contributions; honest stance on evals), timeline, and a "what's out of
  sync" consistency view. Read-only v1; carries the seed of the feedback Extension.

## Pending Owner decisions
- **Project-management tooling** — CPO recommends proprietary, backend-first work
  records surfaced in the Console (no external SaaS). Awaiting Owner confirmation
  before it's recorded as an ADR.
- **Build order** — Explore feature vs. registry harvester vs. CI/self-heal wiring.
