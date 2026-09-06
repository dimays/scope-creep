---
name: ledger-034-qa-tester
description: The Owner authorized a Quality Assurance Tester agent (2026-09-06); the CoS ratified its creation per ADR-002. A standing functional agent that produces empirical proof (real runs, driven app, validated spikes) to complement the CRO's skeptic reasoning. Records its role and the standing grants it needs the Owner to authorize.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 034 — Quality Assurance Tester created

**Date:** 2026-09-06 · **Recorded by:** Chief of Staff

## Why
Verifying "does it actually work?" (e.g. the [[adr-013]] proof-of-hook spike) kept landing
on the Owner as manual steps. The Owner chose instead to **authorize a standing QA Tester
agent** to drive that empirical work, granting it what it needs. The CoS ratifies its
creation per [[adr-002]].

## The role ([[qa-tester]])
Hands-on empirical verification: reproduce acceptance criteria with real runs, execute and
**read** tests, drive the app in browser/simulator, wire **throwaway** spikes/hooks to prove
a premise then clean up, and hand back a **PASS / FAIL / INCONCLUSIVE** verdict with the
artifact. It **advises with evidence and does not ship** — never deploys, merges, publishes,
or routes around a gate.

Complements, does not duplicate, the [[chief-reality-officer]]: the CRO *reasons* about what
to distrust; QA *runs* it and produces the proof. CRO decides what must be proven; QA proves it.

## Standing grants (Owner to authorize)
The QA Tester needs these to do its job; the Owner grants via permission rules / `/permissions`:
1. **Edit `.claude/settings.local.json` (and place `.claude/hooks/*` scripts)** — to wire
   *throwaway* test hooks (the classifier gates this for good reason; the grant scopes it to
   the QA Tester's verification work). Required for the [[adr-013]] / [[work-036]] spike.
2. **Bash, Read, Write, Edit, browser/preview, and Agent (spawn)** — to run tests, drive the
   app, and spawn a trivial subagent to exercise a spawn-hook.
3. It still **cannot** self-approve human-gated actions (deploy/spend/delete/publish) or
   force a fresh session; where a hook needs a session reload to load, it flags that step
   for the Owner.

## First assignment
Finish the [[adr-013]] proof-of-hook spike: wire the `PreToolUse: Task` (and/or
`SubagentStop`) hook (`.claude/hooks/log-activity.py`, ready in scratch), spawn one real
subagent, and confirm a line lands in `activity/*.ndjson` — proving or killing [[work-036]]'s
premise before its core-upgrade. The write path is already proven; the live "does it fire"
confirmation is what QA drives once granted.

## Org map now
Six core executives + one standing functional agent (QA Tester). Registry regenerated
(`registry/agents.json`). Creation ratified per [[adr-002]]; amendable/collapsible by the
CoS, logged here.
