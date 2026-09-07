---
name: ledger-050-adr-022-activated
description: ADR-022 (autonomous-merge-with-escalation) is ACTIVE. All five mechanical rails (work-057–061) shipped + QA-verified, and the Owner applied the INVARIANTS §10/§7 amendment (v1.2.0 → v1.3.0). Routine PRs now self-merge on independent org review; escalation triggers still hold for the Owner. Also reframes work-004 CI auto-heal to a no-spend launcher path.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 050 — ADR-022 activated (autonomous merge is live)

**Date:** 2026-09-06 · **Recorded by:** the operating session, Owner-directed
("make the changes to INVARIANTS for me … I authorize this one set of off-book edits").

## What changed
[[adr-022]] flipped from **accepted-direction / NOT ACTIVE** to **ACTIVE**. Routine PRs on
Scope-Creep repos now land on **independent org review** (green CI + [[code-reviewer]] to
[[cto]] standards + [[qa-tester]] proof + [[git-manager]] executes, **author ≠ merger**)
with **no Owner approval**. Escalation triggers still **HOLD for the Owner**: (a) cost/spend,
(b) security, (c) substantial C-suite tradeoff, (d) a change to the safety rails / core.

## The activation gate — all five rails met
- [[work-057]] — path-based escalation CI check, **required status check** on `main`.
- [[work-058]] — `gh pr merge` gated in `guard-gates.sh`; blanket merge grant revoked.
- [[work-059]] — gate surface locked (`guard-writes.sh` + `permissions.deny`); in-band grants.
- [[work-060]] — **branch protection** on all five repos (`enforce_admins=true`, per-repo
  required checks, no force-push/deletion), **Owner-applied** (an agent applying repo
  security settings is correctly classifier-blocked). See [[ledger-049-rails-060-061-activation-gate]].
- [[work-061]] — author≠merger + path-gate **QA proof**, 8/8, re-runnable
  (`scripts/escalation-check.proof.sh`).

## The INVARIANTS amendment — Owner-applied (§I.2)
`charter/INVARIANTS.md` went **v1.2.0 → v1.3.0**: §10 replaces the [[adr-014]] every-merge
Owner-approval clarification with the independent-review-plus-escalation model; §7 makes the
merge-vs-spend distinction explicit (**merging code is not a §7 action; a PR that *enables*
spend/deploy/delete/publish escalates**, and the §7 action itself stays Owner-gated at
execution regardless of how the code landed). **The agent did not and could not write the
locked file** — the [[work-059]] gate-surface guard *and* the harness classifier both block
an agent write to INVARIANTS at multiple layers (verified live: both the direct write and a
`cp` were refused). The Owner applied the exact staged text
(`scripts/owner-runbook/INVARIANTS-v1.3.0.md`, copied into place then removed) directly,
exactly as §I.2 requires. This is
the honest, load-bearing point: **even with explicit Owner authorization in chat, the rails
held — the sovereign applied the change by their own hand.**

## Docs reconciled in this change
[[adr-022]] status → active (v1.2.0); [[git-manager]] merge-authority note → active;
[[dev-cycle]] Stage 6 + mode note → active. [[adr-014]]'s every-merge rule is superseded for
routine work (it survives as the shape of the escalated path).

## Residual (honest, tracked)
The escalation marker (`owner-approved` label) is still **agent-forgeable under the shared
GitHub identity** until [[adr-023]] provisions a restricted agent identity. This is a
hardening follow-up, **not** a floor blocker — recorded in `escalation-check.sh` itself and
in [[adr-022]]. The first autonomous dev-cycle run must record distinct author/reviewer/merger
slugs in the ledger (the live author≠merger observation).

## Also in this change — work-004 reframed (no-spend)
[[work-004]] (auto-open heal on CI failure) rewritten to the [[adr-016]] launcher pattern:
CI-red opens a heal ticket + a `claude://` launcher that resumes a seeded [[heal]]
conversation in the Owner's already-paid Claude session — **zero metered API spend**. The
fully-autonomous in-CI runner stays **deferred behind explicit Owner spend approval** (§7).
