---
id: work-082
title: Org Activity surfacing — distinct rows for the three moments, live links, dedup
type: feature
status: proposed
priority: medium
owner: chief-designer
spec: prd-org-activity-moments
created: 2026-09-07
updated: 2026-09-07
---
The render side of [[prd-org-activity-moments]] on the **agent-buildable periphery**
(`scope-creep-console`). Today `explore-activity.tsx:74-86` renders every row identically —
`<verb> <summary>` with one actor link — because the writer only emits `type:"spawn"` and
never `refUrl`. Once the read-model ([[work-081]]) and capture ([[work-078]]/[[work-079]]/
[[work-080]]) land, the surface must make the three moments **visibly distinct and truthful**.

## What to change (`app/routes/explore-activity.tsx`, `@scope-creep/design` ActivityRow)
- **Per-moment rows.** Render each moment as its own shape, not one generic line:
  - **Run** (`type:"run"`) — one framed entry with start→finish and a duration (grouped by
    `runId` from [[work-081]]); an in-progress run reads as started.
  - **Spawn/delegate** — the **parent→child edge**: "actor spun up target", *both* linked
    (`actor` and `target`), so a fan-out reads as a fan-out.
  - **Staff** — "actor staffed target, reporting to reportsTo", with the `reports_to` edge shown.
- **Working links.** Use `refUrl` (now written) so rows deep-link to the artifact/ledger/PR/
  thread; `activityHref` already prefers `refUrl` then thread (`explore.server.ts:339-345`) —
  no more dead links.
- **Real per-type verbs.** `activityVerb` already maps the four verbs; extend it for `run`
  and ensure each type's row uses its verb (not the generic fallthrough).
- **Read-path dedup.** Collapse duplicate lines (same `id`, or same actor+target+ts) so a
  double-fire never shows twice.
- Preserve the **honest-empty** state and its copy — never fabricate a row.

## Gate class — agent-buildable
Periphery (Console + design package). If a new status color / motion token is needed for the
run "in-progress" affordance, that is a `@scope-creep/design` API change and is Owner-gated
per [[decision-rights]] ([[adr-013]] §7b precedent) — call it out in review rather than
slipping it in. Ordinary [[dev-cycle]]; QA drives the surface with real captured lines.

## Prerequisite
Depends on [[work-081]] (read-model) and shows full value once the capture tickets
([[work-078]]/[[work-079]]/[[work-080]], all gated on [[work-077]]) write real records.

**Acceptance:** with real captured activity present, the Owner can visually distinguish a
run, a spawn edge, and a staffing event at a glance; every row's link resolves; no row
renders twice; the empty state is unchanged when the log is quiet.
