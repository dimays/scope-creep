---
name: prd
description: The living product-requirements document for Scope Creep. Grows and supersedes over time.
metadata:
  type: project
  status: active
  version: 0.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Scope Creep — Living PRD

> This document is **alive**. Sections carry a status (`proposed | active |
> deprecated`) and are superseded, never silently deleted — history lives in git
> and the [[ledger]]. Contrast with [[invariants]], which is locked. The whole
> point of the name: the intended scope can grow to infinity.

## Vision `active`

A self-generating, self-healing, self-enhancing personal software suite that does
whatever the Owner wants, whenever they want it. A small immutable **control-plane
core** (C-suite agents + registries + a loop runner, built on the Claude Agent
SDK) manufactures, operates, and continuously rewrites an unbounded **periphery**
of personal apps and portable extensions.

The thing that builds the software is itself software the system can modify — so
the discipline is: **keep the mutator small and stable; let infinity live only in
the periphery.**

## The end-user `active`

Exactly one human: the Owner, fully trusted. There is no second user, ever
([[invariants]] §II). Safety work protects the Owner from the *agents'* mistakes
and from prompt injection — not users from each other.

## Core abstractions `active`

The 8 primitives and 2 compositions are defined in [[glossary]]. Apps are born and
destroyed freely; the core stays tiny.

## The agent org `active`

Immutable core C-suite: **Chief of Staff** (orchestration + org ratification),
**Chief Designer** (design systems + delight), **CTO** (architecture + technical
standards), **Chief Knowledge Manager** (docs, registries, discovery). Executives
staff employee/app-bound agents as needed; the CoS ratifies ([[adr-002]]).

## The blessed stack `active`

End-to-end TypeScript. Recorded in [[adr-001]]; standard in [[golden-path]].
Polyglot escape is allowed via the [[app-contract]].

## Roadmap `proposed`

1. **v0 — the seed (this repo).** Charter, core agents, standards, App Contract,
   and one runnable loop (`new-app`) so the factory can build its first app.
2. **v1 — the Console (first manufactured app).** The end-user surface —
   `scope-creep-console`, its own repo, dogfooding the `new-app` loop end-to-end on
   the Golden Path. Local-first now; later a persistent host the Owner owns behind
   an edge perimeter. See [[adr-003]]. (The *operator* surface is the Agent SDK
   harness and stays headless.)
3. **v2 — the chatbot extension.** The portable "edit-this-app-in-a-live-preview"
   extension, honoring the Designer's style-isolation standard.
4. **v3 — self-heal loop in anger.** A failing check auto-opens a heal loop that
   terminates when the check passes.
5. **v4 — the registry/discovery layer matures.** Generated registries across many
   apps; RAG only if/when deterministic discovery breaks down (see [[doc-standards]]).

## Open questions `proposed`

- Where does the Ledger physically live long-term (flat files vs SQLite vs a small
  service)? Seeded as append-only markdown; revisit when volume demands.
- How are Grants represented concretely (a signed token vs a policy file vs hook
  config)? Seeded as documented policy + hook enforcement; formalize in v1.
