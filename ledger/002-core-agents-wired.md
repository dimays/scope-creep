---
name: ledger-002-core-agents-wired
description: The four core C-suite agents are now callable Agent SDK subagents via thin loaders.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 002 — Core agents wired

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Change
Wired the four core C-suite agents into `.claude/agents/` as Claude Agent SDK
subagents — `chief-of-staff`, `cto`, `chief-designer`, `chief-knowledge-manager` —
now invocable by name.

- **Pattern:** thin **loaders**, not copies. Each subagent's system prompt sets
  identity + a mandatory read-order pointing at the canonical `agents/*.md` file and
  the Charter. Single source of truth preserved ([[doc-standards]]).
- **Tools/Grants:** loaders inherit the full toolset; the `guard-gates.sh` hook is
  the mechanical backstop. Finer per-agent Grants deferred to a future ADR.

## Org-change ratification
Not a new-agent creation — this makes the four already-chartered core agents
executable. Ratified by the Chief of Staff; no INVARIANTS change.
