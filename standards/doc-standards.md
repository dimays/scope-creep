---
name: doc-standards
description: The Chief Knowledge Manager's day-1 documentation standards. Discovery is deterministic and generated, never hand-maintained.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-07
---

# Documentation Standards

The whole game: **discovery is deterministic and generated, never hand-maintained.**
If a human or agent must *maintain* an index, it drifts and the system rots.

## 1. Every first-class thing carries a manifest
Machine-readable front-matter (this file has one). Required fields:
`name, description, metadata.{type, status, version, owner_agent, last_verified}`.
`type` ∈ `user | feedback | project | reference`. `status` ∈
`proposed | active | deprecated`. Cross-link related docs with `[[name]]`.

## 2. The Registry is *generated* from manifests
A build step harvests every manifest into `registry/*.json`. The index can never
lie because nobody writes it by hand. See [[registry]].

## 3. Fixed filenames = convention over search
Every app repo ships the identical bundle at known paths, so an agent never hunts:
`PRD.md`, `README.md`, `ARCHITECTURE.md` (+ numbered ADRs in `adr/`),
`USERGUIDE.md`, `AGENTS.md`, `CHANGELOG.md`, `MANIFEST`.

## 4. Two registers, marked
Agent-facing docs are precise, imperative, contract-shaped. Human-facing docs
(for the Owner) are narrative. Each declares its audience. The PRD is dual and
sectioned.

## 5. The living PRD is supersede-not-destroy
Every PRD section is stamped `proposed | active | deprecated`; changes supersede
and are recorded (git + [[ledger]]). It grows to infinity without losing memory.
Contrast [[invariants]], which is locked.

## 6. ADRs are the memory of *why*
Numbered, immutable-once-accepted (`standards/adr/`). A self-modifying system must
never re-litigate settled decisions. Template: `adr/000-template.md`.

## 7. RAG only when convention breaks (the "as necessary" rule)
Start with deterministic discovery: fixed filenames + generated registry + grep.
Add embeddings / vector search **only** when catalog size makes lookup actually
fail. Do not build it prematurely. State the trigger in the ADR that proposes it.

## 8. Docs are testable
`last_verified` on every manifest; a maintenance loop flags staleness; a doc-lint
runs in CI. A doc that can drift silently is a bug.

## 9. Docs are presentation-graded (the scannability standard)
> **Owner mandate, 2026-09-07:** *"We should aspire to make every page look this
> polished. Some pages that are just larger, unformatted text blocks don't flow as
> clearly."* Presentation is a first-class doc property, not a finishing coat.
> **Presentation/taste layer owned by the [[chief-designer]]**; §1–§8 doc-integrity
> mechanics remain the [[chief-knowledge-manager]]'s. See [[ledger-054-docs-presentation-standard]].

A doc that is *correct* but reads as a wall of prose has failed its reader. Every
first-class doc — ADRs, PRDs, roadmap presentations, standards, ledger entries,
work tickets — is authored to be **scannable in 20 seconds**: a reader skimming
headers, the lead, and the bold should come away with the decision, the state, and
where their attention is needed. The counter-example is [[roadmap-001]]'s
prose-block passages; the bar is [[adr-024]] and this file.

**The seven checks. An author self-checks against these before publish; a reviewer
treats a miss on a load-bearing doc as a change request, not a nit.**

| # | Check | Concretely |
|---|---|---|
| 1 | **Lead with the answer** | Open with a 1–3 sentence summary or a `>` callout stating the decision/state *before* the argument. The reader gets the "what" before the "why". |
| 2 | **Structural hierarchy** | `##`/`###` sections with scannable, noun-phrase headings. No section longer than ~6 lines of unbroken prose — break it. |
| 3 | **Tables for anything comparative or tabular** | Options-vs-tradeoffs, field schemas, status matrices, stack layers → a table, never a paragraph listing them. |
| 4 | **Callouts for the load-bearing point** | The one thing the reader must not miss goes in a `>` blockquote (status, an Owner-gate, a constraint, a supersede note). At most one or two per doc — a page of callouts has none. |
| 5 | **Visual breaks over wall-of-text** | Lists for enumerations; short bolded lead-ins on list items; `---` rules between major movements. Prefer three tight bullets to one dense sentence with three clauses. |
| 6 | **Bold the load-bearing phrase** | In each paragraph, the decision-carrying words are **bolded** so a skim lands on them. Bold sparingly enough that it still signals. |
| 7 | **Scannable in 20 seconds** | The whole-doc test: headers + lead + bold + tables alone convey the gist. If they don't, restructure — this is the check the other six serve. |

**Not a mandate to inflate.** Structure serves the reader; padding a thin doc to
*look* structured fails check 7 as surely as a wall of text. A one-paragraph note
that reads clearly is already done. Narrative human-facing docs (§4) keep their
voice — this is about *flow and scannability*, not converting prose to bullet soup.

**Where this is enforced.** The doc templates (`000-template.*`) ship this structure
as the default an author starts from (§3). A [[chief-knowledge-manager]]-owned
*advisory* `docs:lint` signal (non-failing) is proposed to warn on likely
wall-of-text / missing structure at publish time ([[work-070]]). The highest-leverage
uplift is the Console's markdown renderer — polished typography, spacing, and
table/callout styling lift *every existing doc at once* with no rewrite, including
[[roadmap-001]] ([[work-069]], owned by the [[cto]]).
