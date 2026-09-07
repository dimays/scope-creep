---
id: work-052
title: Console Schedules surface — cadence, next/last run, self-tuning history, link-out mgmt
type: feature
status: proposed
priority: medium
owner: chief-designer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
Build **Surface 1 (Schedules)** of [[prd-console-operations]] by **enriching the existing loop
explorer** ([[work-039]]), not forking a new surface.

- **Loop profile enrichment** (`/explore/loops/:name`): a **"Schedule & cadence"** section —
  `mode`, cadence + bounds, **last run** and **next run**, and recent outcomes. For a loop backed
  by a scheduled cloud routine, show **both** "next cron check" (the fixed cron fire) and "next
  *due* run" (`ran_at + next_cadence_days`), labelled honestly. Event-driven loops say so
  plainly ("event-driven — fired in the harness, no cadence").
- **Self-tuning cadence timeline**: parse the ledger `cadence-decision` blocks
  ([[ledger-043-staffing-cadence-self-tuning]]) into a **lengthen / shorten / hold** timeline —
  each run's signals (empty-streak, ad-hoc-since-last), the decision, `next_cadence_days`, and
  the CoS's one-line `reason`. This is the highest-value piece: it makes the staff-driven cadence
  legible (the cadence "breathing" and why).
- **Schedules index** (`/explore/schedules` + a home panel): the loops that *have* a
  schedule/cadence, each row = cadence, last/next, health at a glance.
- **Link-out management (honesty rule, [[adr-016]]):** a **cloud routine** → "Manage in
  claude.ai" deep link to `https://claude.ai/code/routines/{trigger_id}` (enable/disable/run-now
  happen **there**, never in-app — the app makes zero automated Claude calls). An **event-driven
  loop** → "open in Claude" harness launcher with context (mirror the [[prd-cos-threads]]
  launcher). **No in-app control that claims to drive a cloud routine.**
- **Empty is empty**: no cadence history / no runs → say so; never fabricate a run.

**Depends on:** [[work-051]] (scheduled-routines record; cadence timeline can land ahead of it
from the ledger alone).

**Acceptance:** from the Console the Owner sees what runs on a cadence, each one's last/next run,
recent outcomes, and the self-tuning cadence history with reasons; "Manage in claude.ai" and
"open in Claude" link out correctly; a loop with no schedule and a routine with no history both
render honestly. See [[prd-console-operations]].
