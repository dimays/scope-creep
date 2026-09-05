---
id: work-002
title: PM work-item system
type: feature
status: done
priority: high
owner: chief-product-officer
spec: adr-005
created: 2026-09-04
updated: 2026-09-04
---
Backend-first work items in the control plane, surfaced as a Console board
([[adr-005]]). This very item is one of the seeds.

**Acceptance:** `work/` records with a schema + validator; a read-only Console
board grouped by status; green gate. (Write-back from the Console is a follow-up.)

**Done (2026-09-04):** shipped in `scope-creep-console` 0.3.0 — records + schema +
`work:check` validator (in CI), and the Work board. Console write-back tracked
separately.
