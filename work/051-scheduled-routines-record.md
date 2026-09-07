---
id: work-051
title: Scheduled-routines record — projectable repo-side memory of cloud routines
type: feature
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
Give the Console a clean, generated input for **Surface 1 (Schedules)** of
[[prd-console-operations]]. Today the one scheduled **cloud routine** that exists
(staffing-review's `trig_01D3wGKgqvTAwEV7Y5avk7tf`) lives only as prose in
[[ledger-044-staffing-loop-automated]] — the "repo-side memory of it" that entry itself names.
There is no machine-readable record mapping *which loop* is fired by *which routine*, on *what
cron*, managed at *what URL*. So the Console can't project scheduled-routine rows without one.

- Create a projectable record of scheduled cloud routines: per routine `{ loop, trigger_id,
  cron, model, source, manage_url, status }` (e.g. `registry/routines.json`, generated/seeded
  the same way [[work-038]] added `loops.json`), harvested from a small per-routine source so
  it stays generated, never hand-maintained ([[adr-017]] §D posture; the Registry primitive).
- Optionally surface loop-manifest cadence fields the current harvest drops
  (`metadata.cadence`, `metadata.cadence_bounds`, `metadata.mode`) so Surface 1 can show
  cadence/bounds without re-reading manifests — decide harvest-extension vs. read-at-projection
  with the CTO.
- Keep it honest: the record is **memory + a link target**, not a control plane. It carries the
  `manage_url` (`https://claude.ai/code/routines/{trigger_id}`) the Console links out to; it
  does **not** imply the app can drive the routine ([[adr-016]] zero-Claude-call rule).

**GATED:** touches `registry/` + `scripts/` (harvest) and likely a `docs:lint`/`registry:check`
rule → Owner-gated, propose → PR, never a hand-edited registry ([[adr-017]] §E, [[decision-rights]]).

**Depends on:** —  ·  **Blocks:** [[work-052]].

**Acceptance:** `registry:check` passes with a generated routines record listing the
staffing-review cloud routine (loop, trigger id, cron, manage URL); the Console can read "which
loops are backed by a scheduled routine" from generated data, not prose. See
[[prd-console-operations]].
