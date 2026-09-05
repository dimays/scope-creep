---
name: ledger-005-pm-decision-and-explore
description: Project-management approach decided (ADR-005); Console Explore v1 shipped.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 005 — PM decision; Explore v1

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Decisions
- **Project management is proprietary & backend-first** ([[adr-005]], Owner-
  confirmed): work items as versioned records in the control plane, surfaced in the
  Console; no external SaaS as the system of record.
- **Build order:** the Explore feature next (Owner-chosen).

## Product delivered
- **Console Explore v1 shipped** (`scope-creep-console` 0.2.0) per
  [[prd-console-explore]]: docs browser (wikilink-aware), agent profiles with
  ledger-derived contribution history, decision timeline, and a **consistency view**
  that surfaces drift. Green gate (7 tests); runtime-verified.
- Engineering note: the Console reads the live control plane directly, so the
  registry harvester is not a blocker — the consistency view instead *flags* the
  hand-seeded registries as a visible, tracked item.

## Follow-ups surfaced by the consistency view
- Build the **registry harvester** (registries still `_generated: false`).
- Optional: a machine-readable ledger index for cheaper timeline/contribution reads.
