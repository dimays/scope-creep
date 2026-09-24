---
id: work-120
title: Standing doc-freshness / staleness maintenance loop
type: feature
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: adr-021
created: 2026-09-24
updated: 2026-09-24
---

`standards/doc-standards.md` (§ "a maintenance loop flags staleness") and
`standards/adr/015-agent-eval-criteria.md` (manifest-freshness as an eval signal) both assert a
doc-freshness loop exists. **It does not** — there is no file in `loops/`, no entry in
`registry/routines.json`, and no ticket. The only enforcement today is the advisory `docs:lint`
target and the `last_verified` field; the [[board-hygiene]] loop covers the *work board*, not docs.
The 2026-09-24 audit found the rot the tooling can't catch is exactly in human-maintained docs
(e.g. ADR-026 still `proposed` though live; charter/PRD org model predates ADR-018/020).

## Acceptance
- A doc-freshness maintenance loop exists (as a loop file + registered routine, OR folded into the
  [[board-hygiene]] propose-only pass — the CKM's earlier recommendation) that, on a cadence:
  runs `docs:lint` + `registry:check` + a `last_verified` staleness sweep, and opens ONE
  propose-only PR listing stale/broken/contradicted docs. It never merges (propose-only, so it can
  run as a cloud routine without a merge credential; any auto-landing of trivial `last_verified`
  bumps must route through the [[adr-027]] separated reviewer, never a credential in its own env).
- The false claims in doc-standards / ADR-015 are trued up to match whatever ships.

## Notes
Recommended by the Chief Knowledge Manager this session. Decide loop-vs-fold-into-board-hygiene
via the [[decision]] loop (CTO/CoS own, Owner dispositions — a new scheduled loop is
Owner-gated, [[adr-021]]). Also close the linter-scope gap the audit found: `docs/` and
`reference/` are excluded from `docs-lint.ts` MANIFEST_DIRS (see [[work-123]]).
