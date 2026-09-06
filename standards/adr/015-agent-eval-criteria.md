---
name: adr-015
description: Defines per-role success criteria — what "good" means for each of the six core executives plus the two standing functional agents (qa-tester, git-manager) — and sketches a grounded eval method that derives any score only from real, in-repo signal (authored ledger entries and ADRs, landed PRs, QA verdicts, CRO verifications, the activity graph), never from invented metrics or parsed prose. This is the gating prerequisite for work-007: no agent score may be claimed until the criteria exist as an accepted ADR, and transparent contribution history precedes any quantitative score.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# ADR-015: Per-role agent-eval criteria + a grounded eval method

- **Status:** proposed — authored by the CPO (with the CKM's discoverability lens) under the
  overnight crank ([[ledger-036-overnight-crank]]). Acceptance is the gate: per
  [[decision-rights]] a docs/knowledge standard is **CRO-verified and CoS-ratified**, and the
  agent-eval design is jointly owned by the [[chief-product-officer]] and the
  [[chief-knowledge-manager]] ([[adr-004]]). **No agent score may be computed or surfaced
  until this ADR is accepted.**
- **Date:** 2026-09-06
- **Deciders:** CPO (lead), CKM (co-owner, discoverability); CRO to verify; CoS to ratify.
- **Owner-gated:** no (a measurement standard, not new product scope or a core-record change).
  Surfacing a score in the Console is ordinary ticket work behind this gate.

## Context
[[work-007]] wants to move agent profiles "from transparent contribution history to real
performance scoring." Its own acceptance names the ordering: **first define what "good" means
per role, recorded as an ADR, *before any score is claimed*.** The [[chief-product-officer]]
charter states the same discipline — "starting with transparent, ledger-derived contribution
history before claiming quantitative scores."

Two hard facts from [[adr-013]] constrain any eval built here, and this ADR treats them as
load-bearing:
1. **The [[ledger]] is deliberate prose, not a typed metric stream.** Deriving a number by
   NLP-parsing prose would be *inventing* the metric — forbidden ([[invariants]] §III.8).
2. **The activity log (`activity/*.ndjson`) is local, gitignored, and empty on a fresh
   clone.** Any count drawn from it must say "no activity captured yet" honestly rather than
   render an authoritative-looking zero as if it were a real score.

The failure mode this ADR exists to prevent is the one the org was built to catch: a
**confident but ungrounded number** — a leaderboard that looks quantitative but rests on
vibes, self-report, or parsed prose. A wrong eval is worse than none: it misdirects the Owner
and rewards the wrong behavior.

## Decision

### A. Per-role success criteria (what "good" means)
Each role's "good" is stated as an **observable behavior** tied to a **grounded signal** — a
real artifact already produced in-repo, not a proxy we would have to fabricate. Criteria are
role-specific because the roles are; a single universal score would flatten them.

**The six core executives**

- **[[chief-of-staff]]** — *good* = load-bearing decisions reach the **right room** and get
  **ratified and recorded**; org changes ([[adr-002]]) are ratified with a ledger entry;
  work is routed so it lands without collisions. *Signal:* ledger entries authored/ratified;
  ADRs ratified; staffing/delegation events in the activity graph; absence of orphaned or
  mis-routed PRs.
- **[[cto]]** — *good* = architecture decisions are sound and preserve the core/periphery
  split; the App Contract and tech SOPs hold; core-upgrades are correctly gated. *Signal:*
  ADRs led (owner_agent = cto); technical PRs landed green; heal/CI standards upheld; no
  invariant or gate routed around.
- **[[chief-product-officer]]** — *good* = every shipped requirement states a **user problem
  and a success signal** ([[chief-product-officer]] operating rules); specs under `product/`
  are buildable; sequencing favors the smallest slice that produces learning. *Signal:* specs
  authored; work tickets owned and moved to `done` with acceptance met; ADRs led.
- **[[chief-designer]]** — *good* = the design system stays coherent (tokens/primitives), the
  experience is not silently capped, and shared-package changes are correctly gated. *Signal:*
  design ADRs/tokens authored; design PRs landed green; delight/quality follow-ups raised.
- **[[chief-knowledge-manager]]** — *good* = discovery stays **deterministic and generated**
  ([[doc-standards]]); manifests are complete and fresh; the registry never lies; wiki-links
  resolve. *Signal:* `docs:lint` and `registry:check` green; manifest freshness
  (`last_verified`); dangling-link count at zero.
- **[[chief-reality-officer]]** — *good* = load-bearing claims are checked against reality
  **before** they are acted on, and fabrications/assumptions are caught. *Signal:* CRO
  verifications recorded against decisions; corrections that changed an outcome (e.g. the
  ADR-013 undercount and the lying `/healthz`).

**The two standing functional agents**

- **[[qa-tester]]** — *good* = "done/works" is turned into observed fact with an attached
  artifact, and **couldn't-verify is distinguished from failed**. *Signal:* PASS / FAIL /
  INCONCLUSIVE verdicts with the command + output/screenshot; throwaway spikes cleaned up.
- **[[git-manager]]** — *good* = approved work **lands green and mergeable**, stacks are
  parent-first with children retargeted, merged branches are cleaned up, and **no red gate or
  missing approval is ever routed around** ([[adr-014]]). *Signal:* PRs landed with the
  approving message recorded in the ledger; zero orphaned PRs; zero red-gate merges.

### B. The eval method (grounded, no invented metrics)
1. **Contribution history first; scores strictly later.** Phase 1 is a **transparent,
   read-only contribution history** per agent — a projection of real artifacts the agent
   produced (ledger entries authored, ADRs led, PRs landed, QA verdicts, CRO verifications).
   This is descriptive, not a score, and it ships before any number. A quantitative score is
   Phase 2 and only after this ADR is accepted and the history proves trustworthy.
2. **Every input must be a grounded artifact.** An eval signal is admissible only if it is a
   real, addressable artifact already in a repo or record-set:
   - **Ledger entries** an agent deliberately authored/ratified (attributed prose).
   - **ADRs** where the agent is `owner_agent` or a named decider.
   - **PRs opened/landed**, from the git host and the git-manager's ledger records.
   - **QA verdicts** (the qa-tester's PASS/FAIL/INCONCLUSIVE artifacts).
   - **CRO verifications** recorded against decisions.
   - **Doc-health checks** (`docs:lint` / `registry:check` results) for the CKM.
   - **The activity graph** (`activity/*.ndjson`, [[adr-013]]) for spawn/delegate/staff/confer
     events — the *graph* only, never a decision or rationale inferred from it.
3. **Attribution over inference.** A signal counts for an agent only where authorship is
   explicit (manifest `owner_agent`, a ledger byline, an ADR decider, a PR author). Where
   attribution is ambiguous, it is **unattributed**, never guessed onto an agent to inflate a
   count.
4. **Show the denominator and the provenance.** Any surfaced figure links to the underlying
   artifacts (the ledger entry, the PR, the verdict) so the Owner can audit it. A number the
   Owner cannot click through to its evidence is not shippable.
5. **Empty is empty, and it says so.** On a fresh clone or a quiet week the history is thin or
   the activity log is empty; the surface renders "no contributions captured yet," never a
   fabricated or zero-dressed-as-earned score.

### C. What must NEVER be fabricated (the hard line)
- **No score without grounded signal.** If the admissible artifacts don't exist, there is no
  number — full stop.
- **No parsing prose into metrics.** The ledger is prose; do not NLP-derive counts, quality
  grades, or sentiment from it and present them as measured ([[adr-013]] decision 5).
- **No self-report as proof.** An agent's own "I did X well" is not a signal; only the
  independently produced artifact (QA verdict, CRO verification, landed PR) is.
- **No quality/impact score dressed as objective** before the criteria here are accepted and
  the transparent history has been validated against reality by the CRO.
- **No inferred decisions or rationale** from the activity graph — it captures *that* a
  delegation happened, never *that a decision was right* ([[adr-013]]).
- **No cross-agent leaderboard ranking** in Phase 1. Contribution history is per-agent and
  descriptive; ranking is a Phase-2 decision that needs its own acceptance.

## Consequences
- **The ticket's gate is satisfiable:** per-role criteria now exist as a recorded ADR, so a
  contribution history can be built against a real definition of "good" once this is accepted.
- **The Console surfacing is a clean follow-up, not core work.** Rendering the contribution
  history / first eval on the agent profile is a `scope-creep-console` ticket that reads
  existing record-sets (ledger, activity log, git host) read-only — deliberately **out of
  scope for this control-plane ADR** and queued in the busy console lane (see [[work-007]]).
- **Discoverability holds (CKM lens):** the eval is defined in a numbered ADR with a manifest,
  cross-linked to the role charters it measures; nothing new must be hand-maintained, and the
  signals it reads are already-generated or already-append-only.
- **A cost we accept:** the grounded-only rule means early evals are sparse. That is the point
  — a thin honest history beats a rich fabricated one, and it improves as the record-sets fill.

## Alternatives considered
- **Jump straight to a quantitative per-agent score.** Rejected: violates the ticket's and the
  CPO charter's explicit ordering (transparent history first) and would almost certainly rest
  on invented metrics before the record-sets are rich enough.
- **A single universal score across all roles.** Rejected: the roles optimize for different
  outcomes (a git-manager's "green landed" ≠ a CRO's "caught the fabrication"); one number
  would flatten and mislead.
- **Parse the prose ledger with an LLM to grade quality.** Rejected: same failure as
  [[adr-013]] — it invents a metric from prose and couples the eval to writing style; it also
  can't be audited by clicking through to a hard artifact.
- **Self-assessment questionnaires per agent.** Rejected: self-report is not grounded signal;
  it rewards confident narration over produced work.
</content>
</invoke>
