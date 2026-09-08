---
name: roadmap-000-template
description: Template for a CEO roadmap-presentation entry. Copy to roadmap/NNN-YYYY-MM-DD-*.md when the roadmap loop produces one (see [[work-055]]). Not itself a presentation; exempt from lint like every other 000-template.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

<!--
PRESENTATION (doc-standards §9 — a board deck must be scannable in 20 seconds):
the CEO statement is the biggest wall-of-text risk — keep it to a few short
movements, each with a bolded lead sentence and a `---` break, never one long prose
block (roadmap-001 is the counter-example). Themes: a table-of-themes up top helps
the Owner skim; bold the ask in each theme. Delete this comment before publish.
-->

# Roadmap Presentation NNN — YYYY-MM-DD

- **Date:** YYYY-MM-DD
- **Horizon:** e.g. "next quarter" — the forward window this round plans against.
- **Presented by:** [[ceo]] to the board (the Owner), per [[roadmap]] step 5.
- **Supersedes:** [[roadmap-NNN]] (the prior presentation), or "—" on the first round.
  **Supersede-not-destroy** ([[doc-standards]]): this entry never overwrites the prior one;
  history stays in the repo and the Console shows the trail.

> **This round in one line:** the single most important thing the Owner should take
> from this deck — the state of the org and the one call being asked of them.

## CEO statement — State of the Org
The board narrative. Keep it in **short movements** — a bolded lead sentence per
paragraph, `---` rules between movements — not one continuous prose block. The Owner
should be able to skim the bold and get the arc. (This is the section most likely to
regress to wall-of-text; it is exactly what doc-standards §9 guards against.)

## Since last round
What changed since the superseded presentation (or since genesis, on the first round):
user experiences tracked, releases/version-bumps landed, and how the existing roadmap held
up — the three input streams [[roadmap]] step 2 reviews, briefly. Link the release notes
this round drew on (e.g. [[release-001]]).

## Themes
One subsection per board-deck theme. A theme with no narrative or no trace-links is not
ready to present — do not pad this section to look complete.

Lead with a one-row-per-theme overview table so the Owner skims the shape before the
detail:

| # | Theme | Owner | The ask |
|---|-------|-------|---------|
| 1 | <name> | [[executive]] | one line |

### Theme: <name>
A short narrative: what this theme is, why it matters now, what it changes for the Owner.
**Bold the ask.**

**Traces to:** the PRDs, tickets, decisions, and ledger entries this theme rests on —
[[prd-NNN]], [[work-NNN]], [[adr-NNN]], [[ledger-NNN-slug]]. Every theme must resolve to at
least one real artifact; a theme with nothing to trace to is a guess, not a plan
([[invariants]] §III.8 — never fabricate).

## Disposition
The Owner's response, recorded per [[roadmap]] step 7 — **accepted** / **revised** /
**deferred** — and, if revised, what changes before the next round.

---

**Producing this file is not this template's job.** The artifact shape + storage
convention are specified by [[work-055]]; the presentation's *content* is authored by the
[[roadmap]] loop's C-suite round and its *disposition* is the Owner's, per
[[decision-rights]]. This template exists so the Console surface ([[work-056]]) has a
stable shape to project before the first real round runs.
