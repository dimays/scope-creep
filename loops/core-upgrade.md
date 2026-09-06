---
name: core-upgrade
description: The only way the immutable control-plane core changes — ADR, tests, canary, Owner approval, version bump, Ledger.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: core-upgrade

The governed path for changing the core — including the core agents "immutable
except for targeted upgrades" ([[invariants]] §I.4).

## Inputs (typed)
- `proposal` (ADR draft) — the change and its rationale.

## Steps
1. **Propose** — write an ADR ([[doc-standards]] §6); mark `proposed`.
2. **Branch** — implement on a branch; never on `main` directly.
3. **Core test suite** — full green gate on the control plane.
4. **Canary** — rebuild a canary app against the changed core; confirm it still
   passes its own App-Contract `test`.
5. **Owner approval** — **HUMAN-GATED.** The Owner accepts the ADR.
6. **Land** — merge, bump the core semver, mark the ADR `accepted`, append a
   [[ledger]] entry.

## Termination condition
Either merged with Owner approval + green core suite + green canary, OR rejected
(ADR marked `superseded`/closed with reason in the Ledger). Always terminal.
