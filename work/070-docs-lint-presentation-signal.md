---
id: work-070
title: Advisory docs:lint presentation signal (warn on likely wall-of-text)
type: feature
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: doc-standards
created: 2026-09-07
updated: 2026-09-07
---
Add an **advisory (non-failing) signal** to `scripts/docs-lint.ts` that warns at
generation/publish time when a doc likely violates the [[doc-standards]] §9
presentation standard — so doc-writers *encounter the bar mechanically*, not only by
reading the standard. This is the lint half of the §9 authoring-time-awareness
mechanism (the template + `AGENTS.md` pointer are the other halves, landed already).

**Why CKM-owned.** The lint is the [[chief-knowledge-manager]]'s doc-integrity
mechanics. The [[chief-designer]] owns the §9 *taste* layer and specs the heuristics
below; CKM owns *how* the linter implements and tunes them. Captured as a ticket
(not implemented in the same pass) to respect that ownership boundary.

**Advisory, never a gate.** It must `warn`, never `exit 1` — presentation is a
judgment call and a heuristic will have false positives; failing CI on it would be
worse than the disease. It rides the existing `warnings[]` path (like stale
`last_verified`), never `errors[]`.

Candidate heuristics (Chief Designer's starting set — tune, don't over-fit):
- **Wall-of-text paragraph** — a single prose paragraph over ~6 lines / ~N words with
  no list, table, callout, or sub-header breaking it.
- **No lead structure** — a first-class doc whose body opens with a long paragraph and
  no summary/callout/heading in the first ~8 lines (check 1).
- **Comparative-prose smell** — heuristic hint only; likely under-detectable, keep low-noise.
- **Scope for exemptions** — READMEs and narrative human-facing docs (§4) should be
  exemptable; keep the signal low-noise so it stays trusted (a noisy advisory gets ignored).

**Acceptance:** `bun run docs:lint` emits presentation `warn:` lines for a seeded
wall-of-text fixture and stays **green** (exit 0); no false-positive warning on the
current bar docs ([[adr-024]], [[doc-standards]]); the heuristics + thresholds are
documented so authors know what triggers them. See [[doc-standards]] §9, [[work-069]].
