---
name: prd-000-template
description: Template for a product PRD. Copy to product/<slug>.prd.md and replace this manifest. Bakes in the doc-standards §9 presentation structure so a PRD starts scannable, not as a wall of prose.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-07
---

<!--
PRESENTATION (doc-standards §9 — keep this PRD scannable in 20 seconds):
lead with a `>` status/summary callout · the user problem before the solution ·
scope as a table or a tight bulleted list of tickets, never prose · bold the
load-bearing phrase per paragraph · no unbroken prose block over ~6 lines · mark
each section's register (agent-facing vs Owner-facing, §4). This template is the
default shape an author starts from — delete this comment and replace the manifest.
The `[[name]]` cross-links below are the wiki-link form; every real link must
resolve to a manifest name or work id (docs:lint enforces this).
-->

# PRD — <Feature name>

> **Status / one-line summary:** proposed | active | shipped — and the single
> sentence that says what this is and why it matters now. If it supersedes another
> PRD or is Owner-gated, say so **here**, in bold.

## The user problem
What the Owner is actually trying to do, and why today falls short. Lead with the
crux in one or two sentences; if there are several failure modes, make them a
**numbered list**, not a paragraph. Keep it about the *problem*, not the solution.

## The experience
The intended experience in the Owner's terms — a few bulleted moves, each with a
**bolded lead-in**, each mapping to a problem above. This is the human-facing
register (doc-standards §4): narrative, concrete, no jargon.

## Scope (this cycle)
The smallest slice that ships value and teaches us. One row per ticket — a bulleted
list of `[[work-NNN]]` links with a one-line intent each, or a table when there are
tradeoffs to show. Every scope item traces to a real ticket; new scope is
Owner-gated ([[invariants]] §I).

## Non-goals (this cycle)
What this explicitly does **not** do — the boundary that keeps the cycle honest.
A tight bulleted list. Guard the invariants here (e.g. single-user, §II).

## Success
How we know it worked — the observable signal, not an opinion. One or two sentences,
or a short list of measurable outcomes.

---

Follows [[doc-standards]] (esp. §4 registers and §9 presentation). The PRD is the
**living, supersede-not-destroy** record (§5): stamp sections `proposed | active |
deprecated` as they evolve; changes supersede and are recorded in git + the [[ledger]].
