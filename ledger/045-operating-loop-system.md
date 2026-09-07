---
name: ledger-045-operating-loop-system
description: Proposed the operating-loop system (ADR-021) — three refined loops (dev-cycle, roadmap, evolve), the new code-reviewer standing function, and two seeded templates (DevOps, Security) — reconciled with the existing eight loops. Owner-directed 2026-09-06; lands via Owner-approved PR.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 045 — The operating-loop system

**Date:** 2026-09-06 · **Recorded by:** the [[chief-of-staff]], under the [[ceo]]'s direction,
Owner-directed ("refine them among the staff, design it all yourself").

## What
Authored [[adr-021]] and the artifacts it ratifies — a **three-loop system + one standing
function**, refined and reconciled with the existing loop set rather than transcribed:

- **[[dev-cycle]]** (new, event-driven) — the **primary development loop**: the outer cohort
  loop (standup → development → PR push → code review → doc review → land → close) that
  **wraps** [[ticket-cycle]] (the per-ticket inner engine, unchanged) and interposes the
  review stages into its step-5 landing gate.
- **[[roadmap]]** (new, time-scheduled monthly) — forward planning: the full C-suite reviews
  UX/releases/version-bumps since the last roadmap, plans the next (user stories, PRDs, ADRs),
  and the [[ceo]] presents it to the board (the Owner); presentation + release notes shown in
  the Console (product surface, CPO-speced in parallel). Distinct from [[level-set]].
- **[[evolve]]** (new, time-scheduled monthly→quarterly) — the **meta** loop: generates new
  machinery as the org scales (procedures, templates, loops/functions) **and** re-tunes the
  whole portfolio of scheduled cadences. Distinct from [[level-set]]; owns the cadence portfolio.
- **[[code-reviewer]]** (new `kind: function`) — the review orchestrator: runs the
  review→QA→debug cycle on a pushed diff against [[cto]] standards, delegating proof to
  [[qa-tester]] and fixes to employees, iterating (bounded) until standards are met, then
  handing to [[git-manager]] to land. Third standing function guarding the finish line
  (verify → review → land).
- **Seeded templates** — [[devops-engineer]] and [[security-engineer]] (`owner_agent: cto`,
  balanced tier), the [[evolve]] loop's first concrete output; the Owner-named near-term roles.

## Reconciliations recorded (no duplication)
- **dev-cycle wraps ticket-cycle** (not subsume, not parallel): outer cohort loop vs. inner
  per-ticket engine; the review stages gate step-5 landing.
- **roadmap ≠ level-set**: forward/outward planning vs. backward/inward debt+reflection; they
  feed each other.
- **evolve ≠ level-set ≠ staffing-review**: generativity + meta-cadence vs. debt paydown vs.
  roster maintenance; explicit handoffs both directions.

## Cadences / triggers
- dev-cycle: **event-driven** (no routine).
- roadmap: **monthly** (30d, bounds 14–90d) — schedule a routine.
- evolve: **monthly → quarterly** (30d, bounds 30–90d) — schedule a routine; it re-tunes the
  whole cadence portfolio (staffing-review still self-tunes its own live value between rounds).

## Governance / gates
Owner-gated core change (loops, a standing-function agent, edits to [[glossary]],
[[decision-rights]], [[staffing]], [[ticket-cycle]], [[git-manager]], [[qa-tester]],
AGENTS.md). Lands via **PR under Owner approval** (the [[core-upgrade]] discipline,
[[invariants]] §I.4 / [[adr-014]]). No merge/deploy/spend/publish/INVARIANTS-edit performed;
ADR-021 is `proposed`. An independent [[chief-reality-officer]] / [[qa-tester]] pass is
recommended on the four seams flagged in ADR-021 before acceptance.

## Green gates at authoring
`docs:lint`, `registry:check`, `work:check` run green; the registry was regenerated
(`registry:build`) to harvest the new loops, the code-reviewer function, and the two templates.

## Follow-ups (not done here)
- **Schedule** the roadmap and evolve routines (self-gated like [[ledger-044-staffing-loop-automated]]).
- **Build** the code-review cycle mechanics, release-notes generation, and the roadmap
  "since-last-roadmap" harvest as `work/` tickets.
- **Console (product surface, CPO):** store/show roadmap presentations + release notes; render
  the code-reviewer function tier and dev-cycle cohort/review status in the org view.
