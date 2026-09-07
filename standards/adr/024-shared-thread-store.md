---
name: adr-024
description: A shared, remote, cloud-writable thread store for the console's conversations DB — so a scheduled cloud routine can write back to a thread without the Owner launching a Claude session. Points DATABASE_URL at a remote libSQL instance; single database, single user (NOT tenancy/auth, INVARIANTS §II preserved). ACCEPTED as direction (Owner 2026-09-07); activation requires an Owner-provisioned instance (account + spend), Owner-gated.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-07
---

# ADR-024: A shared, cloud-writable thread store

- **Status:** **ACCEPTED** as direction (Owner 2026-09-07, [[prd-request-loop]] Q2).
  **Activation is Owner-gated** — it requires an Owner-provisioned hosted instance
  (a remote libSQL account + a scoped token, a possible recurring spend). The design and
  the migration land now; the switch flips when the Owner provisions the instance.
- **Date:** 2026-09-07
- **Deciders:** **Owner** (approves the direction; provisions the instance), CTO (design).
- **Owner-gated:** **yes** — provisioning a hosted instance touches account + spend
  ([[invariants]] §III).
- **Relates to:** [[prd-request-loop]], [[request-triage]], [[adr-012]] (the thread
  primitive), [[adr-016]] (the launcher/projection whose limitation this addresses),
  [[work-065]] (the ticket).

## Context

Threads are rows in the console's local libSQL/SQLite (`conversations` /
`conversation_messages`, [[adr-012]]). The org's side of a thread, today, exists **only
inside a launched Claude Code session**, projected back read-only ([[adr-016]] — the
loader makes zero Claude calls). So the org has **no way to write into a thread
asynchronously**: any org reply requires the Owner to open Claude first. That single fact
is the root of the "hacked together" feel — it blocks submit-and-forget, because the
[[request-triage]] routine (a cloud process, no human at the keyboard) has nowhere to post
its outcome.

For the routine to read new requests and write outcomes back, it and the console must
share **one** threads database, reachable from outside the local console process.

## Decision

**Point `DATABASE_URL` at a shared remote libSQL instance.** libSQL is remote-native
(the console already uses the `@libsql` client), so this is a connection-string change,
not a rewrite. Both the console and the cloud routine's environment hold a scoped auth
token and read/write the same `conversations` tables.

Explicitly: **one database, one user.** This is not tenancy, accounts, or roles — there is
still exactly one Owner and no auth surface in the app ([[invariants]] §II holds). The
remote token is infrastructure credentials, not a user identity.

Local development keeps a file DB via the same env var, so the switch is per-environment.

## Consequences

- **Unlocks the whole loop:** the routine can post an org message and flip a thread to
  `needs-you` with no launched session ([[work-064]] wires the writers; this ADR gives
  them a shared place to write).
- **Introduces a network dependency** on a hosted instance, and a possible recurring cost
  — both **Owner-provisioned**, which is why activation is Owner-gated. Until provisioned,
  the code paths exist behind the env var and the console keeps running locally.
- **Migration:** the Owner's existing local rows are real history. A one-time copy into the
  remote instance (or a clean start, Owner's call) is part of [[work-065]].
- **Failure posture:** the console must degrade honestly if the remote is unreachable
  (surface the outage, never a silent empty thread list) — carried as acceptance on
  [[work-065]].

## Alternatives considered

- **Routine authors a file the console projects (no shared DB).** Rejected: re-introduces a
  projection lag and isn't a true write-back — the same class of indirection [[adr-016]]
  already imposes, which is what we're removing.
- **Console exposes a write API the routine calls.** Viable, and avoids handing the routine
  a DB token — but it adds an always-on server the routine must reach and a new auth
  surface. Folded in as the fallback if a direct DB connection proves undesirable in
  practice; the direct connection is simpler for a single-user, single-DB system.
- **Keep it local-only.** Rejected — it *is* the root cause.
