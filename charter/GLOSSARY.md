---
name: glossary
description: The locked lexicon of Scope Creep. Every agent uses these terms with these exact meanings.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-06
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
- **The agent org — four tiers** ([[adr-020]]). Every agent is exactly one `kind`:
  **Executives** (`kind: core`), **Standing function agents** (`kind: function`),
  **Employees** (`kind: employee`), and **Templates** (`kind: template`). The tiers below
  define each.
- **Executive / C-suite / core agents** (`kind: core`) — the permanent, immutable-except-by-upgrade
  leadership that holds *direction* and domains: the Owner-delegated **CEO** atop the agent
  org ([[adr-018]]), plus the six C-suite — Chief of Staff, Chief Designer, CTO, Chief
  Knowledge Manager, Chief Product Officer, Chief Reality Officer.
- **Standing function agent** (`kind: function`) — a **permanent, cross-org function**
  that holds *execution*, not a domain, and is **not** summoned per-ticket like an employee:
  the **QA Tester** (proof-by-running) and the **Git Manager** (lands approved work). They
  live in the core repo and change only by [[core-upgrade]], like the executives; `function`
  names the role type, not a weaker governance class. See [[adr-020]].
- **Employee agent** (`kind: employee`) — an **ephemeral/transitory** Agent spun up by an
  executive for a scoped need, **instantiated from an Employee template** and **reporting
  to** the executive that created it; its creation is ratified by the Chief of Staff. It is
  **staffed** to work by listing its slug in a work item's `assignees`, and **retired**
  (status → `retired` + a reason, never deleted) when the work is done — consistency lives in
  the template, not in a long-lived worker. See [[adr-017]], [[adr-020]], and [[staffing]].
- **Employee template** — a **stable-but-mutable**, off-the-shelf **role archetype** (`kind:
  template`, e.g. Frontend Engineer, Researcher) an executive selects from to spin up an
  Employee agent. It carries the role's operating manual, its `owner_agent` executive, and
  defaults including a **model preset** ([[resource-budget]] tier); when none fits, an
  executive may create or modify one (a gated change). Templates are agents' *classes*;
  employee agents are their *instances*. See [[staffing]].
- **The App Contract** — the six lifecycle targets every app exposes, regardless
  of stack.
- **The Golden Path** — the blessed default stack. See [[golden-path]].
- **Escapee** — an app that has siphoned off the Golden Path onto another stack. It
  still honors the App Contract.
