# .claude/agents

The six core C-suite agents are wired here as **Claude Agent SDK subagents** the
harness can invoke by name: `chief-of-staff`, `cto`, `chief-designer`,
`chief-knowledge-manager`, `chief-product-officer`, `chief-reality-officer`.

Plus one standing **functional** agent (not a C-suite exec): `qa-tester` — the
hands-on empirical verifier, Owner-authorized and CoS-ratified (ADR-002,
[`ledger/034`](../../ledger/034-qa-tester.md)). Same thin-loader pattern.

## The loader pattern (single source of truth)

These subagent files are deliberately **thin loaders**, not copies. Each carries
the SDK front-matter (`name`, `description`) and a short system prompt that
establishes identity and a mandatory read-order pointing at the **canonical**
instructions in [`../../agents/`](../../agents/) plus the Charter. The canonical
`agents/*.md` files remain the one source of truth (they also carry the Scope Creep
manifest schema and feed the registry); editing an agent means editing the
canonical file, not this loader.

## Tools & Grants
Loaders currently omit a `tools:` field, so each executive inherits the full
toolset; the human-gate hook (`.claude/hooks/guard-gates.sh`) is the mechanical
backstop on dangerous actions. Finer per-agent Grants are a later refinement
(propose via ADR).
