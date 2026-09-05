---
name: prd-console-explore
description: Product requirements for "Explore" — understanding Scope Creep (docs, agents, ledger, consistency) from inside the Console, without touching code.
metadata:
  type: project
  status: active
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-04
---

# PRD — Console "Explore"

> **v1 shipped** in `scope-creep-console` 0.2.0 (2026-09-04): docs browser, agent
> profiles with ledger-derived contributions, timeline, and the consistency view.
> Roadmap items below remain proposed.

## The user problem
The Owner wants to understand *what is being built and how* — and spot what's
out-of-sync or unexpected — **through the Console, without getting close to the
codebase.** Today that knowledge lives only in files in the control-plane repo.
As scope grows, "read the repo" stops scaling as a way to stay oriented.

## Goal & success signal
Give the Owner a first-class way to learn about the platform from inside the app.
**Success:** the Owner can answer "what did the org decide, who did it, and is
anything drifting?" without opening the repo — and reaches for the Console *first*.
We'll know it works by usage: Explore views get visited, and the Owner catches a
drift/inconsistency here before noticing it in code.

## v1 scope (smallest slice that teaches us)
All read-only, sourced from the control plane via `SCOPE_CREEP_HOME` (same pattern
as the dashboard):

1. **Docs browser** — navigable rendering of the Charter, standards, ADRs, and
   PRDs (markdown → readable pages), with `[[wikilink]]` resolution so the Owner can
   follow the graph the agents follow.
2. **Agent profiles** — a page per agent: its charter, status, and a
   **contributions view derived from the [[ledger]]** (decisions ratified, loops
   run, artifacts produced). See "On evals" below.
3. **Timeline / ledger** — the chronological event & decision history (genesis →
   stack decision → console → …), filterable by agent and type.
4. **Consistency / "what's out of sync"** — the highest-value view: surfaces
   drift automatically — manifests with a stale `last_verified`, registries still
   `"_generated": false` (hand-seeded), apps whose gate/health status is unknown,
   `[[wikilinks]]` with no target, ADRs marked `proposed` but never resolved.
   This is what lets the Owner "catch the unexpected" at a glance.

## On evals (be honest)
"Agent performance evals" is a real ambition but v1 does **not** invent scores.
Real scoring needs defined success criteria per agent, which is a CPO + CKM
project. v1 ships **transparent contribution history** (what each agent actually
did, from the ledger) — the substrate any future eval is built on. We add
quantitative evals only once we've defined what "good" means for each role, and we
record that definition as an ADR.

## Feedback hooks (seed of the feedback Extension)
Each Explore view carries a lightweight, non-nagging prompt at natural moments —
e.g. after reading an ADR, "Is this decision still what you want?"; on the
consistency view, "Flag this as unexpected." These answers append to the ledger and
feed the roadmap. This is the first concrete step toward the in-app feedback
mechanism, which we expect to generalize into a portable Extension.

## Metrics
Instrument which Explore views are visited and which items the Owner flags. These
metrics — not opinion — drive what Explore becomes next.

## Out of scope (v1)
Editing anything from the Console; triggering loops; agent chat. Explore is
read-and-understand first; acting-from-the-Console comes later.

## Dependencies / notes
- Benefits from the **registry harvester** (generated registries) so the
  consistency view has clean inputs.
- The ledger is currently markdown; v1 may add a small machine-readable index so
  the timeline and contribution views are cheap to build. (CTO + CKM.)
- Design stays minimal (the Owner likes it) and token-driven, built to grow.
