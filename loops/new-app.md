---
name: new-app
description: The loop that manufactures a new app on the Golden Path, one repo, contract-conformant, with a green test gate.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: new-app

Manufactures a new app repo on the [[golden-path]], conforming to the
[[app-contract]] and [[doc-standards]]. Fully autonomous **except** the gated
steps.

## Inputs (typed)
- `name` (string) — app slug, becomes the repo name.
- `intent` (string) — what the Owner wants the app to do.
- `stack` (enum, default `golden-path`) — or a sanctioned escape.

## Steps
1. **Frame** (Chief of Staff) — restate `intent` as a short brief; pick the room.
2. **Design brief** (Chief Designer) — tokens/primitives from `@scope-creep/design`
   this app needs; any new ecosystem-wide abstraction to propose.
3. **Scaffold** (CTO / employee agent) — from the core template: RR7 + Vite +
   Drizzle/SQLite, the six App-Contract targets, the standard doc bundle + MANIFEST.
4. **Build the first slice** (employee agent) — smallest end-to-end feature.
5. **Test gate** — run `test` (Vitest + `tsc --noEmit` + Biome, **also under Node
   LTS**). Non-zero exit → open the [[heal|heal loop]] and recurse. This is the
   termination oracle.
6. **Register** (Chief Knowledge Manager) — harvest the app's MANIFEST into
   `registry/apps.json`.
7. **Deploy** — `deploy` target. **HUMAN-GATED.** Propose; the Owner disposes.
8. **Record** — append a [[ledger]] entry with the Artifacts produced.

## Termination condition
The test gate is green (exit 0) AND the app exposes all six App-Contract targets AND
its MANIFEST is registered. Deploy is a separate, gated, optional step.

## Outputs (typed)
- `repo` (url) · `manifest` (path) · `ledger_entry` (id) · `test_report` (artifact).
