---
id: work-050
title: Org view — render the four-tier taxonomy + per-exec template catalog
type: feature
status: proposed
priority: medium
owner: chief-product-officer
spec: prd-org-and-staffing
created: 2026-09-06
updated: 2026-09-06
---
Console-repo follow-up to [[adr-020]] (the agent-taxonomy & staffing reconcile). The
control-plane registry now distinguishes four tiers and enriches the template catalog; the
`scope-creep-console` org view (ADR-017) should render them.

Scope (all in `scope-creep-console`, behind the gated preview/PR path — no control-plane
edits needed):
- **Render the `function` tier distinctly** from `core` executives and `employee` agents —
  `registry/agents.json` now emits `kind: function` for [[qa-tester]] and [[git-manager]].
  They should read as permanent cross-org functions, not C-suite and not employees.
- **Group the template catalog by executive** using the new `owner_agent` field on
  `registry/employee-templates.json`, so each exec shows "the types of employees I can
  summon."
- **Surface each template's `default_model`** (model preset) and any per-employee override,
  so the Owner can see which model each kind of employee runs ([[staffing]] §4,
  [[resource-budget]]).
- Reflect **employee ephemerality** — show `active | idle | retired` status so retired
  employees read as dissolved, not deleted.

**Acceptance:** the Console org view shows Executives, Standing functions, and Employees as
three visually-distinct tiers; templates are grouped under their `owner_agent` executive
with their model preset visible; retired employees render as retired. Reads generated
registry data only; writes (if any) go through the gated authoring path ([[adr-017]] §E).
