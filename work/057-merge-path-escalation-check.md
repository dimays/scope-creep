---
id: work-057
title: Path-based auto-escalation as a required pre-merge CI check
type: feature
status: done
priority: high
owner: cto
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
> **Shipped 2026-09-06.** `.github/workflows/escalation-check.yml` +
> `scripts/escalation-check.sh` classify a PR's changed paths and FAIL (hold for
> the Owner) on an escalation-class touch without the `owner-approved` label; the
> routine ledger-append carve-out is implemented (append/new = pass, non-append
> rewrite = escalation). Verified across 7 scenarios and confirmed the check flags
> **its own PR** as escalation-class. **Remainder (not this ticket):** making this a
> *required* status check at the GitHub branch-protection layer is [[work-060]]; the
> harness-level merge block is [[work-058]]. **Honest gap:** the `owner-approved`
> marker is agent-forgeable under the shared GitHub identity ([[work-059]] — token
> separation); documented in the workflow, the script, and the PR.
The floor rail for [[adr-022]] activation (CRO fix #1 — the single most important).
A required CI status check that **fails any merge** whose diff touches an
escalation-class path without an explicit Owner-approval marker, making trigger (d)
(and much of (a)) mechanical rather than reviewer judgment.

- Escalation-class paths: `charter/INVARIANTS.md`, `.claude/**`, `standards/**`,
  `agents/**`, `loops/**`, `registry/**`, `.github/workflows/**`, and infra/paid-dep
  manifests (`package.json` + lockfiles, `Dockerfile`, `fly.toml`, `Procfile`/Heroku,
  `*.tf`). A routine ledger-append is carved out (per [[adr-022]] trigger (d)).
- On a touch with no Owner-approval marker → the check **fails** (the PR is held for
  the Owner). Define the marker (e.g. an `owner-approved` label the Owner alone can set).

**Acceptance:** an escalation-class diff cannot merge without the Owner marker; a routine
periphery diff passes. Blocks [[adr-022]] activation. See [[adr-022]] Activation gate.
