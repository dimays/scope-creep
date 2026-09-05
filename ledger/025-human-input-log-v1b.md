---
name: ledger-025-human-input-log-v1b
description: Human-Input Log v1b shipped (work-020) — terminal capture hook + one-time backfill of 31 inputs back to the first ideation; consistency self-check carved out to work-022.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 025 — Human-Input Log v1b (capture + backfill)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

## Delivered ([[work-020]], [[prd-human-input-log]], [[adr-010]])
The terminal surface — the richest input channel, until now a "capture pending" gap
in the v1a log ([[ledger-024-human-input-log-v1a]]).

- **Owner-gated core change** (dimays/scope-creep#1, Owner-merged): a
  `UserPromptSubmit` hook (`.claude/hooks/log-human-input.{sh,py}`) appends each
  Owner prompt to a **local, gitignored** `human-input/YYYY-MM.ndjson`, redacting
  obvious secrets first and printing nothing to stdout. Never pushed to the public
  repo (Owner's choice).
- **Console reader** (dimays/scope-creep-console#13): `listHumanInput()` unions
  `human-input/` in via `SCOPE_CREEP_HOME` and emits `operator-session` events.
- **One-time backfill** (`scripts/backfill-human-input.py`): reconstructed **31**
  genuine inputs from the session transcript — back to the first ideation
  (`2026-09-04T21:22:46Z`, *"set up my own end-to-end autonomous AI developer loop"*).
  Conservative (drops tool-results / task-notifications / interrupts / compaction
  summaries; unwraps slash-command args; redacts secrets), idempotent (de-dupes by
  ts+text), each row tagged `backfill: true`. Verified: 37 inputs on `/work/inputs`
  once unioned with chat/request/feedback.

## Caught in verification (CRO discipline)
Two real bugs, both fixed before merge: a **stdin-vs-heredoc** bug (the hook's
Python was reading the here-doc, not the prompt JSON, so v1 captured nothing) and a
**UTC-parsing** bug in the backfill (transcript `Z` times read as local, shifting
every input ~5h onto the wrong clock). Empirical verification, not the plan, surfaced
both.

## Carved out — not shipped here
The **Consistency self-checks** specified in work-020 (gap + dup detection) were
*not* built — split to **[[work-022]]** for the level-setting round rather than
claimed as done.

## Next
Per the Owner's plan: the level-setting round — evaluate the c-suite pool, operating
standards, the Consistency issues (now incl. work-022), and the backlog; pay down
tech/doc/system debt.
