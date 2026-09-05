---
id: work-028
title: Ratify (or roll back) the RR8 + Vite 8 major bump as a gated core-upgrade
type: chore
status: proposed
priority: medium
owner: cto
spec: golden-path
created: 2026-09-05
updated: 2026-09-05
---
From the level-set ([[ledger-027-level-set-round]], CTO — escalated to Owner). ADR-001 +
`golden-path` pin **React Router 7**, and ADR-001's mitigation demands *pinned versions*
and *gated framework upgrades*. The Console ships `react-router ^8` + `vite ^8` on caret
ranges with **no core-upgrade and no ledger entry** recording the major bump — a §I.4 /
ADR-001 breach that slipped because nothing enforces it.

- Decide: **ratify** RR8/Vite8 (amend ADR-001 + `golden-path` to RR8, pin exact versions,
  record a ledger entry) **or roll back** to RR7.
- Resolve **Playwright**: named in the App-Contract `test` gate + ADR-001 amendment (3)
  but absent from `package.json` — install it or amend the contract.

**Owner-gated:** a blessed-stack change ([[core-upgrade]], INVARIANTS §I.4).

**Acceptance:** ADR-001/`golden-path` match the installed framework, versions are pinned,
and a ledger entry records the decision. See [[golden-path]], [[ledger-027-level-set-round]].
