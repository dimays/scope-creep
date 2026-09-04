---
name: app-contract
description: The uniform interface every Scope Creep app exposes, regardless of stack. Six lifecycle targets.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# The App Contract

The one rule that makes "blessed default, polyglot allowed" governable:
**standardize the interface, not the implementation.** Every app repo — blessed
or [[golden-path|escapee]] — exposes the same six named targets (as `package.json`
scripts, a `justfile`, or a `Makefile`), so the loop runner treats any stack as an
interface. This is mandated by [[invariants]] §IV.

## The six lifecycle targets

| Target | Contract | Golden-Path implementation | Gate |
|---|---|---|---|
| **bootstrap** | Clean clone → runnable, one command | `bun install` (from committed `bun.lock`) → `drizzle-kit migrate` | — |
| **test** | Non-zero exit = the self-heal loop's failing condition | `vitest run` + `tsc --noEmit` + `biome check` (+ Playwright smoke); **also run under Node LTS in CI** | — |
| **run** | Start the app locally / in prod | dev: `react-router dev` · prod: `node ./build/server.js` | — |
| **deploy** | Ship outward | `fly deploy` | **human-gated** (irreversible/outward-facing) |
| **healthcheck** | Liveness + version + dependency status | `GET /healthz` → `200 {status, version, db}` | — |
| **destroy** | Tear down the app and its resources | `fly apps destroy` + drop volume/repo | **human-gated** (irreversible) |

## Rules

1. **The names are fixed.** The loop runner never special-cases a framework; it
   calls these six names. An escapee implements them however its stack demands.
2. **`test` is the self-heal oracle.** A loop that modifies an app terminates when
   `test` goes from non-zero to zero. No merge to an app's `main` with a red gate.
3. **`deploy` and `destroy` are always human-gated** — enforced by hooks + review
   flow, never by agent goodwill ([[invariants]] §III, [[tech-sops]]).
4. **`healthcheck` is machine-readable** so the loop runner and the platform can
   both consume it.
5. **Every app ships the standard doc bundle** alongside the contract (see
   [[doc-standards]]).
