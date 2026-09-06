---
name: ledger-040-employee-org-and-templates
description: The Owner asked to expand the Console's Agents tab into an org view (who reports to whom, which employees are staffed to which tickets) and floated off-the-shelf employee templates executives staff from. Ratified as ADR-017 — employee = Agent(kind:employee) from a reusable template, reporting to the exec that spun it up, staffed via work-item assignees; both spin-up and template authoring are gated PRs. Seeded 5 templates and 5 employees reporting across the C-suite and staffed to real tickets.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 040 — Employee org & templates

**Date:** 2026-09-06 · **Recorded by:** the operating session, at the Owner's request.

## What happened
The Owner asked to expand the Console's **Agents** tab into a real org picture — who
reports to whom, which **employee agents** each executive has spun up, and what they are
staffed to — and floated an abstraction: off-the-shelf **employee templates** that a
C-suite executive staffs from, with license to create or modify a template when none
fits.

The [[glossary]] already sanctioned the **employee agent** ("an agent spun up by a
C-suite executive… ratified by the Chief of Staff") but nothing had been instantiated,
and there was no notion of an employee *type*. So the operating session gave the existing
concept a data model and formalized it rather than inventing a parallel primitive.

## The decision (ratified as [[adr-017]])
- An employee **is an Agent** with `kind: employee`, carrying `reports_to` (the exec that
  spun it up) and `template` (its archetype). Employees live in `agents/employees/*.md`.
- **Employee templates** (`kind: template`, in `agents/templates/*.md`) are reusable role
  archetypes — the shelf executives staff from.
- **Staffing** is derived from work items: a new optional `assignees:` field (owner =
  accountable exec; assignees = staffed employees). Never duplicated onto the employee.
- **Registries are generated:** `agents.json` now includes employees; a new
  `employee-templates.json` catalogs templates.
- Both **spinning up an employee** and **creating/modifying a template** are gated changes
  (proposed → isolated diff → PR, never a hand-edited registry, never an auto-merge —
  [[adr-009]], [[adr-014]]). This stays within [[invariants]] §II: it is an org hierarchy
  of agents, not human auth/roles.

## What was seeded
- **Templates:** [[frontend-engineer]], [[backend-engineer]], [[researcher]],
  [[technical-writer]], [[qa-verifier]].
- **Employees:** [[ada]] → [[chief-designer]] (on [[work-045]], [[work-048]]); [[linus]]
  → [[cto]] (on [[work-044]], [[work-042]]); [[vera]] → [[chief-reality-officer]]
  (cross-staffed to verify [[work-044]]); [[rae]] → [[chief-product-officer]] (on
  [[work-007]], [[work-031]]); [[quill]] → [[chief-knowledge-manager]] (spun up,
  intentionally unstaffed to show the "available" state).

## Follow-through
The Console surfaces (org view, template catalog, and the two gated authoring flows) are
periphery work in `scope-creep-console`, specced in [[prd-org-and-staffing]] and building
on the flagship gated preview/PR path. After any authored change merges, `registry:build`
regenerates the registries.
