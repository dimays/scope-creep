---
name: prd-org-and-staffing
description: Product requirements for the org & staffing surface — the Console's picture of who reports to whom, which employee agents each executive has spun up, what they're staffed to, and the off-the-shelf employee templates executives staff from (and may create/modify).
metadata:
  type: project
  status: active
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# PRD — Org & Staffing

> Ratified by [[adr-017]]. This PRD is the spec the `scope-creep-console` org-view and
> template-authoring tickets trace to.

## The user problem
As scope grows, the Owner needs to see the **organization**, not just a flat agent
list: which executive spun up which **employee agents**, who reports to whom, and what
each employee is staffed to. And executives need a fast way to **staff work** — pick a
role off a shelf rather than describe one from scratch each time — while keeping the
license to invent a new role when none fits.

## Goal & success signal
Give the Owner a clear, always-current org picture and give executives a first-class
staffing motion. **Success:** the Owner can answer "who works for whom, and who's on
what?" from the Console at a glance, and a new employee can be staffed to a ticket by
selecting a template — without hand-writing an agent from zero. We'll know it works
when execs staff from templates (not bespoke every time) and the org view is where the
Owner looks first to understand the team.

## Scope (v1)
1. **Org view** — the reporting tree: the Owner → C-suite → employee agents grouped by
   `reports_to`, each employee showing its [[glossary|template]] and the tickets it's
   staffed to (derived from work-item `assignees`). This is the expanded **Agents** tab.
2. **Template catalog** — browse the off-the-shelf employee templates (role, defaults,
   skills) and see the roster instantiated from each.
3. **Spin up an employee** — pick a template, name the employee, set the reporting
   executive, and optionally staff to ticket(s); produces the employee manifest + the
   `assignees` edits as a **gated PR** ([[adr-009]], [[adr-017]]). Deterministic.
4. **Create / modify a template** — describe a new role (or edit an existing one); an
   agent drafts the template manifest, reviewed as a diff and landed via the same gated
   PR path.

## Data model (see [[adr-017]])
An employee is an Agent (`kind: employee`) with `reports_to` + `template`; templates are
`kind: template`. Staffing lives in work-item `assignees` (owner = accountable exec;
assignees = staffed employees) and is **derived**, never duplicated. Registries
(`agents.json`, `employee-templates.json`) are generated.

## Out of scope (v1)
Auto-merging any authored agent/template (always gated); performance scoring of
employees (that rides on [[adr-015]]); cross-executive re-org tooling; per-employee live
chat. Staffing to initiatives/projects beyond work tickets can reuse the `spec` trace
later.

## Dependencies / notes
- Reads generated registries + `work/*.md` via `SCOPE_CREEP_HOME` (same pattern as the
  dashboard and Explore, [[prd-console-explore]]).
- Authoring reuses the existing gated sandbox → PR machinery ([[adr-009]]), pointed at
  the control-plane repo.
- Design stays minimal and token-driven ([[chief-designer]]).
