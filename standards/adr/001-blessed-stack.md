---
name: adr-001
description: The blessed default stack is end-to-end TypeScript (React Router 8, Drizzle/SQLite, Bun+Node, Vitest, Biome, Fly.io).
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# ADR-001: The Blessed Stack is End-to-End TypeScript

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** CTO (lead), Chief Designer (constraints), Chief of Staff (ratified)
- **Owner-gated:** yes (Owner commissioned the decision)

## Context
Scope Creep needs one paved-road stack that maximizes, in priority order:
agent-authorability, single-user simplicity, reproducibility/isolation, UI ambition
+ portable design system, extension portability, polyglot escape, and 2026 longevity.
The stack must not silently cap the product experience. The CTO ran current research;
the Chief Designer fenced off five hard design constraints; the CoS reconciled.

## Decision
Bless a single-language, statically-typed **TypeScript** factory:
- **Full-app path:** React Router 7 (framework mode) on Vite; SSR shell + client
  runtime; UI from the core-owned `@scope-creep/design` package.
- **Small-tool path:** Bun-run `.ts` files; `bun build --compile` for a binary.
- **Data:** SQLite/libSQL via Drizzle ORM (one file per app; swaps to Postgres by
  connection string).
- **Toolchain:** Bun (dev/test/scripts) + Node LTS (prod runtime); Vitest +
  Playwright; `tsc --noEmit` + Biome; per-repo Dockerfile; Fly.io deploy.

Full stack table and the three binding CoS amendments live in [[golden-path]].

## Consequences
- **Wins:** the compiler is the self-heal oracle (`tsc`/Drizzle catch shape/query
  bugs pre-runtime); one language from control plane to DOM (no forced boundary);
  React design-system + chatbot extension stay same-language; huge coherent corpus.
- **Amendments (binding):** (1) design system is a semver-pinned `@scope-creep/design`
  package, not shadcn copy-in; (2) the embeddable widget uses Shadow DOM + host CSS
  variables; (3) the `test` gate also runs under Node LTS in CI; (4) the full-app
  framework is **React Router 8 on Vite 8** (bumped from RR7/Vite7), **pinned to exact
  versions**, ratified as a gated core-upgrade on 2026-09-05 ([[work-028]],
  [[ledger-029-rr8-core-upgrade]]); **Playwright is deferred** — the `test` gate is
  `tsc` + Biome + Vitest until an end-to-end need is identified.
- **Risks accepted (and mitigations):** RR7 less-trodden than Next.js → pin versions,
  core-owned template, gated framework upgrades. TS config footguns → one core-owned
  base `tsconfig`/Biome config, apps extend never author. SQLite outgrows a file →
  Drizzle swaps to Postgres; `/healthz` surfaces DB pressure early.

## Alternatives considered
- **Python (FastAPI/Django)** — steel-manned (owns AI ecosystem, readable, great
  backend). Rejected for the paved road: every full app becomes polyglot by
  construction (UI + design system are JS/TS anyway), gradual types are a weaker
  self-heal oracle, and it doubles the toolchain the core must own deeply.
- **Next.js** — rejected as default: corpus fractured across three eras, RSC/caching
  footguns, version churn. Remains a sanctioned escape.
- **SvelteKit** — near-parity, but React's design-system corpus is deeper for the
  portable-UI requirement. Sanctioned escape.
