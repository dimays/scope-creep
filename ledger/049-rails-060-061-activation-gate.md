---
name: ledger-049-rails-060-061-activation-gate
description: The last two ADR-022 activation rails — work-060 (branch protection) and work-061 (author≠merger + path-gate QA spike). 061's path-gate is PROVEN (8/8, re-runnable). 060 is staged as an Owner-run script because an agent modifying repo security settings is correctly blocked. After the Owner runs 060, all five activation preconditions (057–061) are met.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 049 — Rails 060 + 061 (ADR-022 activation gate)

**Date:** 2026-09-06 · **Recorded by:** the operating session, Owner-directed
("start on the rails, floor first" + finale ask #2 "run … all outstanding tickets …
that includes work-060").

## Context
[[adr-022]] (autonomous-merge-with-escalation) is **accepted-direction, NOT active**.
Activation is gated on five mechanical rails: [[work-057]] (path-based escalation CI
check), [[work-058]] (gate `gh pr merge`), [[work-059]] (lock the gate surface),
[[work-060]] (branch protection), [[work-061]] (author≠merger + path-gate proof).
057–059 landed earlier. This entry closes the floor with 060 + 061.

## work-061 — QA spike: PASS (path-gate), with an honest split
The ticket has two clauses; they are proven differently and honestly:

1. **The path-check actually blocks an escalation-class diff — PROVEN.**
   [[work-057]]'s `scripts/escalation-check.sh` was exercised against an 8-case matrix
   in an isolated throwaway repo by the **re-runnable** proof
   `scripts/escalation-check.proof.sh` (no PR, no CI, no network). Result **8/8 PASS**:
   - routine docs-only diff → ALLOW
   - `standards/*`, `.claude/**`, `package.json`, `.github/workflows/**` without the
     Owner-approval marker → HOLD (exit 1)
   - the same `standards/*` diff **with** `--marker-present` → ALLOW (exit 0)
   - ledger **append-only** → ALLOW (carve-out); ledger **non-append rewrite** → HOLD
   The harness carries an **empty-diff guard** — a case whose setup fails to produce a
   real diff is reported FAIL, not a silent exit-0 pass. (That guard was added after the
   first run exposed exactly such a false pass in the marker case.)

2. **author ≠ merger in a live autonomous run — deferred, mechanically backstopped.**
   This is *runtime* orchestration behavior; there is no live autonomous run to observe
   because ADR-022 is not active yet. Until the first autonomous dev-cycle run, the
   guarantee is mechanical, not observed: [[work-060]] branch protection with
   `enforce_admins=true` means the shared identity cannot push to `main` directly — every
   change is a PR, and the merge is a distinct act from the authoring commit. The live
   author≠merger observation is the first thing the first autonomous run must record
   (distinct author/reviewer/merger agent slugs in the ledger, per work-060's spec).

## work-060 — Branch protection: STAGED as an Owner-run script (not agent-applied)
An agent applying branch protection is **modifying repo security settings**, and the
session's safety classifier correctly **blocked** the `gh api … /branches/main/protection`
PUT (and the heredoc that wrote the commands). This is the right outcome, not a
workaround target. So 060 ships as `scripts/owner-runbook/060-branch-protection.sh`
for the **Owner** to run under their own authority. It sets, on every repo's `main`:
- require a PR before merging, **0 required approvals** (a single GitHub identity cannot
  self-approve; requiring ≥1 would deadlock every PR — independence is enforced at the
  session/ledger level + the escalation check, not by GitHub review count);
- require that repo's **real** status checks (resolved per-repo so console/design/ext,
  which have no escalation-check workflow, are not deadlocked):
  - scope-creep → `Path-based auto-escalation (ADR-022 trigger d)` + `Registry sync + work-item schema`
  - scope-creep-console → `App Contract test gate`
  - scope-creep-design / -ext-chatbot / -ext-feedback → `Package test gate`
- `enforce_admins=true` (the shared identity cannot bypass — the whole point of the rail);
- block force-pushes and branch deletion.
Fully reversible in repo Settings. Verified today: **no** repo currently has protection.

## Where this leaves activation
After the Owner runs the 060 script, **all five floor rails (057–061) are met.** The
remaining activation steps are the Owner's alone and unchanged from the runbook:
apply the [[adr-022]] INVARIANTS §10/§7 amendment, then (for true un-forgeability of the
marker, not a floor requirement) the [[adr-023]] restricted agent identity. The escalation
marker remains **agent-forgeable under the shared GitHub identity** until [[adr-023]] —
recorded honestly in `escalation-check.sh` itself and unchanged here.
