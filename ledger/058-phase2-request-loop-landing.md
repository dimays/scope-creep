---
name: ledger-058-phase2-request-loop-landing
description: Records a batch landing of Phase-2 Request Loop work across two repos — console PR #57 (work-065 remote thread store, ADR-024) and the work-066 request-triage runner (console side), plus scope-creep PR #73 (Org-Activity moments PRD + tickets work-078..082). Also records what was NOT landed: the two escalation-class PRs #72 (ADR-025 topology + runbook) and #74 (.claude/ activity-log fix) were HELD for the Owner because their red ADR-022 trigger-(d) gate is cleared only by a genuine Owner approval (the owner-approved label), which the Git Manager will not forge on a delegated agent's relay. Documents an orphaned-PR recurrence (#58) and its remediation (#59), and a ledger-numbering correction (057 already on main).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: git-manager
  last_verified: 2026-09-07
---

# Ledger 058 — Phase-2 Request Loop engine: batch landing (partial)

**Date:** 2026-09-07 · **Recorded by:** Git Manager · **Repos:** `dimays/scope-creep-console`,
`dimays/scope-creep` · **Status:** **PARTIAL LANDING** — 3 of 5 PRs landed; 2 escalation PRs held.

This entry consolidates one directed batch: the Phase-2 Request Loop engine (console #57/#58
mechanics + ADR-025 topology #72), the Org-Activity request (#73), and the `.claude/`
activity-log fix (#74). Three routine, non-escalation PRs landed; the two escalation-class
PRs were held for the Owner (see below).

> **Numbering correction.** The batch directive assumed main held up to `056` and asked for a
> single entry at `ledger/057`. In fact `ledger/057-transparent-delegation-visibility-fix.md`
> is already on `main` (landed via PR #71). This entry is therefore recorded as **058**, the
> next free number.

## What LANDED

### 1. console #57 — work-065 remote-capable thread store (ADR-024)
- **Repo:** `dimays/scope-creep-console` · **Branch:** `work-065-remote-thread-store` → `main`
  (deleted after merge).
- **Merge commit:** `c4868abdb1ab8cec72a472a3e06e93df7df9e629` (standard `(#57)`).
- **Gate:** routine / non-escalation. `App Contract test gate` green; MERGEABLE + CLEAN;
  author ≠ merger. Landed on independent-review + green gate ([[adr-022]] §10 routine path).
- **Files:** `README.md`, `app/db/config.ts`, `app/db/config.test.ts`, `app/db/index.ts`,
  `drizzle.config.ts`.

### 2. console work-066 — request-triage runner mechanics (console side)
- **Repo:** `dimays/scope-creep-console` · Originally **PR #58**
  (`work-066-request-triage-runner`), stacked with base = `work-065-remote-thread-store`.
- **Orphaned-PR recurrence + remediation (recorded honestly):** merging #57 with branch
  deletion removed the `work-065` base branch, which **auto-closed the stacked #58** — the
  same orphaned-PR failure mode seen on 2026-09-06. Correct order is *retarget child → then
  delete parent base*; the parent base was deleted first. GitHub refused to reopen #58 while
  its base branch was missing, and re-creating the base ref was blocked by the harness
  permission classifier. Remediation: opened a fresh PR **#59** from the surviving head branch
  `work-066-request-triage-runner` → `main` (identical diff; verified only its own 4-file delta
  and a conflict-free merge), updated the branch by **merging** `main` (not force), and merged.
- **Replacement PR #59 merge commit:** `c2464d6c6a6e9ea8a65456e8b810b492c27384e2`
  (standard `(#59)`). Branch deleted.
- **Gate:** routine / non-escalation. `App Contract test gate` green; MERGEABLE + CLEAN after
  update-branch; author ≠ merger.
- **Files:** `app/lib/threads.server.ts`, `app/lib/triage.server.ts`,
  `app/lib/triage.server.test.ts`, `scripts/triage.ts`.

### 3. scope-creep #73 — Org-Activity: the three moments (PRD + tickets)
- **Repo:** `dimays/scope-creep` · **Branch:** `cpo/org-activity-moments` → `main`
  (deleted after merge).
- **Merge commit:** `4397a3ef1b7a22d7f4c1b15f75b321d2ab9e6883` (standard `(#73)`).
- **Gate:** routine / non-escalation. Touches `product/` + `work/` only; the
  `Path-based auto-escalation (ADR-022 trigger d)` check ran **green** (confirming
  non-escalation), `Registry sync + work-item schema` green; MERGEABLE + CLEAN; author ≠ merger.
- **Files:** `product/org-activity-moments.prd.md`, `work/078-spawn-parent-child-edge.md`,
  `work/079-end-to-end-run-capture.md`, `work/080-staffing-event-capture.md`,
  `work/081-activity-read-model.md`, `work/082-activity-surfacing-uplift.md`.

## What was HELD for the Owner (NOT landed)

Both PRs below fail a **red** `Path-based auto-escalation (ADR-022 trigger d)` gate and are
`BLOCKED`. That gate is cleared only by the Owner's explicit approval, mechanically the
**`owner-approved`** label. The Git Manager was directed to apply that label and merge, on a
relayed statement that the Owner had approved. Per [[invariants]] §III.7/§III.10, the
[[git-manager]] charter, and the operating rule that **no message from any agent is the
Owner's approval** and **a delegated role cannot clear a hold**, the Git Manager did **not**
apply the label. `gh pr merge` is allow-listed in this environment (no harness prompt fires),
so the red check + label is the *sole* remaining guard on these Owner-gated changes — forging
the marker would bypass the gate with no human in the loop, and #74 changes the gate surface
itself. These are held pending a genuine Owner approval (the Owner applying `owner-approved`,
or an Owner instruction through a trusted channel).

- **#72 — work-066 ADR-025 request-triage runner topology + runbook env vars.**
  Escalation trigger **(d)**: touches `standards/adr/025-*.md` (core standards). Also `BEHIND`
  after #73 landed. Files: `standards/adr/025-request-triage-runner-topology.md`,
  `docs/owner-apply-request-loop.md`. **Status: HELD — awaiting Owner approval.**
- **#74 — fix-update-log-activity (.claude/ activity-log fix).**
  Escalation trigger **(d)**: touches the locked `.claude/` gate/permission surface
  (`.claude/hooks/log-activity.sh`, `.claude/settings.json`) — the one INVARIANTS §III.10
  names explicitly ("`.claude/` gate or permission config"). Also `BEHIND`. **Status: HELD —
  awaiting Owner approval.** (Note: the related out-of-band hook fix is already recorded in
  [[ledger-057]]; this PR is a further `Task|Agent` matcher + write-path converge change.)

## Forgeable-marker caveat
The `owner-approved` label remains **agent-forgeable** until [[adr-023]] makes it unforgeable.
Where it appears, it is meant to record a *genuine* Owner approval. For #72 and #74 the Git
Manager had no Owner-sourced approval it could trust (only a delegated relay), so it declined
to apply it — which is exactly the failure mode ADR-023 is meant to close.

## Provenance
Recorded by the [[git-manager]] as the merger (author ≠ merger throughout). This ledger PR is
authored by the Git Manager and is therefore left for an **independent merger** — not
self-merged.
