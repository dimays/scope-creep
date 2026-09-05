---
name: ledger-011-design-package
description: work-005 done — @scope-creep/design shipped and consumed by the Console via a gated PR.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 011 — @scope-creep/design (work-005 done)

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Delivered ([[golden-path]] amendment #1)
- **`scope-creep-design`** repo (public): the shared runtime CSS-variable token
  layer + `token()` + the first headless primitive (`VisuallyHidden`). Own green
  gate (tsc + biome + vitest), CI, and `main-gate` ruleset. Tagged **v0.1.0**.
- **Console 0.4.0** consumes `@scope-creep/design/tokens.css` pinned `#v0.1.0` via a
  git dependency and dropped its inline `--sc-*` copy. Look unchanged; tokens now
  centralized + versioned.

## First gated-autonomous cycle
Landed via the new flow: branch → **PR #1** → required CI check **passed** → merge →
branch deleted. The merge gate worked as designed (never merged red).

## Decisions (surfaced for the Owner)
- **Distribution = git tag**, not npm publish (no publish needed, works with public
  repos, semver via tags). Reversible — say so if you'd prefer npm.
- **CRO in practice:** the git-dep mechanism was *verified* (installed + resolved)
  before building on it, not assumed.

## Next in sequence
`work-006` — the feedback Extension (proves the portable-graft mechanism on a small
surface before the flagship `work-001`).
