---
name: golden-path
description: The blessed default stack for Scope Creep apps. End-to-end TypeScript. Ratified in ADR-001.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# The Golden Path (blessed stack)

Ratified in [[adr-001]] after a CTO + Chief Designer huddle. This is the *paved
road* — the default with the deepest core tooling. Apps may siphon off (become an
**escapee**) but must still honor the [[app-contract]].

## The stack

| Layer | Choice | Why (short) |
|---|---|---|
| Language | **TypeScript**, end to end | One compiler-checked language from control plane to DOM. No forced language boundary. |
| Full-app framework | **React Router 7** (framework mode) on **Vite** | Explicit typed `loader`/`action` data contracts; SSR shell + real client runtime; state-preserving HMR. |
| Small-tool path | **Bun**-run `.ts` files | Native TS, zero build; `bun build --compile` for a single binary. |
| Datastore | **SQLite / libSQL** via **Drizzle ORM** | One file per app = perfect isolation; schema is TypeScript, checked by `tsc`; swaps to Postgres by connection string. |
| Dev/test/scripts | **Bun** | Fast, native TS. |
| Prod runtime | **Node LTS** | Sidesteps Bun's 2026 production blockers. |
| Tests | **Vitest** (+ **Playwright** smoke) | Jest-API corpus is huge; agents write idiomatic tests. |
| Typecheck / lint / format | `tsc --noEmit` + **Biome** | One fast binary; the compiler is the self-heal oracle. |
| Design system | **`@scope-creep/design`** (core-owned package) | See amendment #1 below. |
| Container | Per-repo multi-stage **Dockerfile** | Reproducible; prod on Node LTS. |
| Deploy | **Fly.io** | Simple single-user ops; per-app app + volume. |

## CoS ratification amendments (binding)

These three amendments were added by the Chief of Staff when reconciling the CTO
and Chief Designer memos. They override the raw CTO recommendation where they
conflict.

1. **The design system is a published, semver-pinned package — not shadcn
   copy-in.** shadcn's default "paste components into each repo" model would let
   many one-per-repo apps silently fork taste. Instead: a **core-owned
   `@scope-creep/design`** package ships *runtime CSS-variable tokens* + a curated
   set of *headless accessibility primitives*; every app pins it by semver and
   adopts fixes centrally. shadcn is a *source we vendor into the core package*,
   never a per-app copy. (Honors Designer constraints #1 and #2.)
2. **The embeddable-widget style-isolation pattern is a day-1 standard.** The
   chatbot extension mounts into a **Shadow DOM** root and reads the *host's* CSS
   variables for theme (light/dark, accent) while scoping its own internals so
   host and widget styles never bleed. Owned by the Chief Designer. (Honors
   Designer constraint #5.)
3. **The `test` gate runs under the production runtime too.** Because dev is Bun
   and prod is Node LTS, CI must run `test` under **Node LTS**, not only Bun, so we
   never ship a Bun-only green. (Dev/prod parity.)

## Designer constraints this stack must keep honoring

Runtime CSS-variable tokens · semver-pinned shared design package · client-capable
hybrid rendering (not server-template-only) · state-preserving live preview as a
hard gate · style-isolated, theme-inheriting embeddable widget. Any future change
that breaks one of these is a regression, not a refactor.

## Sanctioned escapes (not the default, but blessed when justified)

Next.js and SvelteKit for full apps; Python/FastAPI or Django for a
heavily-ML/agent-orchestration backend. An escapee carries its own tooling and
still exposes the six App-Contract targets.
