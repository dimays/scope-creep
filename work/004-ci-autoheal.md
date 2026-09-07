---
id: work-004
title: Auto-open the heal loop on CI failure (no-spend launcher path)
type: feature
status: dropped
priority: low
owner: cto
spec: engineering-policy
created: 2026-09-04
updated: 2026-09-07
---
> **DEFERRED — Owner decision 2026-09-07 (status `dropped` = not being pursued now;
> revive if the trigger below fires).** The Owner's concern: not to re-introduce an
> approve/click-every-time bottleneck after [[adr-022]] removed per-PR approval. On
> examination the feature is **low-value now**:
> - **The dev-cycle already self-heals in-flight failures.** [[dev-cycle]] Stage 4
>   (the [[code-reviewer]] cycle) iterates *review → QA → debug* until CI is green
>   **before** a PR is handed off to land — so a red check mid-development never reaches
>   the Owner; it's fixed in the same working session. work-004 only covers the leftover
>   case (a flaky failure, or red on `main` post-merge), which is **rare**.
> - **No "automatic + free + LLM-heal" exists** — automatic LLM execution always costs
>   *something*: metered API $ (the deferred in-CI runner, [[invariants]] §7), or a
>   first-party cloud trigger that burns the Owner's Claude usage/limits. The launcher's
>   human click is precisely what keeps the no-spend path free.
> - Because the trigger is **rare** (not per-PR), even the click path is not the
>   PR-approval treadmill the Owner is avoiding.
>
> **Revive trigger:** if red-CI-on-`main` (or dev-cycle-escaped failures) becomes a
> recurring annoyance. **Then build:** the **cloud-trigger** path (a GitHub Action on
> failure → a first-party cloud Claude session that heals + opens a fix PR) — automatic,
> no metered API bill (subscription-usage), the one shape worth the plumbing. The
> metered in-CI runner stays behind explicit Owner spend approval regardless.

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
