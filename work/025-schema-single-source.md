---
id: work-025
title: One schema source of truth (Drizzle authoritative) + table-exists test
type: feature
status: done
priority: high
owner: cto
spec: engineering-policy
created: 2026-09-05
updated: 2026-09-05
branch: work-025-schema-single-source
pr: https://github.com/dimays/scope-creep-console/pull/16
---
From the level-set ([[ledger-027-level-set-round]], CTO). The Console has **two schema
sources**: `app/db/index.ts` hand-writes `CREATE TABLE` for 6 tables in `ensureSchema()`,
while `app/db/schema.ts` (Drizzle) declares the same 6 — they can silently diverge, and
`db:generate`/`db:migrate` are wired but unused. `/healthz` only probes `page_visits`,
so a drift in another table stays invisible.

- Make **Drizzle authoritative**: replace `ensureSchema`'s hand-DDL with the generated
  migrations (`drizzle-kit migrate`, already scripted).
- Add a test asserting every table declared in `schema.ts` exists after bootstrap.
- Fix the stale `schema.ts` header ("v0.1 schema. One table.").

**Acceptance:** one schema source; bootstrap runs migrations; a table-exists test guards
every declared table. See [[engineering-policy]], [[ledger-027-level-set-round]].

**Done (2026-09-05):** Shipped in gated PR dimays/scope-creep-console#16: Drizzle is authoritative; `ensureSchema()` applies generated migrations + a table-exists test.
