---
name: adr-010
description: The Human-Input Log is a generated projection (owns no data) — a Console union-read over existing systems of record, plus a terminal-capture hook writing a new human-input/ NDJSON set.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# ADR-010: Human-Input Log architecture

- **Status:** accepted (architecture) — but **v1b implementation is Owner-gated** (it
  touches `.claude/` + adds a core record set; needs Owner approval + `core-upgrade`).
- **Date:** 2026-09-05
- **Deciders:** CPO + CTO (memos), Chief of Staff (ratified), Owner (directed the feature)

## Context
The Owner wants one timeline of every human input. Naively that invites a central
telemetry store in the core — the Scope-Creep trap.

## Decision
- **The log owns no data — it's a generated projection.** The Console is a **union
  reader** merging: (a) in-app surfaces already in its DB (`conversation_messages`
  role=owner, `request_messages` author=owner, `feedback`) via live queries; (b) a new
  control-plane **`human-input/`** record set for the terminal surface; (c) **interludes**
  derived from git commits + `ledger/` in each window. No sync, no duplication.
- **Terminal capture = a `UserPromptSubmit` hook** appending one NDJSON line per Owner
  prompt to `human-input/YYYY-MM.ndjson`. Mechanical (rides the harness, not agent
  goodwill). The only truly-automatic option for that surface.
- **NDJSON, one file per month** — a documented **Escapee** from the one-file-per-entry
  + frontmatter convention ([[engineering-policy]] §5), justified: terminal inputs are
  frequent + append-concurrent.
- **Self-policing:** the Consistency view gains checks — work/merges in a window with no
  preceding captured input (missed input / uninstalled hook), and dup ids.
- **Split:** v1a (read-model, periphery, no gate) ships first; v1b (hook + `human-input/`
  reader + Consistency checks) is the Owner-gated core change.

## Consequences
- A real log ships now (v1a) over what's already captured; the richest surface (terminal)
  lands behind one approval (v1b).
- Honest boundaries: automatic where the harness enforces it, convention/backfill
  elsewhere. Redaction guard so a pasted secret never lands in `human-input/`.

## Alternatives considered
- **One physical table everything writes to** — rejected: duplication, sync, drift; puts
  telemetry in the core.
- **Agent-appended "log this input" convention as the spine** — rejected: asks the
  observed to observe itself, silently misses inputs. Fine as backfill only.
- **Ledger-derived inference of inputs** — rejected: the ledger is work-summaries, lossy
  and revisionist for input capture.
