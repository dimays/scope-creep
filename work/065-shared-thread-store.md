---
id: work-065
title: Shared remote libSQL thread store (cloud-writable conversations DB)
type: debt
status: proposed
priority: high
owner: cto
spec: adr-024
created: 2026-09-07
updated: 2026-09-07
---
Implement [[adr-024]] — the **first activation of the remote-datastore standard**. Point the
console's `DATABASE_URL` at a **dedicated** remote libSQL (Turso) instance so the console and
the [[request-triage]] routine — **one system, two processes** — read/write the **same**
threads. This is the unlock for asynchronous write-back: without it, "submit and forget"
can't post back without the Owner launching Claude. One database, one user — **not** tenancy
or auth ([[invariants]] §II preserved); the DB is dedicated to the console's environment, not
shared across apps (§9 preserved).

Build:
- Console runs against a remote libSQL endpoint via the existing `@libsql` client (no
  driver/dialect/migration rewrite — same sqlite dialect, same generated migrations); a
  scoped token, dedicated to this environment, lives in env, not in the app.
- Local development keeps a file DB via the same env var (per-environment switch).
- Honest degradation: if the remote is unreachable, surface the outage — never a silently
  empty thread list.
- Migration of the Owner's existing local rows (one-time copy, or a clean start — Owner's
  call).

**Activation is Owner-gated** — it needs an Owner-provisioned instance (account + a possible
recurring spend, [[invariants]] §III). The code paths land behind the env var; the switch
flips when the Owner provisions it.

**Acceptance:** the console reads/writes a remote libSQL instance; a process outside the
console writes a thread message the console then serves; local dev still works via a file
DB; a remote outage is surfaced, not hidden. See [[adr-024]], [[adr-016]].
