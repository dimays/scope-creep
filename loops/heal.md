---
name: heal
description: Self-heal loop — recurse on a failing check until it passes or the budget is exhausted, then escalate to the Owner.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: heal

The canonical self-healing loop. Its exit condition is literally "the failing check
now passes."

## Inputs (typed)
- `target` (repo path) — the app to heal.
- `failing_check` (enum) — `test | typecheck | lint | healthcheck`.
- `budget` (int, default 5) — max recursion depth before escalation.

## Steps
1. **Reproduce** — run the failing check; capture the exact error (file:line).
2. **Diagnose** (employee agent) — read source, form a hypothesis.
3. **Patch** — smallest change that could fix it, on a branch.
4. **Re-gate** — run the check. Green → go to 6. Red → decrement `budget`; if
   `budget > 0` recurse to 2, else go to 5.
5. **Escalate** — budget exhausted: append a [[ledger]] entry and surface to the
   Owner with the diagnosis and attempts. Stop.
6. **Land** — merge via review; append a [[ledger]] entry. Never merge with a red gate.

## Termination condition
The `failing_check` returns exit 0, OR `budget` reaches 0 (escalate). Always terminal.
