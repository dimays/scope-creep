---
id: work-087
title: Execution cadence & milestone governance — self-tuning sweep, machine-checkable milestone rule
type: feature
status: proposed
priority: medium
owner: chief-of-staff
spec: prd-autonomous-execution-loop
created: 2026-09-08
updated: 2026-09-08
---
The [[work-sweep]] loop must (a) self-pace its cadence on real signal rather than a hard-coded
guess and (b) know **precisely** when to stop for a milestone. This ticket makes a standing
function accountable for both — the execution-side analog of [[work-067]] (which did cadence
governance for [[request-triage]]), plus the net-new milestone rule.

Build:
- A **`cadence-decision` protocol** for [[work-sweep]]: on each run, weigh the signal —
  ready-backlog depth (deep → wake sooner; dry → back off), blocker/milestone hit-rate
  (frequent Owner-pulls → slow down and batch), and the [[ticket-cycle]] WIP cap — and emit a
  `cadence-decision` block to the [[ledger]] (`ran_at`, `trigger`, `next_cadence`, `reason`),
  the same protocol [[staffing-review]] / [[roadmap]] / [[evolve]] use. `cadence_bounds` keep
  tuning sane; the live cadence is read from the most recent ledger block, not duplicated.
- The **machine-checkable milestone rule** from [[prd-autonomous-execution-loop]], implemented
  as a pure predicate the sweep evaluates after each ticket:
  1. **theme/PRD boundary** — the last `ready` ticket tracing to a roadmap theme or a PRD's
     "Scope (this cycle)" reached terminal;
  2. **release boundary** — landed-but-unreleased work crossed the [[roadmap]] loop's release
     threshold;
  3. **priority-floor exhaustion** — no `ready` ticket at/above the floor (also termination);
  4. **explicit marker** — a ticket carries `milestone: owner-review` in frontmatter.
- Once the routine is registered on claude.ai, its `registry/routines.json` entry carries
  `cadence_bounds` alongside the other scheduled routines.

**Gate class — escalation.** Cadence *policy* (seed + bounds) and the milestone rule are core
loop policy ([[adr-021]] / [[invariants]] §I.4) — Owner-gated; a cadence *live retune* is
ungated ledger output. Any `standards/`/manifest policy change holds for the Owner.

**Acceptance:** every `work-sweep` run records a `cadence-decision` block; the sweep frequency
moves within bounds on real signal (not manual edits); the milestone predicate fires on each
of the four triggers and on nothing else (unit-tested); the routines.json entry (once
registered) lists `cadence_bounds`. See [[prd-autonomous-execution-loop]], [[work-sweep]],
[[work-067]], [[staffing-review]].
