---
name: ledger-042-staffing-model
description: The Chief of Staff reconciled the agent org into four clear tiers (Executives, Standing function agents, Employees, Templates), reclassified qa-tester/git-manager out of kind:core into kind:function, seeded a per-executive template catalog with model presets, and stood up the staffing standard + staffing-review loop as the ongoing CoS-driven machinery. Ratified as ADR-020; lands via PR under Owner approval.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 042 — The staffing model & agent taxonomy

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff

## Why
The Owner called the mixture of agents confusing — templates, the C-suite, and the two
manually-created permanent agents ([[qa-tester]], [[git-manager]]) all read as one blur, and
the registry emitted the latter two as `kind: core`, conflating them with the executives.
[[adr-018]] had explicitly **deferred** the staffing-standards / employee-template pass to
the CoS; under that standing mandate, the CoS drove this reconcile.

## What changed (ratified as [[adr-020]])
- **Four tiers, one `kind` field:** **Executives** (`core`: CEO + six C-suite),
  **Standing function agents** (`function`: [[qa-tester]], [[git-manager]]), **Employees**
  (`employee`, ephemeral), **Templates** (`template`, stable-but-mutable).
- **Reclassified the standing functions** out of `kind: core` into **`kind: function`** —
  permanent, cross-org *execution* roles, not executives and not employees. They keep their
  core-repo [[core-upgrade]] protection; `function` names the role type, not a weaker class.
- **Employees are ephemeral; templates persist.** Codified in the new [[staffing]] standard:
  summon from a template → staff to tickets → **retire** (status, never `rm`) when done;
  consistency lives in the template.
- **Per-executive template catalog seeded** (5 existing + 8 new = 13), each carrying its
  `owner_agent` executive (now harvested into `registry/employee-templates.json`) and a
  **model preset**:
  - **[[cto]]:** [[backend-engineer]], [[platform-engineer]], [[integration-engineer]]
  - **[[chief-designer]]:** [[frontend-engineer]], [[design-systems-engineer]], [[product-designer]]
  - **[[chief-knowledge-manager]]:** [[technical-writer]], [[knowledge-engineer]]
  - **[[chief-product-officer]]:** [[researcher]], [[product-analyst]]
  - **[[chief-reality-officer]]:** [[qa-verifier]], [[auditor]]
  - **[[chief-of-staff]]:** [[program-coordinator]]
- **Model presets** follow [[resource-budget]] "default down, escalate up":
  [[program-coordinator]] → routine/fast tier (Haiku) as the exemplar that different
  employees run different models; the rest → balanced tier (Sonnet); **no template defaults
  to Opus** — the agentic tier is a per-employee escalation, not a template default.
- **Ongoing machinery:** the [[staffing]] standard (the *what*) + the [[staffing-review]]
  loop (the *how often*) — a cadence sweep the CoS runs to retire stale employees, mend/prune
  templates, and true up presets. The "ongoing, automated" project the Owner asked for.
- **Registry regenerated** via `bun run registry:build` (not hand-edited): `agents.json` now
  ranks core → function → employee; `employee-templates.json` gains `owner_agent`.
- **Glossary** updated to name the four tiers and the `function` lane.

## Governance
- **Ratified** by the CoS per [[adr-002]] (agent-org changes are CoS-ratified and logged) and
  [[decision-rights]] (CRO verifies, CoS ratifies, Owner-gated classes need Owner approval).
  CKM (lexicon/registry) and CTO (data model) lenses represented; CRO reality-check applied
  against the registry-build behavior and the green gates.
- **Owner-gated** — touches core records (glossary, registry harvester) and org structure;
  **lands via PR under Owner approval** ([[core-upgrade]] discipline, [[invariants]] §I.4 /
  [[adr-014]]). The CoS opened the PR; the Owner disposes by merging. Not merged by an agent.
- **Reversible** (§III.10): the `kind` reclassification and the catalog roll back in one diff.

## Follow-up (not this repo)
The Console org view ([[adr-017]] / [[prd-org-and-staffing]]) should render the `function`
tier distinctly and group templates by `owner_agent` with their model preset — tracked as
[[work-050]] against `scope-creep-console`. No console/design-repo edits in this pass.

## Org map now
Owner (sovereign) → **CEO** → Chief of Staff → six core executives ([[cto]],
[[chief-product-officer]], [[chief-designer]], [[chief-knowledge-manager]],
[[chief-reality-officer]], [[chief-of-staff]]) · **standing functions** ([[qa-tester]],
[[git-manager]]) · **employees** summoned from the **template** catalog.
