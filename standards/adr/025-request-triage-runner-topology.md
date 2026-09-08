---
name: adr-025
description: Where the request-triage runner lives and how it reaches each side. The runner straddles two repos — the shared thread store (the console's DB, ADR-024) and ticket-authoring (the scope-creep control plane). Decision — the runner's read/write-back mechanics live in the CONSOLE (reusing its schema + work-064 writers as the single source of truth; no schema fork), ticket-authoring reuses the console's existing controlPlaneRepoDir()+landProposal PR machinery, and the scheduled routine is a claude.ai Code Routine SOURCED FROM scope-creep with the console as a sibling checkout and the ADR-024 remote DATABASE_URL/DATABASE_AUTH_TOKEN in its environment. Triage judgment stays runtime Claude reasoning; the runner never self-merges. PROPOSED (CTO) — escalation-class, holds for the Owner marker.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-07
---

# ADR-025: request-triage runner topology (where the runner lives, how it reaches each side)

- **Status:** **PROPOSED** (CTO, 2026-09-07). Escalation-class ([[adr-022]] trigger (d) — it
  is a core `standards/` ADR); it **holds for the Owner marker** and is not self-merged.
- **Date:** 2026-09-07
- **Deciders:** **CTO** (topology decision, this ADR); **Owner** (ratifies; the routine
  registration + spend ride the [[work-066]] activation, [[adr-016]]/[[adr-024]]).
- **Relates to:** [[prd-request-loop]], [[request-triage]], [[adr-024]] (the shared store this
  reaches), [[adr-016]] (the zero-Claude-call projection this fills in), [[adr-022]]
  (autonomous-merge / escalation — why the runner never self-merges), [[work-064]] (the
  writers it reuses), [[work-065]] (the remote connection), [[work-066]] (the ticket that
  builds it).

## Context

[[work-066]] stands up the [[request-triage]] runner: hourly, with nobody at the keyboard, it
sweeps new Owner request threads, triages each, authors tickets, and writes the outcome back.
The runner **straddles two repos**:

- The **thread data** (read the sweep, write the outcome back) lives in the **console** — the
  `conversations` schema and the [[work-064]] async writers (`postCriticalUpdate` /
  `postNeedsInput`). [[adr-024]] makes that DB the **shared store** the console and this
  routine both read/write (one system, two processes).
- **Ticket-authoring** targets the **`scope-creep` control plane** — `work/NNN` tickets, then
  ticket → PR → (gated) merge.
- The **triage judgment** — decline · counter-propose · accept · fold into a PRD — needs the
  charter, the roadmap, and the specs, which all live in **`scope-creep`**.

So the question this ADR settles is not *whether* to build the runner ([[work-066]] does) but
**where its code lives and how one process reaches both sides** without forking the schema or
smuggling a second datastore client into the core.

## Decision

**Split the runner by source-of-truth, and source the routine from `scope-creep`.**

1. **The read + write-back mechanics live in the console.** `listNewRequestThreads` (the
   sweep) and the write-back wrappers are console code (`app/lib/triage.server.ts`) because
   the thread schema and the [[work-064]] writers are the console's — the **single source of
   truth** for thread data. The runner **reuses** them; it never re-declares the schema or
   the writers anywhere else. (Re-implementing them in `scope-creep` would fork the schema —
   the one thing [[work-066]] explicitly forbids, and a direct violation of "the mutator
   stays small": one datastore client, one dialect, one migration toolchain — [[adr-024]].)

2. **Ticket-authoring reuses the console's existing control-plane authoring path.** The
   console already opens PRs against the core for employee/template scaffolds
   (`authoring.server.ts` → `controlPlaneRepoDir()` + the gated `landProposal` worktree/push/
   `gh pr create` in `sandbox.server.ts`). The runner authors a `work/NNN` ticket through
   that **same** machinery, pointed at `SCOPE_CREEP_HOME`. No new PR mechanism.

3. **The scheduled routine is a claude.ai Code Routine sourced from `scope-creep`.** That is
   the runner's **centre of gravity**: the triage judgment reads the charter/roadmap/specs,
   and tickets + PRs land there. It runs with:
   - the **console checked out as a sibling** (its `app/lib/triage.server.ts` + schema are the
     read/write-back code), and
   - the **remote `DATABASE_URL` + `DATABASE_AUTH_TOKEN`** ([[adr-024]]) in its environment, so
     the console writers operate **directly on the shared store** with no launched session —
     the capability [[adr-016]] left as a read-only projection.

   This mirrors, in reverse, how the console already runs today with `scope-creep` as its
   sibling (`SCOPE_CREEP_HOME`): the two repos meet exactly where they already meet.

4. **The runner is mechanism; judgment stays runtime Claude reasoning.** The CLI
   (`scripts/triage.ts`: `sweep` · `write-back` · `author-ticket`) gives the routine session
   verbs. *Which* verb, with *what* content — decline vs. counter vs. accept — is the session
   reasoning against the [[request-triage]] loop spec, per [[prd-request-loop]]. No decision
   is hardcoded.

5. **The runner never self-merges.** `author-ticket` **stages a gated PR** and stops.
   Auto-merge of a simple accept (Owner disposition Q3, [[adr-022]]) is the **independent-
   review finish line** (author ≠ merger; [[code-reviewer]] → [[qa-tester]] → [[git-manager]]),
   which mechanically enforces the STOP gates. A STOP-gate or new-scope outcome is written
   back as a `needs-input` card that parks the thread on the Owner — never self-authorized.

## Consequences

- **No schema fork; the mutator stays small.** One `conversations` schema, one libSQL/Drizzle
  client, one migration set — the console's — reused by both processes. `scope-creep` gains
  **no** datastore client.
- **No new PR path.** Ticket-authoring rides the console's existing gated `landProposal`
  machinery; the escalation rails ([[adr-022]] path-check, branch protection) apply to the
  runner's PRs exactly as to any other.
- **Deployment is "two sibling checkouts + env".** The routine clones `scope-creep` and the
  console side by side and sets the [[adr-024]] env. This is the same two-repo shape the Owner
  already runs locally, so there is nothing bespoke to operate.
- **Honest degradation carries through.** A remote-store outage surfaces as a non-zero
  `sweep` exit (never an empty list) — [[adr-024]] posture, all the way to the routine.
- **Activation stays Owner-gated.** Live end-to-end needs the provisioned Turso DB
  ([[work-065]]) **and** the registered claude.ai routine ([[adr-016]], runbook step 2). The
  code lands staged and dry-run-testable; nothing activates on merge.

## Alternatives considered

- **Put the runner in `scope-creep`, re-implementing thread DB access there.** Rejected — it
  **forks the schema** ([[work-066]] forbids it) and plants a second datastore client in the
  core, growing the mutator ([[adr-024]] / [[tech-sops]] §1). The whole point of [[adr-024]] is
  *one* client on *one* URL.
- **Console imports `scope-creep` as a package (or vice-versa) for a single in-process
  runner.** Rejected — cross-repo TypeScript imports couple two independently-versioned repos
  and break the clean-clone story ([[invariants]] §6). The sibling-checkout + CLI seam is
  looser and already proven (`SCOPE_CREEP_HOME`).
- **Source the routine from the console instead of `scope-creep`.** Viable, and symmetric to
  option 3. Rejected as the default because the triage *judgment* and the ticket/PR artifacts
  live in `scope-creep`; sourcing there keeps the routine's primary working tree where most of
  its reads and all of its writes-of-record happen, with the console as the data seam. (If a
  future routine is console-centric, sourcing it from the console with `scope-creep` as the
  sibling is the mirror image — the seam is the same.)
- **A thin write API on the console the routine calls over HTTP.** Rejected for the same
  reasons [[adr-024]] rejected it: an always-on server, a new auth surface, and the exact
  indirection [[adr-016]] is removing. A direct scoped-token connection to the shared store is
  the simpler primitive.
