---
id: work-024
title: Implement docs:lint and wire it into CI
type: feature
status: proposed
priority: high
owner: chief-knowledge-manager
spec: doc-standards
created: 2026-09-05
updated: 2026-09-05
---
From the level-set ([[ledger-027-level-set-round]], CKM). `doc-standards` §8 says a
doc-lint runs in CI, but `package.json` `docs:lint` = `echo TODO && exit 1`, and
`registry.yml` runs only `registry:check` + `work:check` — so doc drift accrues
silently (it already has: stale README indexes, ADR/PRD-vs-reality gaps).

Implement `scripts/docs-lint.ts` checking:
- required manifest frontmatter fields present + valid;
- `last_verified` freshness (warn past a threshold);
- **wiki-link resolution** — every `[[name]]` resolves to a real manifest `name`;
- registry-in-sync across all manifest dirs (not just `agents/`).
Wire it into `.github/workflows/registry.yml`.

**Acceptance:** `docs:lint` exits non-zero on a dangling `[[link]]`, a missing required
field, and an out-of-sync registry; green on the current tree once known drift is fixed.
See [[doc-standards]], [[ledger-027-level-set-round]].
