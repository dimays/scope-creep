---
name: glossary
description: The locked lexicon of Scope Creep. Every agent uses these terms with these exact meanings.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-04
---

# GLOSSARY (locked lexicon)

Precise, shared words are how an unbounded system stays coherent. These terms
mean exactly what is written here, everywhere in Scope Creep. Changing a
definition is a Charter-level change, not a casual edit.

## The 8 primitives (irreducible)

- **Environment** — the isolation boundary. A namespace of resources, secrets,
  filesystem, and datastore. *Everything* runs inside exactly one. Nothing crosses
  an environment boundary except as an Artifact.
- **Agent** — an instructed actor: instructions plus a set of Grants. Capabilities
  are not baked in; they are granted.
- **Loop** — the only unit of process: typed inputs → steps (which may invoke
  Agents and sub-Loops) → typed outputs, plus a mandatory termination condition.
  "Autonomous / partially-autonomous / manual" is one property — how many steps
  are human-gated — not three kinds of thing.
- **Artifact** — a typed, addressable, versioned unit of work-product that flows
  between Loops and Agents (a diff, a doc, a design-token set, a decision, a test
  result). The blood of the system.
- **Registry** — the discovery primitive: a *generated* index mapping stable names
  to resolvable things. Never hand-maintained.
- **Charter** — the governing document set: the living PRD plus the locked
  INVARIANTS. What an agent reads to know "what are we, and what may I not do."
- **Grant** — a capability token: "Agent X may do Y in Environment Z, [requiring
  human confirmation]." How infinity stays safe.
- **Ledger** — the append-only event log; the system's episodic memory and the
  substrate of self-healing.

## Compositions (built from primitives — not primitive themselves)

- **App** — an Environment + a Registry entry + a bundle of Artifacts (code/docs)
  + optional bound Agents + Extension slots, all conforming to the Charter. One
  repo per app.
- **Extension** — a *portable* bundle of (Artifacts + Agents + Loops) that grafts
  onto an App's Environment. The flagship example is the chatbot that edits an app
  live in a preview and merges the change.

## Governance terms

- **The Owner** — the single human. The source of all authority.
- **C-suite / core agents** — the immutable-except-by-upgrade orchestrating agents:
  Chief of Staff, Chief Designer, CTO, Chief Knowledge Manager.
- **Employee agent** — an agent spun up by a C-suite executive for a scoped need;
  its creation is ratified by the Chief of Staff.
- **The App Contract** — the six lifecycle targets every app exposes, regardless
  of stack.
- **The Golden Path** — the blessed default stack. See [[golden-path]].
- **Escapee** — an app that has siphoned off the Golden Path onto another stack. It
  still honors the App Contract.
