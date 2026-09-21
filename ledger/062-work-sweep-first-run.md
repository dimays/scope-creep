---
name: ledger-062-work-sweep-first-run
description: First scheduled run of the work-sweep autonomous execution loop (work-086 / prd-autonomous-execution-loop), fired manually as a supervised validation on 2026-09-21. Outcome — BLOCKED, nothing built, nothing merged. The loop behaved safely and honestly: it verified identities before touching anything, diagnosed the exact config problems, wrote a needs-you card, backed the cadence off to 7 days, and refused to route around blocked write paths (work-091 honored by the loop itself). Records the findings and the fixes queued as work-092 (board reconciliation) and work-093 (routine hardening). Re-authored on main because the routine's own commit was stranded in the read-only cloud session and could not be pushed.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-21
---

# Ledger 062 — work-sweep first run (supervised validation)

**Date:** 2026-09-21 · **Trigger:** `Work sweep` (`trig_01Aw7cBgWjGTER2FeAe9tyeT`), manual
`Run now` · **Run:** `cse_01Tnci99q4zXFWgxZE6GbYFL` · **Outcome:** **BLOCKED — no ticket built,
no PR opened, nothing merged.**

## What the loop did right (the validation's real payoff)
- **Read the specs first**, then **verified both GitHub identities before building anything**.
- **Built and merged nothing**; wrote a `needs-you` card to thread #9 (the DB write-back path
  works — different credential from GitHub); emitted a `cadence-decision` backing off to 7 days.
- When every GitHub write path returned 403, it **refused to keep retrying** — *"I won't keep
  retrying the same blocked path… flagged for you to act on rather than route around."*
  [[work-091]] (fail-closed, no gate-bypass) honored by the autonomous loop itself.
- The runner CLI (`work-sweep -- sweep`) works in the cloud; the sweep produced a real ready set.

## Findings (all fixes queued)
1. **`GH_REVIEW_PAT` authenticates as `dimays`, not `@scope-creep-review`** — the reviewer
   identity the live CODEOWNERS require; `dimays` is reserved for escalation. → [[work-093]].
2. **`GH_APP_INSTALLATION_ID` holds the App client_id, not the numeric installation ID** — the
   bot installation token can't mint (404). JWT/app auth itself works. → [[work-093]].
3. **No working GitHub write from the sandbox** — `git push` is proxied through the read-only
   Claude GitHub App (403); `api.github.com` REST is reachable, so the fix is REST-based
   authoring with a correctly-minted bot token. → [[work-093]].
4. **Stale work board / WIP cap** — 4 tickets `active` against a WIP cap of 2 (`work-086`/`087`
   merged but never flipped to `done`; `work-058`/`059` shipped/parked), so no new work could
   start. → [[work-092]].
5. **Env/prompt polish** — `gh` not pre-installed (downloaded each run); `npm ci` fails on the
   console's `bun.lock` (fell back to `npm install`); the prompt's `sweep <base> <head>` example
   was inaccurate (real: `sweep [--floor …]`). → [[work-093]].

## Correction (2026-09-21) — findings #1 and #2 were misdiagnoses
> Findings **#1 (`GH_REVIEW_PAT` reads as `dimays`)** and **#2 (`GH_APP_INSTALLATION_ID` wrong)**
> were read as misconfiguration. They are **not.** A definitive diagnostic
> ([[ledger-066-cloud-sandbox-proxy-identity-wall]]) proved the cloud sandbox's egress proxy
> **overrides the outbound `Authorization` header** and forces its own read-only GitHub App identity
> (`dimays`) — a valid PAT, an invalid token, and no token all returned the same identity. The
> Owner's `GH_REVIEW_PAT` was **always correct** (= `scope-creep-review`); repasting/regenerating it
> would have changed nothing. Finding **#3 (no working write path)** stands and is now explained by
> the same proxy. The real fix is a write-path **redesign**, [[work-096]] — not an env change.

## Disposition
Board reconciliation shipped as **[[work-092]]** (done, PR #90). Routine hardening **[[work-093]]**
landed its code (PR #91) but its end-to-end acceptance is **blocked** by the proxy wall above and
superseded by **[[work-096]]**. The routine must not run unattended until [[work-096]] lands. See
[[ledger-066-cloud-sandbox-proxy-identity-wall]], [[prd-autonomous-execution-loop]].
