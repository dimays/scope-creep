---
id: work-123
title: Console + Design documentation-debt refresh (genesis docs, CHANGELOG catch-up, design README)
type: debt
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: prd-console-operations
created: 2026-09-24
updated: 2026-09-24
---

The 2026-09-24 audit found a doc-debt cluster in the peripheral repos that the control-plane
`docs:lint` cannot see (cross-repo):

**scope-creep-console** (app at v0.22.0):
- `ARCHITECTURE.md`, `MANIFEST.yaml` (v0.3.0), `PRD.md`, `USERGUIDE.md` all frozen at
  `last_verified: 2026-09-04` — never re-verified across ~19 minor releases. USERGUIDE describes
  only the old 3-panel dashboard; PRD lists shipped roadmap items (agent chat, chatbot edit/merge,
  adopt design pkg) still as `proposed`.
- `CHANGELOG.md` stops at 0.22.0 though ~15+ commits shipped after (notification center,
  releases/roadmap/schedules surfaces, ADR-024 datastore, request-triage/work-sweep runners,
  Threads UX fix). Version froze at 0.22.0 — `consistency()` passes while silently drifting.
- `adr/001-schema-init.md` is contradicted by reality (drizzle migrations 0000-0008 AND
  `ensureSchema()` coexist); `adr/003` references `agentRespondStream`, deleted in 0.22.0.

**scope-creep-design** (at v0.4.0 dark-only):
- `README.md` still says "What's here (v0.2)" and "light + dark" — repo is v0.4.0 dark-only.
- `MANIFEST.yaml` `last_verified` predates the 0.4.0 release; version divergence from the control
  plane (design v0.4.0 vs releases v0.2.0) is nowhere explained (it is by design — independent
  semver — but say so).

## Acceptance
Console genesis docs re-verified to current reality (or explicitly marked historical); CHANGELOG
caught up post-0.22.0; adr/001 + adr/003 reconciled; design README bumped to v0.4.0/dark-only with
a one-line "versions independently of the control plane" note. Confirm the console's current
`@scope-creep/design` pin matches the dark-only decision.

## Notes
Also decide the linter-scope gap: `docs/` + `reference/` are outside `docs-lint.ts` MANIFEST_DIRS
(control plane) — pairs with [[work-120]]. **Open question for the Owner:** the audit could not
find a "Review column" in the console work board (only a `milestone: owner-review` value) — confirm
what "Review column" refers to before acting.
