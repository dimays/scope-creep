---
name: ledger
description: The append-only event log — episodic memory and the substrate of self-healing. Never rewrite history.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger

The append-only record of everything consequential: loop runs, agent invocations,
Artifacts produced, org changes, and gate decisions ([[invariants]] §III.8). You
cannot heal what you cannot replay.

- **Append only.** Never rewrite an entry; supersede with a new one.
- **No secrets.** Never write credentials or sensitive data here ([[tech-sops]] §6).
- **Format (v0 seed):** one markdown file per entry, `NNN-slug.md`, newest wins.
  Physical storage may migrate to SQLite/a service later (see [[prd]] open questions).
