---
name: engineering-policy
description: The CTO's standing best-practices policy — CI, bug/self-heal loops, PR health, commit hygiene, refactoring, tech-debt escalation, environment promotion, and honest test definitions.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# Engineering Policy

Standing rules for how Scope Creep writes and ships code. Complements
[[tech-sops]] (architecture) and [[app-contract]] (interface). Applies to every
app, blessed or escapee.

## 1. CI is the referee
- CI runs the App-Contract `test` target on every branch and PR: `typegen + tsc +
  biome + vitest` (and, per Golden Path amendment #3, **under Node LTS too**, not
  only Bun). Red = merge blocked. No override by an agent; only the Owner may waive.
- CI also runs the healthcheck against a built artifact where feasible.
- A green gate is necessary, not sufficient — see §6 on honest tests.

## 2. Bug discovery & the self-heal loop
- **Every bug fix begins with a failing test that reproduces it.** Red → fix →
  green. The regression test is the proof and the guard against recurrence.
- A CI failure auto-opens the [[heal]] loop (budgeted recursion); on budget
  exhaustion it escalates to the Owner with the diagnosis and attempts — never
  silently gives up, never merges red.
- Bugs found in review or in use become tracked work items (see §5), not
  fix-and-forget.

## 3. Pull-request health
- **One PR, one purpose.** If a PR needs the word "and" to describe it, split it.
- Every PR: states intent, links the PRD/spec section it serves, notes risk, and
  says how it was verified. Passes the gate before merge.
- Small PRs over large ones, always — a reviewer (human or agent) must be able to
  hold the whole diff in their head.

## 4. Commit hygiene
- **Atomic commits:** one logical change each, independently revertible, message
  says *why* not just *what*. Prefer many small commits over one large one.
- Never mix a refactor with a behavior change in the same commit (see §5).
- No secrets, no generated artifacts, no data files in commits ([[tech-sops]] §6).

## 5. Refactoring & tech debt
- **Refactors are behavior-neutral and kept separate** from feature/bugfix changes.
  A refactor must leave the gate green with no behavior delta.
- Small boy-scout cleanups inline are welcome; anything larger is split into its own
  PR.
- **Tech debt is flagged, not silently carried.** Mark it in code as `DEBT:` with a
  one-line why, and open a tracked debt work item (§ project management). Debt items
  are **escalated to the CTO**, who folds them into the appropriate dev cycle rather
  than letting agents fix ad hoc or ignore. Escaping the road (an [[golden-path|Escapee]])
  or accepting debt are both **recorded decisions**, not defaults.

## 6. Honest test definitions
- **Tests assert intended behavior per the PRD/spec — not whatever the code
  currently does.** A test written to make a red gate green by encoding the bug is a
  policy violation.
- A test must be able to *fail* for the right reason: no tautologies, no asserting
  mocked values, no `expect(true)`.
- Coverage follows behavior: test the contract and the edges a user/PRD cares about,
  not lines for their own sake.
- When behavior legitimately changes, the test changes *with a spec change to point
  to* — never a quiet edit to dodge a failure.

## 7. Environments & promotion
- Three environments: **dev** (local; SQLite file; the default datastore, never
  production), **staging** (a deployed instance behind an edge perimeter, non-prod
  data), **prod** (the host the Owner owns).
- **Promotion is one-directional: dev → staging → prod.** Each step requires a green
  gate; **staging → prod is human-gated** ([[invariants]] §III). No direct-to-prod,
  ever.
- Config and secrets are per-environment and isolated ([[tech-sops]] §6). No app
  reaches another environment's data.

## 8. Everything observable
Every CI run, gate decision, promotion, and escalated debt item appends to the
[[ledger]]. If it mattered, it's replayable.
