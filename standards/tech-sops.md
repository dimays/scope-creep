---
name: tech-sops
description: The CTO's standing technical standards and SOPs for Scope Creep. How we operate with technical excellence as scope explodes.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# Technical SOPs

Prime directive: **keep the mutator small and stable; let infinity live only in
the periphery.**

## 1. Core / periphery split is law
The control-plane core (this repo) is small and version-pinned. It changes only
via the `core-upgrade` loop: ADR → branch → full core test suite → canary app
rebuild → **Owner approval** → version bump → [[ledger]] entry. Periphery code
never leaks into core.

## 2. The App Contract is the interface
Standardize the interface, not the stack. See [[app-contract]]. The default stack
is [[golden-path]].

## 3. One-command reproducibility
`bootstrap` on a clean clone must work from zero. Lockfiles committed, environment
containerizable. Agents create and destroy environments constantly; non-repro
setup is a defect.

## 4. Test-driven termination
Any loop touching code declares machine-checkable exit criteria (tests + typecheck
+ lint + healthcheck green). Self-heal = a loop whose exit condition is "the
failing check now passes." Nothing merges to an app's `main` without a green gate.

## 5. Gates are enforced by the harness, not by goodwill
`deploy`, spend, `destroy`, publish are human-gated via Claude Code **hooks** +
branch/PR flow (see `.claude/settings.json`). A rule an agent can choose to ignore
is not a control ([[invariants]] §III).

## 6. Environment hygiene
Environments are isolated; no app reaches another's DB, secrets, or filesystem. The
default datastore is **never production**. Secrets live per-environment, never in
the repo, never in Artifacts or [[ledger]] entries.
> Learned constraint: a sibling project once had its local `.env` pointed at a
> production database. The Environment primitive exists precisely to make that
> impossible here.

## 7. Observability & the Ledger
Structured, append-only [[ledger]] entries for every loop run, agent call,
Artifact, and gate decision. Mandatory instrumentation, not optional.

## 8. Versioning & compatibility
Semver for core and extensions. Every extension declares the App-Contract version
it needs; the [[registry|registry]] refuses an incompatible install. The periphery
must not shatter against a moving core.

## 9. Change safety
All work lands via branch + review + gated merge. Everything reversible via git +
[[ledger]]. Agents propose; gates dispose. A PR merge is gated on a **green CI gate +
Owner approval** — once approved, the [[git-manager]] may execute it ([[adr-014]]); the
`deploy` / spend / `delete` / publish gates stay Owner-executed (`guard-gates` hook).
