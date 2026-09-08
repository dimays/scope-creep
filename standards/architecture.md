---
name: architecture
description: A living overview of Scope Creep's architecture — the blessed stack, the control-plane / console / cloud-routine topology, and the data layer (the remote-datastore standard and its cost profile). A projection of the standards; the ADRs and golden-path remain the authorities.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-07
---

# Architecture overview

**In one line:** three planes — a **control-plane repo** (the org's brain and system of
record), the **console** (the app the Owner sees), and **cloud routines** (the unattended
hands) — meet at git and, now, at a shared datastore.

> This page is a **projection of the standards, not a second source of truth.** The
> authorities are [[adr-001]] / [[golden-path]], the other `standards/`, and `registry/*`.
> When an ADR changes the stack or a routine is added, update this page in the same PR.

## The three planes

| Plane | What it is | Holds |
|---|---|---|
| **Control plane** | The org's brain + system of record (this repo) | PRDs, ADRs, `work/`, `ledger/`, agents, loops, generated registries, CI gates |
| **Console** | The app the Owner looks at | React Router SSR app on Fly.io; reads the control plane read-only (Explore/Docs); owns the thread store |
| **Cloud routines** | Unattended cron agents on claude.ai | Clone the repo, run a loop, open PRs |

They meet at **git** (routines open PRs; the console projects the repo read-only) and, now,
at a **shared datastore** (the console and the [[request-triage]] routine share the thread
store).

## The blessed stack

End-to-end TypeScript, ratified in [[adr-001]]; the full table is [[golden-path]]. Short form:

| Layer | Choice |
|---|---|
| Language | TypeScript, end to end |
| Full-app framework | React Router 8 · Vite 8 (pinned exact) |
| Small tools | Bun-run `.ts` |
| Datastore | SQLite / libSQL · Drizzle (one DB per system) |
| Runtime | Bun (dev) · Node LTS (prod); CI tests under both |
| Quality gates | `tsc --noEmit` · Biome · Vitest (Playwright deferred) |
| Design system | `@scope-creep/design` (semver-pinned package) |
| Ship | per-repo Dockerfile · Fly.io |

Apps may escape the paved road but still honor the [[app-contract]].

## The data layer — the remote-datastore standard

**Decision ([[adr-024]], CTO-signed):** a system that must be read or written from outside
its local process points its own `DATABASE_URL` at a **dedicated remote libSQL (Turso)**
instance — one DB per system.

- **Why Turso:** it is the hosted form of **libSQL**, the SQLite fork the console already
  runs through Drizzle. Going remote is a **connection-string + token change, not a
  rewrite** — same client, same dialect, same migrations.
- **Why one-per-system:** [[invariants]] §9 forbids any app reaching another app's database,
  which rules out one shared DB. One-per-system is today's "one file per app," made remote.
  Postgres stays the per-app escape for a system that outgrows libSQL (e.g. the chatbot's
  embeddings, [[work-001]]).

**Local vs. hosted:**

| | Local file SQLite | Turso (hosted libSQL) |
|---|---|---|
| Dollar cost | $0 | ~$0 free tier → ~$5–10/mo if exceeded |
| Async cloud write-back | ✗ impossible | ✓ the whole point |
| Survives a stateless deploy | ✗ ephemeral | ✓ durable, hosted |
| Code change to adopt | — | connection string + token |
| Ops overhead | none | token, outage handling, account |

**Cost:** a single-user thread store is tiny (short text rows, low write volume) and sits in
the free tier — realistically **~$0/month**. Verify current pricing at turso.tech/pricing;
spend is governed by `standards/resource-budget.md` and stays Owner-gated. Because the
standard is per-system, watch the **aggregate** as more systems go remote.

First activation: the console thread store ([[work-065]]), so the [[request-triage]] routine
can write back to a thread with no launched session ([[adr-016]]).

## Cloud routines

Unattended cron agents on claude.ai; the system of record is claude.ai, with
`registry/routines.json` as the repo's memory. **Distinct from local scheduled tasks** (which
run only while the desktop app is open — wrong tool for an unattended org routine).

| Routine | Loop | Cadence |
|---|---|---|
| Roadmap planning | roadmap | 1st & 15th · 14:00 |
| Staffing review | staffing-review | Mondays · 14:00 |
| Org evolve | evolve | Monthly 1st · 14:00 |
| Request triage *(to register)* | [[request-triage]] | hourly · self-tuning |

Cadences **self-tune** within bounds — the live value lives in each loop's latest `ledger/`
cadence-decision block, not hard-coded. Routines can be registered **programmatically** (the
schedule tooling), not only via the claude.ai UI.

## The invariants that shape it

| Rule | Consequence for the architecture |
|---|---|
| **§II** — single-user, forever | No auth, tenancy, or roles. A remote DB token is infra credential, not a user identity. |
| **§9** — app isolation | One datastore per system; the default datastore is never production. |
| **§III** — gates are human-held | deploy · spend · delete · publish are Owner-gated (provisioning a hosted DB is spend). |
| **core changes gated** | The blessed stack changes only via the `core-upgrade` loop with Owner approval. |

## How this stays true

Maintained by the CTO as a **projection of the standards**. Intended to be surfaced
read-only in the console as an **Architecture** tab (ticket forthcoming). A drift-check —
does this overview still match the ADRs it cites? — is a natural CRO self-check, like the
Human-Input Log consistency check ([[adr-010]]).
