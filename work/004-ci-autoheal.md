---
id: work-004
title: Auto-open the heal loop on CI failure (no-spend launcher path)
type: feature
status: proposed
priority: low
owner: cto
spec: engineering-policy
created: 2026-09-04
updated: 2026-09-06
---
When CI goes red, get a heal attempt moving without waiting on a human — **without any
API spend** (Owner directive 2026-09-06: "defer the CI auto-heal and/or rewrite it so
that it doesn't require any API spend").

**Reframed to the [[adr-016]] projection+launcher pattern (zero metered calls):**
- A CI-failure signal (workflow `on: failure` → a lightweight webhook/dispatch, or the
  Console polling `gh run` status) opens a **heal ticket** and raises a **"needs-you"**
  item with a **`claude://` launcher** that seeds a [[heal]]-loop conversation in the
  Owner's already-paid Claude session — the heal runs there, not in a metered cloud agent.
- No `ANTHROPIC_API_KEY` in CI, no scheduled cloud routine for this, no per-run billing.
- The failing check, the diagnosis stub, and the run URL are projected into the Console
  so the launch is one click with full context.

**Deferred (needs explicit Owner spend approval, not in scope here):** the fully
autonomous in-CI agent runner (Claude auth in the runner, budgeted, escalates on budget
exhaustion). That path drives metered API cost and stays **blocked on Owner authorization**
per [[invariants]] §7. See [[ledger-050-adr-022-activated]].

**Acceptance (no-spend path):** a red gate opens a heal ticket + a launcher that resumes
a seeded heal conversation in the Owner's Claude session; nothing bills against an API key.
