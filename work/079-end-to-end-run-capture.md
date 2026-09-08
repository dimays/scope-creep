---
id: work-079
title: Capture end-to-end runs — a run start/finish event with a shared run-id
type: feature
status: proposed
priority: high
owner: cto
spec: prd-org-activity-moments
created: 2026-09-07
updated: 2026-09-07
---
Moment 1 of [[prd-org-activity-moments]] — *"an agent runs a process end-to-end."* This is
**not captured at all**: the only hook is `PreToolUse` on the spawn tool
(`.claude/hooks/log-activity.py`), there is no `Stop`/`SubagentStop` hook, and no run
concept. A whole unit of work — a loop, a routine, a subagent's full task — leaves no trace,
so the Owner can't see a process as one framed thing with a beginning and an end.

## What to change (capture side)
Add run capture emitting the target-shape run fields ([[prd-org-activity-moments]]):
- `type:"run"`, `phase:"start"` and `phase:"finish"`, sharing one **`runId`** so the two ends
  correlate into a single framed unit.
- Reuse `actor`/`summary`/`sessionId`/`threadId`; set `refUrl` to the run's artifact/thread
  when knowable so the row links live.

## The CTO deep-dive
Decide the capture point and the run boundary:
- **Which hook.** `SubagentStop` gives a subagent's end; a session-level `Stop` gives the
  turn's end. Evaluate whether `PreToolUse`(spawn)→`SubagentStop` bracket a subagent run
  cleanly, and how a **loop/routine** run (the more Owner-meaningful "process end-to-end")
  is bounded — a loop runner may need to emit its own start/finish rather than rely on a
  tool hook.
- **`runId` source.** Must be stable across the start and finish writes (e.g. derived from
  the session + spawn correlation, or minted at start and threaded to finish). Name the
  mechanism; if start/finish can't be reliably paired, prefer emitting only what is truthful
  over a guessed pairing.

## Gate class — Owner-applied
A new hook + settings wiring under `.claude/**` → **Owner-applied** (like [[work-077]]);
deliverable is an **owner-apply doc** under `docs/`. The read side — extending `activityVerb`
for `run` and grouping start↔finish by `runId` — is agent-buildable and lands in
[[work-081]] (read-model) / [[work-082]] (render). A [[ledger]] note records the core-hook
addition (INVARIANTS §8).

## Prerequisite
**[[work-077]]** (capture fires + reaches the Console) lands first.

**Acceptance:** after the owner-apply patch, running a process end-to-end appends a
`phase:"start"` and later a `phase:"finish"` line sharing one `runId`; the Console renders
them as one run with a duration, not two unrelated rows; an unfinished run shows as started
(honest), never a fabricated finish.
