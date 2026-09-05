---
id: work-023
title: Version-sync — stop /healthz lying; add a version-sync consistency check
type: bug
status: proposed
priority: high
owner: chief-reality-officer
spec: prd-console-explore
created: 2026-09-05
updated: 2026-09-05
---
From the level-set ([[ledger-027-level-set-round]], CRO + CTO). Console `version.ts`,
`package.json`, and CHANGELOG top-entry are frozen at **0.13.0** while console PRs
#13 (work-020 reader) and #14 (work-021 expand) merged on top — so `/healthz` reports
a stale version and no gate catches it.

- Bump the Console version + CHANGELOG to reflect the shipped reader + expand work.
- Add a **version-sync check** to `consistency()` (`explore.server.ts`): flag when
  `package.json` ↔ `version.ts` ↔ CHANGELOG ↔ MANIFEST disagree.
- Fix the `version.ts` comment (it claims sync with the control-plane MANIFEST, wrong file).

**Acceptance:** `/healthz` reports the true version; `consistency()` flags a deliberately
desynced version. See [[ledger-027-level-set-round]].
