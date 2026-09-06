---
name: adr-017
description: Ratifies the employee-agent org model — an employee is an Agent (kind:employee) instantiated from a reusable Employee template and reporting to the C-suite executive that spun it up, staffed to work via a work item's assignees field. Defines the generated registries (agents.json employees + employee-templates.json), the owner-vs-assignees staffing semantics, and that both spinning up an employee and creating/modifying a template are gated changes (proposed → PR, never a hand-edited registry, never an auto-merge). This is the substrate for the Console's org view and its in-app, gated authoring.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# ADR-017: Employee templates & the staffing model

- **Status:** accepted — authored by the CPO (staffing/PM is the CPO's domain), with the
  CTO on the data-model/registry shape and the CKM's discoverability lens. Per
  [[decision-rights]], employee-agent *creation* is ratified by the [[chief-of-staff]];
  this ADR ratifies the *model* those creations follow.
- **Date:** 2026-09-06
- **Deciders:** CPO (lead), CTO (model/registry), CKM (discoverability); CoS to ratify
  the org change ([[adr-002]]).
- **Owner-gated:** yes — it introduces a governed term and a new authoring path. The Owner
  requested the org view and the template abstraction directly; this records the decision.

## Context
The [[glossary]] already sanctions the **Employee agent** — "an agent spun up by a C-suite
executive for a scoped need; its creation is ratified by the Chief of Staff" — but nothing was
ever instantiated, there was no reusable notion of an employee *type*, and the Console's
**Agents** panel showed only the flat list of the eight core/functional agents. The Owner
asked for two things: (1) a **clear picture of who reports to whom** and which employees are
staffed to which tickets/initiatives, and (2) **off-the-shelf employee templates** an executive
staffs from, with license to create or modify a template when none fits.

Constraints this must respect:
- **[[invariants]] §II (single-user, forever).** This is an *org hierarchy of agents*, not
  human auth/roles/tenancy. No accounts, no permissions-per-user — the Owner remains the
  single source of authority.
- **The Registry primitive is generated, never hand-maintained.** Any employee/template index
  is harvested from manifests, not authored.
- **[[invariants]] §III (safety & reversibility) + [[adr-009]].** Creating an agent or a
  template is a repo change; it flows through the gated **propose → isolated diff → PR** path
  and is never auto-merged.

## Decision

### A. An employee *is* an Agent
An employee agent is an [[glossary|Agent]] with `kind: employee`. We extend the existing agent
model rather than introduce a parallel primitive — consistent with the glossary and with the
Agent primitive ("instructions plus a set of Grants"). Employee manifests live in
`agents/employees/*.md` and carry two extra top-level keys:
- `reports_to: <exec-slug>` — the C-suite/functional executive that spun the employee up (the
  edge that makes "who reports to whom" a fact, not an inference).
- `template: <template-slug>` — the archetype it was instantiated from.

`metadata.status` ∈ `active | idle | retired` (an employee is retired via status + a reason,
never `rm`'d — [[invariants]] §III).

### B. Employee templates are reusable role archetypes
A **template** (`kind: template`) is the off-the-shelf role an executive selects from —
Frontend Engineer, Backend Engineer, Researcher, Technical Writer, QA Verifier as the seed
set. Manifests live in `agents/templates/*.md` and carry the role's operating manual plus
defaults (`default_model`, `skills`). Templates are the *class*; employee agents are the
*instance*. Creating or modifying a template is a gated change (§E) so the roster stays
Owner-governed.

### C. Staffing is derived from work items (owner vs assignees)
Work items gain an **optional `assignees:`** field (comma-separated employee slugs). Semantics:
`owner` is the **accountable executive**; `assignees` are the **employees staffed** to the
item. Work items remain the single source of truth for staffing — the Console *derives* "which
employees are staffed to what" by joining employees to `work/*.md`; it is never duplicated onto
the employee manifest. `work:check` validates that every assignee resolves to a known agent.

### D. The registries are generated
`scripts/registry-build.ts` harvests:
- `registry/agents.json` — core/functional **and** employee agents, employees carrying
  `kind`, `reports_to`, `template`.
- `registry/employee-templates.json` (new) — the template catalog with `default_model` +
  `skills`.
Output stays deterministic so `registry:check` remains a reliable "in sync?" gate.

### E. Both authoring paths are gated
- **Spin up an employee:** an executive picks a template, names the employee, sets `reports_to`,
  and optionally staffs it to tickets. This produces the employee manifest **and** the
  `assignees` edits — proposed into an isolated worktree ([[adr-009]]) and opened as a **gated
  PR**. Deterministic (no model call needed).
- **Create / modify a template:** describe the role; an agent drafts the template manifest,
  reviewed as a diff and landed via the same gated PR path. Never a hand-edited registry;
  never an auto-merge; a red gate is never waived ([[adr-014]]).

The Console surfaces (org view, template catalog, and the two authoring flows) are ordinary
periphery work in `scope-creep-console` that reads the generated registries and writes only
through the gated path above.

## Consequences
- **The Owner gets the org picture:** Owner → C-suite → employees, each employee showing its
  template and staffed tickets, all from generated + derived data (no fabricated edges).
- **Staffing has one home** (work items); the employee manifest never drifts from it.
- **Governance holds:** new agents and templates enter only through a gated PR the Owner
  approves; the registry is still generated; retirement is a status change, not a delete.
- **A cost we accept:** an employee's manifest and its staffing live in two places (agent file
  + work items) by design — the file declares existence and reporting line; the tickets declare
  assignment. The join is the Console's job, not a denormalized copy.

## Alternatives considered
- **A new top-level `employees/` primitive.** Rejected: the glossary already defines an
  employee *as an Agent*; a parallel primitive would fork the model, the registry, and every
  reader for no gain.
- **Store staffing on the employee manifest (`staffed_to: [work-ids]`).** Rejected: it
  duplicates the work item's truth and drifts; deriving from `assignees` keeps one source.
- **Direct writes from the Console (skip the gated PR).** Rejected: violates §III / [[adr-009]]
  — creating an agent is a repo change and must be reviewable and Owner-approved.
- **Free-text roles instead of templates.** Rejected: the Owner asked for a preset roster to
  staff from; templates make roles reusable, comparable, and improvable, while still allowing
  a bespoke one when none fits.
