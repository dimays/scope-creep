---
id: work-026
title: Integration coverage for untested server fns + route loaders
type: feature
status: done
priority: high
owner: cto
spec: app-contract
created: 2026-09-05
updated: 2026-09-05
branch: work-026-runtime-tests
pr: https://github.com/dimays/scope-creep-console/pull/17
---
From the level-set ([[ledger-027-level-set-round]], CTO + CRO). The `test` gate is the
App-Contract "self-heal oracle," but current tests cover only pure helpers — so a broken
loader or IO path passes green. CRO sharpened the scope: 5 of 8 `.server.ts` **are**
tested; genuinely untested are `human-input.server.ts` (the newest, most drift-prone
reader — `readOperatorSessions`/`buildSpine`/`commitsBetween`), `conversation.server.ts`,
`requests.server.ts`, and all 20 `routes/`.

- Add integration tests using in-memory libSQL + a temp git repo: the three untested
  `.server.ts` and a representative set of route loaders/actions.
- Prioritize `human-input.server.ts` — everything downstream trusts it.

**Acceptance:** the three named server modules and ≥3 route loaders have tests; a
deliberately broken loader fails `npm test`. See [[app-contract]], [[ledger-027-level-set-round]].

**Done (2026-09-05):** Shipped in gated PR dimays/scope-creep-console#17: integration tests for conversation/requests/human-input.server + route entry points; verified a broken loader fails the gate.
