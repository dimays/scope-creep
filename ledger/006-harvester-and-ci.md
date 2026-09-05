---
name: ledger-006-harvester-and-ci
description: Registry harvester built (registries now generated); CI wired for the control plane and the Console.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 006 — Harvester & CI

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Delivered
- **Registry harvester** (`scripts/registry-build.ts`): the sole writer of
  `registry/*.json`. Generates agents.json from `agents/*.md`; reconciles
  apps/extensions from registration records (validating referenced manifests).
  Deterministic output; `registry:check` is a CI-ready "in sync?" gate. All three
  registries flipped to `_generated: true`. The Console's consistency view
  reflected it live: drift dropped from 11 to 1 (the intentional `[[adr-NNN]]`
  template placeholder).
- **CI wired** ([[engineering-policy]] §1):
  - Control plane — `.github/workflows/registry.yml` runs `registry:check` on
    push/PR (fails if registries drift from manifests).
  - Console — `.github/workflows/ci.yml` runs the App-Contract `test` gate under
    Bun, then vitest under **Node LTS** (Golden Path amendment #3), then a
    production build.

## Honest boundaries (follow-ups)
- CI currently runs on push/PR as a tripwire. **Enforcing red-blocks-merge** needs
  PR flow + branch protection; the Owner pushes to `main` directly today. Toggle
  when PRs are adopted.
- **Auto-opening the heal loop on CI failure** ([[engineering-policy]] §2) needs an
  agent runner with Claude auth in CI — a larger automation, deferred.
