---
name: adr-024
description: The remote-datastore standard for cloud-writable systems. A Scope Creep system that a cloud routine must read/write becomes remote by pointing its own DATABASE_URL at a per-system remote libSQL (Turso) instance — the existing @libsql/Drizzle client, a connection-string change, not a rewrite. One database PER system (isolation, INVARIANTS §9), single-user (NOT tenancy/auth, §II); Postgres-by-connection-string stays the sanctioned per-app escape (adr-001). First activation: the console's thread store. ACCEPTED as direction (Owner 2026-09-07); provisioning an instance (account + spend) is Owner-gated.
metadata:
  type: reference
  status: accepted
  version: 1.1.0
  owner_agent: cto
  last_verified: 2026-09-07
---

# ADR-024: The remote-datastore standard (cloud-writable systems)

- **Status:** **ACCEPTED** as direction (Owner 2026-09-07, [[prd-request-loop]] Q2). CTO
  sign-off on the platform shape (2026-09-07). **Activation is Owner-gated** — it requires
  an Owner-provisioned hosted instance (a remote libSQL/Turso account + a scoped token, a
  possible recurring spend). The design and the console migration land now; the switch
  flips per-environment when the Owner provisions the instance.
- **Date:** 2026-09-07 (v1.1 broadens v1.0 from "the thread store" to the platform standard)
- **Deciders:** **CTO** (platform decision, this ADR), **Owner** (approves the direction;
  provisions the instance and disposes the spend).
- **Owner-gated:** **yes** — provisioning a hosted instance touches account + spend
  ([[invariants]] §III). Blessing a *specific hosted provider* as a golden-path addition
  ([[golden-path]]) also rides to the Owner alongside that spend.
- **Relates to:** [[adr-001]] (the blessed stack this operationalizes), [[golden-path]],
  [[app-contract]], [[prd-request-loop]], [[request-triage]], [[adr-012]] (the thread
  primitive), [[adr-016]] (the launcher/projection limitation this addresses), [[work-001]]
  (the chatbot extension — the most likely first Postgres escapee), [[work-065]] (the
  console-thread-store ticket that activates this first).

## Context

Scope Creep's premise is unbounded new apps, each potentially needing storage. The
immediate forcing function is the Request Loop: the [[request-triage]] routine is a **cloud
process with no human at the keyboard**, and it must read new request threads and write
outcomes back. Today the org's side of a thread exists **only inside a launched Claude Code
session**, projected back read-only ([[adr-016]] — the loader makes zero Claude calls). So
the org has **no way to write into a thread asynchronously**: any org reply requires the
Owner to open Claude first. That single fact is the root of the "submit-and-forget" gap.

The narrow fix ("make the console's thread DB remote-writable") is real but under-scoped.
The Owner asked for a **platform** decision: as more db-required systems arrive — the
flagship chatbot extension ([[work-001]]), future standalone apps — each will face the same
"can something outside the local process read/write my data?" question. Decide it once, for
the paved road, not per feature.

### What the blessed stack already says

[[adr-001]] / [[golden-path]] bless **SQLite/libSQL via Drizzle ORM — "one file per app;
swaps to Postgres by connection string."** The console already runs `@libsql/client` +
`drizzle-orm/libsql` against `DATABASE_URL` (default `file:./data/app.db`), sqlite dialect,
8 generated migrations. **libSQL is remote-native**: the same client, same dialect, same
migrations talk to a hosted `libsql://…` endpoint given a URL + auth token. Remote is a
connection-string change, not a rewrite. This ADR does not change the stack; it
**operationalizes "remote" and fixes the isolation rule for remote datastores.**

### The invariant that decides the shape

[[invariants]] §9 / the Environment primitive: **"No app may reach another app's database,
secrets, or filesystem namespace. The default datastore is never production."** [[tech-sops]]
§6 carries the war story — a sibling project once pointed its local `.env` at a production
DB. **This is the load-bearing constraint for a data platform**, and it rules out the
tempting "one shared managed database for all systems" design: a single instance whose
tables every app shares is exactly the cross-app reach §9 forbids. The scalable answer is
therefore **one database per system/environment**, remote-capable, provisioned on demand —
which is precisely the "one file per app" model, made remote.

Two clarifications that keep §9 and §II intact:

- **"Shared" here means shared between a system and its own cloud routine**, not across
  apps. The console and the [[request-triage]] routine are **one system, two processes**
  operating on the *console's* threads by design. That is within-environment sharing, not
  the cross-app reach §9 prohibits. Cross-app isolation is preserved because each app gets
  its **own** DB + token.
- **A remote token is infrastructure credential, not a user identity.** One database, one
  Owner, no auth surface in the app — [[invariants]] §II (single-user, no tenancy) holds
  unchanged.

## Decision

**Adopt a per-system remote-datastore standard: a Scope Creep system that must be read or
written from outside its local process points its own `DATABASE_URL` at a dedicated remote
libSQL (Turso) instance.** Concretely:

1. **Remote libSQL is the paved-road remote datastore.** The console (and any future system
   with the same need) keeps the existing `@libsql`/Drizzle client and swaps `DATABASE_URL`
   from `file:…` to a hosted `libsql://…` endpoint + a scoped token held in the
   environment, never in the repo. No driver/dialect/migration rewrite.
2. **One database per system/environment — never a central multi-app DB.** Isolation
   ([[invariants]] §9) is the default unit, exactly as "one file per app" is today. The
   thread store is the *console's* DB; an app's extension uses *that app's* environment DB;
   a projection that owns no data (e.g. the Human-Input Log) provisions nothing.
3. **Local development stays file-based** via the same env var (`file:./data/app.db`). The
   per-environment switch preserves one-command reproducibility ([[tech-sops]] §3) and the
   "default datastore is never production" rule (§9) — local never touches the remote.
4. **Postgres remains the sanctioned per-app escape**, by connection string, for a *single
   system* that genuinely outgrows libSQL — Drizzle supports `pg` natively ([[adr-001]]).
   This is an app-level escape, not a platform migration (see "the runner-up" below).

**First activation:** the console's thread store, so the [[request-triage]] routine can
post an org message and flip a thread to `needs-you` with no launched session ([[work-064]]
wires the writers; [[work-065]] does the connection-string + token + data-copy work). The
platform standard and its first use land together; the switch flips when the Owner
provisions the instance.

This is a **standards operationalization of [[adr-001]]**, not a stack change — so it does
not require re-blessing the stack via `core-upgrade`. The one piece that rides to the Owner
beyond the spend is blessing **Turso specifically** as the default hosted libSQL provider in
[[golden-path]] (recommended; the standard is provider-agnostic if the Owner prefers another
libSQL host or self-hosted `sqld`).

## Consequences

- **Unlocks the async loop:** any cloud routine can address a system's data directly, with
  no launched session and no bespoke per-system API. The Request Loop is the first
  beneficiary; the pattern generalizes to every future db-required system.
- **The mutator stays small.** The core owns *one* datastore client, *one* Drizzle dialect,
  *one* migration toolchain — remote and local are the same code on a different URL. No
  second first-class datastore platform to own deeply (the cost [[adr-001]] rejected).
- **Migration cost is ~zero for the console:** same dialect, same 8 migrations, same
  client; a connection string, a token, and a one-time data copy ([[work-065]]). Contrast a
  platform move to Postgres: rewrite `schema.ts` column builders (`sqliteTable`→`pgTable`),
  regenerate every migration under the `pg` dialect, swap the driver, re-verify history —
  pure cost, for a need no current system has.
- **Introduces a network dependency** on a hosted instance and a possible recurring cost —
  both **Owner-provisioned**, which is why activation is Owner-gated ([[invariants]] §III).
  Until provisioned, the code paths exist behind the env var and the console runs locally.
- **Failure posture:** a system on a remote DB must **degrade honestly** if the remote is
  unreachable — surface the outage, never a silently empty thread list. Carried as
  acceptance on [[work-065]] and adopted as the standard for any remote-DB system.
- **Isolation obligation is explicit:** provisioning a system's remote DB means a *dedicated*
  database + a *scoped* token for that environment only. Reusing one instance across apps is
  a §9 violation and is not permitted.

## Alternatives considered

- **One shared managed Postgres as the data platform for all systems (Neon/Supabase-style).**
  **Rejected as the platform default — on isolation, not cost.** A single instance whose
  tables every app shares is the exact cross-app reach [[invariants]] §9 forbids
  ([[tech-sops]] §6's war story). To use Postgres safely you'd still enforce
  database-per-app on top of it — at which point you've taken on a heavier operational and
  local-dev story (a Postgres container or a shared cloud dev DB, a §9/§6 hazard) and a full
  schema/migration rewrite, to solve a remote-writability need that remote libSQL already
  solves with a connection string. For a single-user org with tiny thread data and no
  multi-writer concurrency, Postgres buys capacity we don't need and costs simplicity we do.
- **Steel-man of Postgres (the runner-up):** Postgres is genuinely the right call the day a
  *specific* system needs concurrent multi-writer workloads, rich cross-table joins over
  large data, real connection pooling for many server processes, or ecosystem features like
  `pgvector` for retrieval. The chatbot extension ([[work-001]]) is the most plausible first
  system to want embeddings. **This is real — and it is exactly why [[adr-001]] kept
  "swaps to Postgres by connection string" as a paved escape.** The right response is to let
  the first system that truly needs it **escape to Postgres per-app**, and to revisit
  blessing Postgres platform-wide only if a *second* system needs it too. Decide the platform
  on today's evidence; keep the escape paved. (Deferring is cheap; a premature platform
  rewrite is not.)
- **Remote libSQL, but one shared DB across systems.** Rejected — same §9 violation as
  shared Postgres. The remote-native win is kept; the isolation unit stays one-DB-per-system.
- **Keep SQLite local and add a thin write API the routine calls.** Viable, and it avoids
  handing a routine a DB token — but it adds an always-on server the routine must reach, a
  new auth surface, and it re-introduces the very indirection [[adr-016]] is removing. It
  also doesn't generalize: every future cloud routine touching any system's data would need
  its own bespoke API. **Folded in as the fallback** if direct DB tokens prove operationally
  undesirable in practice; a directly addressable per-system DB is the simpler general
  primitive.
- **Keep it local-only.** Rejected — it *is* the root cause of the submit-and-forget gap.
