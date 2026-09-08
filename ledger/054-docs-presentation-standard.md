---
name: ledger-054-docs-presentation-standard
description: The Owner's "make every page look this polished" feedback (2026-09-07) folded into a docs-presentation standard by the Chief Designer — doc-standards §9 (the 20-second scannability bar + seven checks), the same structure baked into the ADR/roadmap/PRD templates, an AGENTS.md read-order pointer, and two tickets (work-069 console renderer uplift/CTO, work-070 advisory docs:lint signal/CKM). Proposed via PR; escalation-class, not self-merged.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-designer
  last_verified: 2026-09-07
---

# Ledger 054 — Docs-presentation standard (Owner polish mandate)

**Date:** 2026-09-07 · **Recorded by:** the [[chief-designer]], Owner-directed
("make every page look this polished; fold it into docs standards").

## The feedback
The Owner praised the latest docs' polish — **clear hierarchy, tables, callouts,
visual breaks** — and asked that **every** doc aspire to it, calling out that
**unformatted prose blocks** (e.g. [[roadmap-001]], the CEO's first roadmap) "don't
flow." The Owner asked the Chief Designer to fold this into future docs standards,
templates, and the doc-generation/publish path so **whoever writes docs meets the bar**.

## The decision
Presentation is now a **first-class, checkable doc property**, owned by the Chief
Designer as the taste layer (doc-integrity mechanics stay with the
[[chief-knowledge-manager]]). Landed as a proposed PR:

1. **The standard** — [[doc-standards]] §9 ("Docs are presentation-graded"): the
   **20-second scannability bar** + **seven concrete checks** (lead with the answer;
   structural hierarchy; tables for comparative content; callouts for the load-bearing
   point; visual breaks over wall-of-text; bold the load-bearing phrase; scannable in
   20s). Prescriptive enough for an agent to follow, with an explicit **"not a mandate
   to inflate"** guard. Bar = [[adr-024]]; counter-example = [[roadmap-001]].
2. **Templates** — the structure is now the **default an author starts from**:
   `standards/adr/000-template.md`, `roadmap/000-template.md`, and a **new**
   `product/000-template.prd.md` (there was no PRD template before) each ship §9
   structure inline.
3. **Authoring-time awareness** — a read-order pointer in `AGENTS.md`; the guidance
   embedded in the templates; and a proposed **advisory** `docs:lint` signal.
4. **Tickets filed:**
   - [[work-069]] (owner [[cto]]) — **Console markdown-renderer uplift** for the
     Explore/Docs surface, sourced from `@scope-creep/design` typography tokens. The
     highest-leverage move: lifts **every existing doc at once** with no rewrite.
   - [[work-070]] (owner [[chief-knowledge-manager]]) — the **advisory (non-failing)**
     `docs:lint` presentation signal, so authors meet the bar mechanically.

## Hand-offs (coordinate, don't overstep)
- **CKM** owns [[doc-standards]] mechanics and the lint script — §9's *taste* content
  is the Chief Designer's; its *enforcement* (work-070) is CKM's to implement/tune.
- **CTO** owns the console renderer (work-069) — sibling `scope-creep-console` repo.

## Governance
Authored on branch `design/docs-presentation-standard` and opened as a **PR**. This is
**escalation-class** ([[invariants]] §III / [[adr-022]] trigger d — it touches
`standards/` and `AGENTS.md`): **not self-merged**, no `owner-approved` label applied
by the org. `docs:lint` and `work:check` green.
