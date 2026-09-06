---
id: work-022
title: Human-Input Log — Consistency self-checks (gap + dup detection)
type: feature
status: done
priority: medium
owner: chief-reality-officer
spec: prd-human-input-log
created: 2026-09-05
updated: 2026-09-06
---
Carved out of [[work-020]] (it was specified there but not built — the capture,
reader, and backfill shipped; this read-side check did not). Queued for the
level-setting round, which explicitly revisits Consistency.

The Human-Input Log is the substrate for noticing when the record and reality have
drifted. Two checks over the spine ([[work-012]]):

- **Gap:** a window of work/merges (control-plane commits) with **no preceding
  captured input** — a missed input or an uninstalled/misfiring hook. Surfaces on
  `/explore/consistency` (and/or inline on `/work/inputs`).
- **Dup:** duplicate input ids or `(ts, text)` pairs — e.g. a backfill overlapping a
  live capture (the backfill de-dupes on write, but the check guards drift over time).

**Acceptance:** an induced gap (commits with no input in-window) and an induced dup
are both flagged; a clean timeline flags neither. See [[prd-human-input-log]],
[[adr-010]].
