# Owner-manual steps — activate the Request Loop ([[prd-request-loop]])

The Request Loop ships as **docs + tickets** in this PR (the PRD, [[adr-024]], the
[[request-triage]] loop spec, `work-063`…`068`). Nothing in the diff changes runtime
behavior — it's the plan of record. Two activation steps **cannot** ship in a PR diff and
are yours to perform, because both touch things agents are gated out of by design: a hosted
account + spend ([[invariants]] §III), and the claude.ai routine registry ([[adr-016]]).

This file is the checklist. Do them **in order**, and only when you're ready to spend —
until you do, the code paths land behind an env var and the console keeps running locally.

---

## Owner-manual step 1 — provision the remote thread store (activates [[adr-024]] via [[work-065]])

The [[adr-024]] decision (CTO-signed): a **dedicated remote libSQL (Turso) instance per
system**, not one shared DB. This first instance is the **console's** thread store, so the
[[request-triage]] routine can read/write the same threads the console serves — one system,
two processes ([[invariants]] §9 preserved: the DB is dedicated to the console's
environment, not shared across apps).

1. **Create a Turso account** and a **dedicated database** for the console (e.g.
   `scope-creep-console`). This is the spend + account step — Owner-only.
2. **Mint a scoped auth token** for that database only (least privilege — it must not reach
   any other system's DB). Keep it in the console's deploy environment, **never in the
   repo**.
3. **Set the console's env:** `DATABASE_URL=libsql://<db>.turso.io` and the auth-token var
   the `@libsql` client expects. Same client, same Drizzle sqlite dialect, same 8
   migrations — no rewrite ([[adr-024]]).
4. **Migrate your existing local rows.** Your current `file:./data/app.db` holds real
   thread history. Either copy it into the new instance (one-time dump/restore) or start
   clean — your call. `work-065` carries the exact steps + the honest-degradation behavior
   (a remote outage must surface, never a silently empty thread list).
5. **Leave local dev on a file DB** (`DATABASE_URL=file:./data/app.db`) — the switch is
   per-environment, so local never touches the remote ("default datastore is never
   production", §9).

> **Golden-path ratification (optional, yours):** the CTO recommends blessing **Turso** as
> the default hosted libSQL provider in [[golden-path]]. The standard is provider-agnostic
> (any libSQL host or self-hosted `sqld` works), so this is a small doc PR to ratify
> alongside the spend — not a blocker.

---

## Owner-manual step 2 — register the `request-triage` cloud routine (activates [[work-066]])

The routine is a **claude.ai Code Routine** — the system of record for cloud routines is
claude.ai, not this repo ([[adr-016]]). It cannot be created from a PR; you (or the CoS on
your behalf) register it once the loop code from [[work-066]] lands.

1. At **https://claude.ai/code/routines**, create a routine pointing at
   `github.com/dimays/scope-creep`, running the [[request-triage]] loop.
2. **Cron: hourly to start** (e.g. `0 * * * *`) — your disposition Q4. The frequency then
   self-tunes within bounds via the [[work-067]] cadence-decision protocol; don't hand-tune
   it after this.
3. **Model:** `claude-sonnet-5` (matches the other scheduled routines).
4. **Record it in `registry/routines.json`** — a small follow-up PR adding the entry with
   the real `trigger_id`, `cron`, `cadence_bounds_days`, and `manage_url`, alongside
   `staffing-review` / `roadmap` / `evolve`. This is memory of a real routine, so it's added
   **after** the routine exists (never a fabricated `trigger_id` ahead of one).

> **Sequencing:** step 2 depends on the Phase-2 code ([[work-065]], [[work-066]]) being
> merged and the thread store from step 1 being live — a routine with nowhere to write
> back is inert. Register it when Phase 2 lands, not before.

---

## What does NOT need you

Phase 1 ([[work-063]] unread/notifications, [[work-064]] the write-back wiring) is ordinary
in-app work in the console repo — no spend, no account, no gate. It can start as soon as
this PR merges and does not wait on either step above.

---

## Residual (honest)

- **Nothing is autonomous until you provision.** Both steps are real Owner actions (spend +
  account, and the claude.ai registry). The org proposes and stages; it cannot flip these
  for you ([[invariants]] §II–III). The merge of this PR is escalation-class ([[adr-022]]
  trigger d — it touches `standards/`, `loops/`, `registry/`); it lands on your
  `owner-approved` marker.
- **Isolation is now a standing obligation.** Every future remote-DB system gets its **own**
  dedicated instance + scoped token. Reusing one instance across apps would violate §9 — a
  guard for this is a sensible later addition, out of scope here.
