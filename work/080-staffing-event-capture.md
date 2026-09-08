---
id: work-080
title: Emit a staffing event when an employee agent is created
type: feature
status: proposed
priority: high
owner: cto
spec: prd-org-activity-moments
created: 2026-09-07
updated: 2026-09-07
---
Moment 3 of [[prd-org-activity-moments]] — *"an agent spins up an employee agent (creates an
agent to task work)."* This is **not captured**. Creating an employee is a git/registry
event: a new `agents/employees/*.md` manifest with a `reports_to` supervisor edge, harvested
by `scripts/registry-build.ts:64,123`. **No hook observes it**, and the current spawn hook
only sees the `Task`/`Agent` tool — a distinct thing (delegating a task ≠ hiring an agent).
So a staffing moment never reaches the activity log, and the reader's already-built
`staff→"staffed"` verb (`explore.server.ts:355`) has nothing to render.

## What to change (capture side)
Emit a staffing event on employee-manifest creation, carrying the target-shape staff fields
([[prd-org-activity-moments]]):
- `type:"staff"`, `actor` = the creating executive, `target` = the new employee slug,
  `reportsTo` = the manifest's `reports_to` edge, `summary` from the manifest description,
  `refUrl` to the manifest path / the ratifying [[ledger]] entry.

## The CTO deep-dive — where to hook (this is the design question)
Employee creation isn't a tool call, so a `PreToolUse` matcher won't see it. Evaluate:
- A **control-plane hook** on the manifest write (`.claude/**`, Owner-applied — like the
  other capture tickets), or
- A step in **`scripts/registry-build.ts`** that diffs new `agents/employees/*.md` and
  appends the event (a core-script change → core-upgrade gated), or
- The **Chief-of-Staff ratification** path emitting it as the org-change is recorded
  ([[invariants]] §I.3 — CoS ratifies agent creation into the [[ledger]]).
Pick the one that fires **exactly once per real hire** and can't double-count on a rebuild;
respect that staffing is already a ratified, ledgered act — the activity event is a
projection of it, never a second source of truth.

## Gate class — Owner-gated (core capture surface)
Whichever capture point wins touches the core (either `.claude/**` → Owner-applied, or a
core script → [[core-upgrade]] with Owner approval). Deliverable is an **owner-apply doc**
or a core-upgrade proposal, plus a [[ledger]] note. The read side is already built
(`staff` verb); [[work-082]] renders the `reportsTo` edge.

## Prerequisite
**[[work-077]]** (capture pipeline works) lands first.

**Acceptance:** creating a new employee agent (a ratified `agents/employees/*.md` with
`reports_to`) appends exactly one `type:"staff"` line naming the creator, the new employee,
and the `reportsTo` edge; the Console renders "X staffed Y, reporting to Z" with links; a
registry rebuild does not duplicate the event.
