---
name: doc-standards
description: The Chief Knowledge Manager's day-1 documentation standards. Discovery is deterministic and generated, never hand-maintained.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-04
---

# Documentation Standards

The whole game: **discovery is deterministic and generated, never hand-maintained.**
If a human or agent must *maintain* an index, it drifts and the system rots.

## 1. Every first-class thing carries a manifest
Machine-readable front-matter (this file has one). Required fields:
`name, description, metadata.{type, status, version, owner_agent, last_verified}`.
`type` ∈ `user | feedback | project | reference`. `status` ∈
`proposed | active | deprecated`. Cross-link related docs with `[[name]]`.

## 2. The Registry is *generated* from manifests
A build step harvests every manifest into `registry/*.json`. The index can never
lie because nobody writes it by hand. See [[registry]].

## 3. Fixed filenames = convention over search
Every app repo ships the identical bundle at known paths, so an agent never hunts:
`PRD.md`, `README.md`, `ARCHITECTURE.md` (+ numbered ADRs in `adr/`),
`USERGUIDE.md`, `AGENTS.md`, `CHANGELOG.md`, `MANIFEST`.

## 4. Two registers, marked
Agent-facing docs are precise, imperative, contract-shaped. Human-facing docs
(for the Owner) are narrative. Each declares its audience. The PRD is dual and
sectioned.

## 5. The living PRD is supersede-not-destroy
Every PRD section is stamped `proposed | active | deprecated`; changes supersede
and are recorded (git + [[ledger]]). It grows to infinity without losing memory.
Contrast [[invariants]], which is locked.

## 6. ADRs are the memory of *why*
Numbered, immutable-once-accepted (`standards/adr/`). A self-modifying system must
never re-litigate settled decisions. Template: `adr/000-template.md`.

## 7. RAG only when convention breaks (the "as necessary" rule)
Start with deterministic discovery: fixed filenames + generated registry + grep.
Add embeddings / vector search **only** when catalog size makes lookup actually
fail. Do not build it prematurely. State the trigger in the ADR that proposes it.

## 8. Docs are testable
`last_verified` on every manifest; a maintenance loop flags staleness; a doc-lint
runs in CI. A doc that can drift silently is a bug.
