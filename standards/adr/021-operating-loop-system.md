---
name: adr-021
description: Ratifies the operating-loop system — three refined loops (the dev-cycle primary development loop wrapping ticket-cycle; the roadmap planning loop; the evolve org self-improvement loop) plus a new code-reviewer standing function — and states how they compose with the existing loops, their cadences/trigger types, and the decision-rights implications.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# ADR-021: The operating-loop system

- **Status:** proposed — authored by the [[chief-of-staff]] under the [[ceo]]'s direction and
  the Owner's 2026-09-06 direction ("refine them among the staff, design it all yourself, I
  trust the org to make decisions for the best of the product"). The [[cto]] (loop mechanics,
  standards enforcement), [[chief-product-officer]] (roadmap/planning), and
  [[chief-knowledge-manager]] (doc/registry) lenses are represented; the
  [[chief-reality-officer]]'s reality-check was applied against the existing loop set and the
  green gates. **An independent CRO/QA pass is recommended before this is accepted** (see
  "Where reality-checks would strengthen this").
- **Date:** 2026-09-06
- **Owner-gated:** **yes** — it adds core loops, a core standing-function agent, and edits core
  records ([[glossary]], [[decision-rights]], [[staffing]]). Lands via **PR under Owner
  approval** (the [[core-upgrade]] discipline, [[invariants]] §I.4 / [[adr-014]]). Agents
  propose; the Owner disposes. Do **not** self-merge.

## Context
The Owner sketched three new operating loops and asked the org to **refine** them — merge,
simplify, and reconcile with the loops that already exist ([[ticket-cycle]],
[[request-intake]], [[new-app]], [[heal]], [[core-upgrade]], [[decision]], [[level-set]],
[[staffing-review]]) rather than transcribe them, and to design a new **Code Reviewer**
function that runs the review cycle in the development loop. The refinement problem is
**avoiding duplication**: each new loop borders an existing one, and a naïve transcription
would create two loops doing one job (the exact failure [[adr-020]] avoided by keeping
staffing out of [[level-set]]).

## Decision
Adopt a three-loop system plus one standing function, each **composing with** — not
duplicating — the existing loops.

### A. The dev-cycle wraps the ticket-cycle (it does not subsume it)
The **[[dev-cycle]]** is the **primary development loop**: the *outer, multi-employee cohort*
loop (standup → development → PR push → **code review** → **doc review** → land → close). The
**[[ticket-cycle]]** stays exactly as-is: the *inner, per-ticket engine* (pick → execute →
gate → land) each staffed employee runs. The dev-cycle:
- **staffs** the cohort at standup ([[staffing]]) and lets each employee run [[ticket-cycle]]
  through its Execute step to a pushed PR;
- **interposes** its review stages **into** [[ticket-cycle]] step 5 — a green `test` gate
  becomes *necessary but not sufficient*; the PR must also clear the code-review cycle and
  doc review before [[git-manager]] lands it under Owner approval ([[adr-014]]);
- **tears the cohort down** (retire employees per [[staffing]]) when all its tickets are
  terminal.

Rejected framings: *subsume* (ticket-cycle is a sharp, resumable per-ticket engine worth
keeping intact) and *parallel/overlapping* (would duplicate per-ticket mechanics). A lone
ticket with no cohort still runs bare [[ticket-cycle]]; the dev-cycle is for a *round*.

### B. A new standing function: the Code Reviewer
**[[code-reviewer]]** (`kind: function`) joins [[qa-tester]] and [[git-manager]] as a
permanent, cross-org **standing function** — it holds *execution*, not a domain. It owns the
dev-cycle's Stage 4: read the pushed diff against **[[cto]]-set standards**
([[engineering-policy]], [[tech-sops]], [[app-contract]], [[golden-path]]), delegate proof to
[[qa-tester]] and fixes to employees, **iterate (bounded) until standards are met and the gate
is green**, then hand the PR to [[git-manager]] to land. Boundaries:
- **vs. [[qa-tester]]** — QA *runs and proves*; the Code Reviewer *reads the diff and
  orchestrates the cycle*, and **calls** QA. Diff-critique + coordination, not proof-by-running.
- **vs. [[chief-reality-officer]]** — the CRO is the skeptic at *decision* altitude; the Code
  Reviewer works at *diff* altitude and **escalates** a load-bearing concern up to the CRO.
- **vs. the [[cto]]** — the CTO *sets* the bar; the Code Reviewer *applies* it and escalates a
  standards *question/change* up to the CTO.
- **vs. the [[git-manager]]** — the Reviewer decides *ready*; the Git Manager *lands*. The
  Reviewer never merges or waives a red gate.

Three standing functions now guard the finish line — **verify ([[qa-tester]]) → review
([[code-reviewer]]) → land ([[git-manager]])** — replacing the Owner's keystroke, never the
Owner's approval.

### C. The roadmap loop is forward-planning, distinct from level-set
The **[[roadmap]]** loop convenes the full C-suite on a cadence to review the **user
experiences, releases, and version-bumps since the last roadmap** against the **existing
roadmap**, plan the **next roadmap in detail** (user stories, PRDs, ADRs), and have the
**[[ceo]] present it to the board (the Owner)**; the presentation + release notes are stored
and shown in the **Console** (product surface, CPO-speced in parallel — referenced, not
designed here). It is kept **separate from [[level-set]]**: level-set is *backward/inward*
(debt + lessons → a paydown backlog); roadmap is *forward/outward* (the next roadmap). They
feed each other (level-set's debt items are inputs to the roadmap round) but never merge.

### D. The evolve loop is generativity + meta-cadence, distinct from level-set
The **[[evolve]]** loop is the **meta** loop: on a cadence the org **generates the new
machinery scaling demands** (procedures, employee **templates** — DevOps and Security seeded
this round — new loops/functions) **and re-tunes the whole portfolio of scheduled loops**
(are they firing at the right cadence, still needed, any missing?). It is a **distinct loop,
not an extension of [[level-set]]** — level-set is debt paydown + reflection over *existing*
domains; evolve is *proactive/structural*. Clean handoffs prevent overlap: a catalog gap or
stale template → [[staffing-review]]; existing-domain debt → [[level-set]]; a *structural*
need surfaced by either → **up** to evolve. Evolve **owns the portfolio of cadences** — it is
the loop that re-tunes *every* scheduled loop (and itself), the way [[staffing-review]]
self-tunes its own.

### E. Cadences & trigger types (what to schedule vs. what is event-driven)
| Loop | Trigger type | Cadence | Wire a routine? |
|---|---|---|---|
| **[[dev-cycle]]** | **event-driven** | fires on an accepted request batch / a chosen level-set·staffing·roadmap track / an Owner-kicked round | **No** — not cron |
| **[[roadmap]]** | **time-scheduled** | **30d (monthly)**, bounds 14–90d | **Yes** |
| **[[evolve]]** | **time-scheduled** | **30d (monthly)** → relaxing toward quarterly, bounds 30–90d | **Yes** |
| [[ticket-cycle]] | event-driven (backlog) | per ticket | No (unchanged) |
| [[level-set]] | hybrid | 15 tickets **or** 2wk | (already defined) |
| [[staffing-review]] | hybrid self-tuning | ~14d (7–42d), + events | **already automated** ([[ledger-044-staffing-loop-automated]]) |

Cadence homes follow the [[staffing-review]] split: **policy** (seed + bounds) lives in each
loop manifest and moves only by [[core-upgrade]]; **state** (the live interval) lives in the
[[ledger]] and moves as ordinary loop output. The **evolve** loop is the portfolio-level
re-tuner of every scheduled cadence; staffing-review additionally self-tunes its own live
value between evolve rounds.

### F. Decision-rights implications
- The **"Landing a PR"** row of [[decision-rights]] gains the **code-review cycle** in its
  Verify column: landing is gated on **green CI + the [[code-reviewer]] cycle + [[qa-tester]]
  proof + Owner approval** — approval required, keystroke not ([[adr-014]]). This ADR edits
  that row (a core change, landing in this Owner-approved PR).
- The **"Product scope / roadmap"** row is now *operationalized by* the [[roadmap]] loop; new
  scope stays Owner-gated (§I.4). The Owner is the **board** the [[ceo]] presents to.
- **New machinery** proposed by [[evolve]] (templates, loops, procedures, standards) is
  **core** and routes through [[core-upgrade]] — Owner-gated. A **cadence policy** change
  (seed/bounds) is Owner-gated core-upgrade; a **cadence live retune** is ungated ledger
  output. This mirrors the [[invariants]] §I.4 boundary exactly.
- No new authority is created: the [[ceo]] still cannot self-authorize a gate or a
  core-upgrade; the three standing functions still cannot ship or waive a red gate; every
  authoring path stays the gated propose → PR flow ([[adr-017]] §E, [[adr-009]]).

### G. Seeded machinery
The [[evolve]] loop's first concrete output: the **[[devops-engineer]]** and
**[[security-engineer]]** employee templates (`owner_agent: cto`, balanced-tier per
[[resource-budget]] / [[adr-020]]) — the Owner-named near-term scaling roles. Gated changes
landing in this PR; the first *employees* are summoned when real work arrives.

## Consequences
- **The three loops compose cleanly** with the existing eight — no loop does another's job;
  each border has a stated handoff. The loop portfolio is now: manufacture ([[new-app]]),
  build ([[dev-cycle]] ⊃ [[ticket-cycle]]), intake ([[request-intake]]), decide
  ([[decision]]), heal ([[heal]]), upgrade the core ([[core-upgrade]]), and four
  self-tending loops ([[level-set]], [[staffing-review]], [[roadmap]], [[evolve]]).
- **The finish line is guarded by three functions** (verify → review → land), making
  "meets CTO standards before it lands" mechanical rather than hoped-for.
- **The org can plan forward and evolve itself on a cadence**, with the meta loop owning the
  cadence portfolio so schedules stay tuned to reality instead of frozen in cron.
- **Costs accepted:** three more loop docs + one more standing function + two templates to
  keep coherent — which the [[evolve]] and [[staffing-review]] loops exist to maintain; and a
  larger fan-out surface (roadmap/evolve convene the C-suite), mitigated by inheriting
  [[level-set]]'s spawn discipline ([[resource-budget]] §2).
- **Governance holds:** nothing expands any agent's reach past the [[invariants]]; the
  standing functions keep core-upgrade protection; every gate is intact.

## Where reality-checks would strengthen this (flagged)
Load-bearing choices an independent [[chief-reality-officer]] / [[qa-tester]] pass should
pressure-test before acceptance:
1. **dev-cycle ⟷ ticket-cycle seam.** The claim that interposing review into ticket-cycle
   step 5 needs *no* edit to ticket-cycle's own text beyond the added cross-link. Verify by
   walking one real cohort end-to-end and confirming no step is double-owned.
2. **Code-reviewer vs. qa-tester non-overlap.** The boundary reads clean on paper; a live
   review round should confirm the Reviewer genuinely *delegates* proof rather than
   re-running it (the duplication risk).
3. **evolve vs. level-set vs. staffing-review non-overlap.** Three self-tending loops is the
   most likely place for silent duplication; the handoff rules should be tested against a
   real finding that could plausibly land in two of them.
4. **Cadence ownership.** evolve tuning *other* loops' cadences while staffing-review
   self-tunes its own must not become two hands on one dial — verify the policy/state split
   holds under a real retune.

## Alternatives considered
- **Make the dev-cycle subsume ticket-cycle.** Rejected: ticket-cycle is a sharp, resumable
  per-ticket engine; collapsing it into a cohort loop loses the single-stream clarity and the
  STOP checklist's home.
- **Fold roadmap and/or evolve into [[level-set]].** Rejected: level-set is already a
  two-stream debt+reflection sweep; adding forward-planning *and* generativity would overload
  it and blur three different altitudes — the same reason [[adr-020]] kept staffing separate.
- **Make the Code Reviewer an executive (a domain seat) or an employee (per-ticket).**
  Rejected: it holds *execution*, cross-org, permanent — exactly the standing-function tier
  ([[adr-020]]), like [[qa-tester]]/[[git-manager]]; a domain seat over-elevates it and a
  per-ticket employee loses the consistent bar.
- **Let evolve seed DevOps/Security only when first summoned.** Rejected for these two: the
  Owner named them as near-term, and seeding the templates now is the loop's natural first
  proof — still gated, still Owner-approved.
- **Schedule the dev-cycle on a cron.** Rejected: development is driven by *work arriving*
  (requests, chosen tracks), not the clock; a scheduled dev loop would fire on an empty
  backlog.
