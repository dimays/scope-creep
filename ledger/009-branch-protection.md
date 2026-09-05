---
name: ledger-009-branch-protection
description: work-003 done — repos made public, mechanical merge-gate ruleset applied, run mode now gated-autonomous.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 009 — Merge gate live (work-003 done)

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Finding (honest)
An **unchecked assumption** cost us steps: branch protection was treated as
available, but classic protection **and** rulesets are gated behind GitHub Pro for
*private* repos on the free plan (verified via two 403s). This is exactly the
failure mode that motivates the new Chief Reality Officer ([[adr-007]]).

## Resolution (Owner decision)
- Owner chose to make **both repos public** (secret-scanned clean first).
- Applied an active `main-gate` **ruleset** to `scope-creep` (id 22317404) and
  `scope-creep-console` (id 22317405): required status check (the CI gate) +
  required PR, block force-push/deletion, **admin bypass** so the Owner keeps
  direct-push flexibility.
- `guard-gates.sh` widened (publish/release).

## Result
`work-003` → **done**. Run mode flips from propose-PR to **gated-autonomous**
([[ticket-cycle]]): CI red now mechanically blocks a normal merge. Next in sequence:
`work-005` (@scope-creep/design).
