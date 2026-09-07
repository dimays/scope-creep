---
name: ledger-044-staffing-loop-automated
description: The staffing-review loop is now automated as a scheduled cloud routine (Owner-directed 2026-09-06). A weekly cloud trigger self-gates to the CoS-owned self-tuning cadence and opens a proposal PR only when due — the recurring runner for the self-tuning cadence in loops/staffing-review.md.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 044 — Staffing-review loop automated

**Date:** 2026-09-06 · **Recorded by:** the operating session, Owner-directed.

## What
The self-tuning staffing-review loop ([[staffing-review]], cadence protocol in
[[ledger-043-staffing-cadence-self-tuning]]) now has an automated recurring runner: a
**scheduled cloud routine** (`trig_01D3wGKgqvTAwEV7Y5avk7tf`, model `claude-sonnet-5`,
source `github.com/dimays/scope-creep`).

## How it runs (self-tuning via self-gating)
- **Trigger:** weekly cron `0 14 * * 1` (the 7-day floor of the cadence bounds).
- **Self-gate:** each fire reads the most recent `cadence-decision` ledger block and runs the
  full review **only when due** (`ran_at + next_cadence_days ≤ today`); otherwise it exits in
  seconds. So the *effective* cadence self-tunes across 7–42 days from the ledger, while the
  cron stays fixed — no fragile self-rewiring.
- **On a due run:** audits employees/templates/model presets, tickets changes through the
  gated path, appends a new `cadence-decision` block (trigger: scheduled), regenerates the
  registry if needed, and **opens a proposal PR**. It never merges/deploys/spends — all
  human-gated (INVARIANTS §III).

## Prereq recorded
Required connecting the Owner's GitHub (Claude GitHub App on `dimays/scope-creep`) so the
cloud routine can clone + open PRs — a one-time Owner action, done 2026-09-06.

## Note
The routine lives in claude.ai (not the repo); this entry is the repo-side memory of it.
Manage/disable at https://claude.ai/code/routines/trig_01D3wGKgqvTAwEV7Y5avk7tf .
