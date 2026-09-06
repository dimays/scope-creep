---
name: adr-020
description: Reconciles the agent org into four clear tiers — Executives (CEO + C-suite), Standing function agents (qa-tester, git-manager; kind:function), ephemeral Employees, and the stable-but-mutable Template catalog each executive summons from. Reclassifies the standing functions out of kind:core, seeds a per-executive template catalog with model presets, and names the staffing standard + staffing-review loop as the ongoing machinery the Chief of Staff drives.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# ADR-020: The agent taxonomy & the staffing model

- **Status:** accepted — authored and ratified by the [[chief-of-staff]], whose standing
  mandate under [[adr-018]] is to drive how work is staffed for consistent quality. The
  [[chief-knowledge-manager]]'s discoverability/lexicon lens and the [[cto]]'s
  registry/data-model lens are represented; the [[chief-reality-officer]]'s reality-check
  was applied against ground truth (registry-build behavior + the green gates) and an
  independent CRO pass may follow.
- **Date:** 2026-09-06
- **Deciders:** CoS (lead & ratify), CKM (lexicon/registry) + CTO (data model) consulted,
  CRO verifies; the [[ceo]] set the direction ([[adr-018]]).
- **Owner-gated:** yes — it touches core records (the [[glossary]], the registry harvester)
  and the org's structure. Lands via **PR under Owner approval** (the [[core-upgrade]]
  discipline, [[invariants]] §I.4 / [[adr-014]]). Agents propose; the Owner disposes.

## Context
Three tiers of agent had accumulated without a clean line between them, and the Owner
called it confusing: (1) the **executives** — the CEO ([[adr-018]]) plus the six C-suite;
(2) two **manually-created, permanent, cross-org agents** — [[qa-tester]] ([[adr-002]] /
[[ledger-034-qa-tester]]) and [[git-manager]] ([[adr-014]] / [[ledger-035-delegated-merge]])
— which the registry emitted as `kind: core`, conflating them with the C-suite; and (3) the
**employees + templates** model from [[adr-017]]. The Owner asked to (a) make the tiers make
sense and reclassify the two standing agents so they stop reading as either C-suite or
employees, (b) make employees clearly **ephemeral/transitory** and templates clearly
**stable-but-mutable**, (c) seed **a few helpful templates under each executive**, and (d)
have the CoS own this as an **ongoing, automated** project — staffing for consistent
quality, including which model each kind of employee runs. [[adr-018]] explicitly deferred
this "staffing-standards / employee-template pass" to the CoS; this ADR is it.

Constraints:
- **[[invariants]] §II (single-user, forever).** This is an *org hierarchy of agents*, not
  human auth/roles/tenancy. No accounts, no per-user anything.
- **The Registry is generated, never hand-maintained** ([[doc-standards]] §2). The tier is a
  harvested `kind`, not a hand-kept list; regeneration flows through
  `scripts/registry-build.ts`.
- **Core changes are governed** ([[invariants]] §I.4). The standing functions still live in
  the core repo and change only by [[core-upgrade]] — reclassifying their *role type* must
  not read as loosening their governance.

## Decision

### A. Four tiers, one `kind` field
The org has exactly four agent tiers, distinguished by the manifest `kind` the registry
harvests:

| Tier | `kind` | Members | Lifespan | Holds |
|---|---|---|---|---|
| **Executives** | `core` | CEO + CoS, CTO, CPO, Chief Designer, CKM, CRO | permanent | *direction* + a domain |
| **Standing function agents** | `function` | [[qa-tester]], [[git-manager]] | permanent | *execution*, cross-org |
| **Employees** | `employee` | instantiated per need (e.g. [[ada]], [[linus]]) | **ephemeral** | a staffed ticket |
| **Templates** | `template` | the role catalog ([[frontend-engineer]] …) | stable, **mutable** | a role *class* |

### B. Reclassify the standing functions out of `kind: core`
[[qa-tester]] and [[git-manager]] get `kind: function` in their manifests. They are
**permanent, cross-org functions** — any executive's work routes "prove it" to QA and
"land it" to the Git Manager — and are **not** summoned per-ticket or dissolved like
employees. The `function` tier names their **role type** (a cross-org capability holding
*execution*, not *direction*), **not** a weaker governance class: they remain core-repo
residents changeable only by [[core-upgrade]], exactly like the executives. This is why
[[level-set]] already excludes them from the domain hats — they execute and verify rather
than hold a domain.

### C. Employees are ephemeral; templates are the stable catalog
Codified in the new [[staffing]] standard: an **employee** is instantiated from a template,
staffed to specific tickets, and **retired** (status → `retired` + reason, never `rm`'d)
when the work is done — consistency comes from the **template**, which persists, not from a
long-lived worker. When a role recurs, summon a fresh employee from the same template.
Templates are **mutable** (improving one is encouraged; forking a near-duplicate is not).

### D. A per-executive template catalog, with model presets
Seed a starter catalog so each executive has "types of employees I can summon." Each
template declares the `owner_agent` executive it hangs under (now harvested into
`registry/employee-templates.json` so the org view can group them) and a `default_model`
preset tied to [[resource-budget]] tiers:

- **[[cto]]:** [[backend-engineer]], [[platform-engineer]], [[integration-engineer]]
- **[[chief-designer]]:** [[frontend-engineer]], [[design-systems-engineer]], [[product-designer]]
- **[[chief-knowledge-manager]]:** [[technical-writer]], [[knowledge-engineer]]
- **[[chief-product-officer]]:** [[researcher]], [[product-analyst]]
- **[[chief-reality-officer]]:** [[qa-verifier]], [[auditor]]
- **[[chief-of-staff]]:** [[program-coordinator]]

**Model presets** follow [[resource-budget]] "default down, escalate up": [[program-coordinator]]
defaults to the **routine/fast tier** (Haiku) as the deliberate exemplar that *different
employees run different models*; the engineering/design/research/writing/analysis/verification
templates default to the **balanced tier** (Sonnet); **no template defaults to the agentic
tier** (Opus) — that is reserved for a **per-employee escalation** on a specific hard or
core-touching ticket, overridden on the instance manifest, not baked into a template. The
CEO and the standing functions do not maintain a summon-catalog (the CEO directs; functions
execute).

### E. The ongoing machinery (CoS-driven)
- **[[staffing]]** — the standard: the template→employee lifecycle, summon-vs-reuse, and the
  model-preset policy.
- **[[staffing-review]]** — the periodic loop the CoS runs on a cadence to keep the roster,
  the catalog, and the presets healthy (retire stale employees, mend/prune templates, true
  up presets against the catalog), ticketing every change through the gated path. This is the
  "ongoing, automated" project the Owner asked for.

### F. Governance is unchanged
Spinning up/retiring an employee and creating/modifying a template remain **gated changes**
(propose → isolated worktree → PR, never a hand-edited registry, never an auto-merge —
[[adr-017]] §E, [[adr-009]], [[adr-014]]). Reclassification and the catalog land via this
Owner-approved PR. The registry stays generated; retirement stays a status change.

## Consequences
- **The confusion is resolved:** four tiers, each with a distinct `kind`, distinct lifespan,
  and distinct role — the standing functions no longer read as C-suite or as employees.
- **Employees are honestly ephemeral** and templates are the durable quality substrate; the
  org view can render "who each exec can summon" and "which model each runs" from generated
  data.
- **Staffing becomes a standing project**, self-correcting on a cadence, not a one-off.
- **Governance holds:** nothing here expands any agent's reach past the [[invariants]]; the
  standing functions keep their core-upgrade protection; every authoring path stays gated.
- **A cost we accept:** one new `kind` value and a slightly larger template shelf to keep
  coherent — which is exactly what [[staffing-review]] exists to maintain.
- **Console follow-up (not this repo):** the org view ([[adr-017]] / [[prd-org-and-staffing]])
  should render the `function` tier distinctly and group templates by `owner_agent` with
  their model preset. Tracked as a `work/` ticket against `scope-creep-console`; no
  console/design-repo edits in this pass.

## Alternatives considered
- **Leave the standing functions as `kind: core`.** Rejected: it is the exact conflation the
  Owner named — they are not executives and hold no domain.
- **Make them a third kind of executive (a "VP" seat).** Rejected: they hold *execution*,
  not *direction*; a domain seat would over-elevate a cross-org function and muddy
  [[decision-rights]].
- **Default some engineering templates to the agentic/Opus tier so the flagship tier is
  represented.** Rejected: it contradicts [[resource-budget]] "don't reach for Opus by
  habit / default down, escalate up." Opus is correctly an instance-level escalation, not a
  template default.
- **Fold staffing into [[level-set]] instead of a dedicated loop.** Rejected: level-set is a
  broad multi-domain debt+reflection sweep; staffing health deserves its own mechanical,
  higher-frequency cadence that complements it rather than diluting either.
- **A parallel `employees/` primitive or a hand-kept tier list.** Rejected: [[adr-017]]
  already settled employee-as-Agent, and a hand-kept list violates [[doc-standards]] §2 —
  the tier is a harvested `kind`.
