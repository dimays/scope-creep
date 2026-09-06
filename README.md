# Scope Creep

A self-generating, self-healing, self-enhancing personal software suite. A small
immutable **control-plane core** (this repo) manufactures, operates, and
continuously rewrites an unbounded **periphery** of personal apps and portable
extensions — built on the Claude Agent SDK.

> The intended scope can grow to infinity. That's the point, and the name.

## What's in this repo (control plane only)

Your manufactured apps live in their **own repos** and are *referenced*, never
vendored here — so this base repo stays cleanly cloneable.

| Path | What |
|---|---|
| `charter/` | The Charter: living [`PRD`](charter/PRD.md), locked [`INVARIANTS`](charter/INVARIANTS.md), [`GLOSSARY`](charter/GLOSSARY.md) |
| `agents/` | The **CEO** (Owner-delegated, atop the org — [ADR-018](standards/adr/018-ceo-and-reorg.md)) + the core C-suite (Chief of Staff, CTO, Chief Designer, Chief Knowledge Manager, Chief Product Officer, Chief Reality Officer) + standing functional agents (QA Tester, Git Manager) |
| `standards/` | [`golden-path`](standards/golden-path.md), [`app-contract`](standards/app-contract.md), [`tech-sops`](standards/tech-sops.md), [`doc-standards`](standards/doc-standards.md), [`engineering-policy`](standards/engineering-policy.md), and ADRs |
| `loops/` | `ticket-cycle`, `request-intake`, `new-app`, `heal`, `core-upgrade` |
| `product/` | Product requirement docs (`*.prd.md`) for the manufactured surfaces |
| `work/` | The ticket backlog (schema in [`work/README.md`](work/README.md)) |
| `registry/` | Generated discovery indexes (never hand-edited) |
| `environments/` | Environment definitions and templates |
| `reference/` | Curated reference data (e.g. the model catalog) |
| `ledger/` | Append-only event log — episodic memory |
| `.claude/` | Agent-SDK wiring: agents, hooks (gate enforcement) |

## The core ideas

- **8 primitives:** Environment, Agent, Loop, Artifact, Registry, Charter, Grant,
  Ledger. **2 compositions:** App, Extension. (See [`GLOSSARY`](charter/GLOSSARY.md).)
- **Single-user, forever.** No auth, no multi-tenancy — ever. Another person clones
  this repo and runs on their own infra + Claude auth.
- **Org structure:** Owner (sovereign) → CEO (direction) → Chief of Staff
  (orchestration) → C-suite & employees. The CEO is Owner-delegated and
  Owner-revocable; the Owner still holds every gate, all spend, and the core
  ([ADR-018](standards/adr/018-ceo-and-reorg.md)).
- **Keep the mutator small and stable; let infinity live in the periphery.**
- **The App Contract is the interface; the stack is an implementation detail.**
- **Blessed stack:** end-to-end TypeScript ([ADR-001](standards/adr/001-blessed-stack.md)).

## Start here (for agents)

Read [`AGENTS.md`](AGENTS.md), then [`charter/INVARIANTS.md`](charter/INVARIANTS.md).
