---
id: work-081
title: Console activity read-model — represent the edge, runs, and staffing
type: feature
status: proposed
priority: high
owner: cto
spec: prd-org-activity-moments
created: 2026-09-07
updated: 2026-09-07
---
The read side of [[prd-org-activity-moments]] on the **agent-buildable periphery**
(`scope-creep-console`). The reader today parses only the thin `{ts,actor,type,summary,...}`
shape (`app/lib/explore.server.ts:279-302`) and its `ActivityEvent` type (`:258-271`) has no
place for the parent→child edge, a run's identity, or a staffing edge — so even once capture
([[work-078]]/[[work-079]]/[[work-080]]) writes richer lines, the Console can't hold them.

## What to change
Extend the read-model to the target record shape ([[prd-org-activity-moments]]) — additively,
so the 63 backfilled rows and any old lines still parse:
- Add optional `target`, `runId`, `phase`, `reportsTo`, `refUrl`, `id` to `ActivityEvent`
  and to `parseActivityLine` (stay tolerant: unknown/missing fields drop to `undefined`,
  never throw — the current contract at `:279-302`).
- Add a **run grouping** helper: fold `type:"run"` `start`+`finish` sharing a `runId` into
  one logical run (with a duration) for the feed; a lone `start` renders as in-progress.
- Keep `activityForActor` semantically correct once `actor` means the doer (surface the
  edge via `target`); add `activityForTarget` if the agent page wants "who spun this agent
  up."

## Gate class — agent-buildable
Periphery only (the Console app, not the core). Ordinary [[dev-cycle]] with unit tests on
`parseActivityLine` (the pure, already-tested seam) covering each new field and the run
fold. No `.claude/**`, no ADR change. Pairs with [[work-082]] (render).

## Note
This can be built to the **schema** ahead of the Owner-applied capture tickets landing —
it reads lines that don't exist yet and stays honest-empty until they do — but it only
*shows value* once [[work-078]]/[[work-079]]/[[work-080]] write the richer records.

**Acceptance:** `parseActivityLine` round-trips every target-shape field with unit coverage;
a run's start/finish fold into one grouped entry; old thin lines still parse unchanged; the
feed stays honest-empty when the log is absent.
