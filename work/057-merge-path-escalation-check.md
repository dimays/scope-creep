---
id: work-057
title: Path-based auto-escalation as a required pre-merge CI check
type: feature
status: proposed
priority: high
owner: cto
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
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
