---
name: ledger-022-request-intake-first-real
description: First real Owner request rode the full loop — request #2 (dashboard extensions) → triage → work-019 → shipped.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 022 — First real request, end to end

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## The loop ran on a genuine request
The Owner reported a dashboard bug + a small feature and asked to route it through the
**request process**. It ran the whole pipeline: filed as **request #2** → CoS triage
(routed the bug to CTO, the feature to the Chief Designer; resolved the "link like
Agents" ambiguity: apps/extensions link to their own repo) → ticketed as **work-019**
→ built → **gated PR #11** → merged → request #2 marked `done`.

## Delivered (Console 0.12.0)
- **Bug fix:** the dashboard Extensions panel was hardcoded to "None installed yet"
  and ignored `registry.extensions` (badge said 2, list was empty). Now it lists them.
- **Feature:** Apps + Extensions entries are clickable, linking out to their repo
  (Agents still link to their in-Console profiles).

## Significance
The request-intake loop ([[request-intake]]) → ticket-cycle → ship is now proven on a
real Owner request, not a demo. The Console handled its own bug report through its own
machinery.
