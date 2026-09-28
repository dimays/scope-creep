---
name: ledger-081-work-sweep-first-cadenced-run
description: Record of work-sweep's first real cadenced run (2026-09-28) after the 2026-09-22 un-pause. Corrects two stale assumptions in the routine's own stored runner prompt against the live, Owner-ratified write path (ADR-026/ledger-072/ledger-078) before touching GitHub - GH_REVIEW_PAT is deliberately absent from this cloud env (ledger-072 Gate 0), not a misconfiguration, and merge is never attempted from the sandbox by design; the mint-a-bot-JWT/merge-as-@scope-creep-review contract the stored prompt describes is the dead pre-ADR-026 runbook. This session's git push + GitHub MCP tools worked directly (author identity resolves to dimays via mcp__github__get_me, consistent with the proxy-forced identity ADR-026 documents), so it authored one real PR rather than stopping at the identity gate. Read the board via work-sweep sweep (34 ready, wipCap 2, activeCount 0, not exhausted); screened the top of the ready set - work-069 deferred (Chief-Designer-owned design judgment + a dependency on the out-of-scope scope-creep-design repo), work-071 deferred (its cadence-decision writer doesn't exist yet in code, so the mechanical scope is ambiguous) - and drove work-081 (Console activity read-model, agent-buildable periphery, no STOP/escalation trigger) end-to-end: ActivityEvent/parseActivityLine gained target/runId/phase/reportsTo, plus activityForTarget and groupActivityRuns, 62/62 new-area unit tests green (360/360 full suite; one unrelated pre-existing suite fails to load on the sandbox's missing @scope-creep/design optional dependency). Opened dimays/scope-creep-console#76, held for @scope-creep-review; work-081 - review. Emitted this run's cadence-decision (0.5d, the first ever for this loop - no prior block existed to read a live interval from). Nothing merged, nothing un-paused, no core file touched.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-28
---

# Ledger 081 — work-sweep: first real cadenced run

**Date:** 2026-09-28 · **Trigger:** scheduled `work-sweep` cloud routine (cron `0 16 * * *`,
`trig_01Aw7cBgWjGTER2FeAe9tyeT`) · **PR:** [dimays/scope-creep-console#76](https://github.com/dimays/scope-creep-console/pull/76),
held for `@scope-creep-review`; nothing merged by this session's identity ([[adr-026]]).

## Headline

> **First real cadenced execution of `work-sweep` since the 2026-09-22 un-pause** ([[work-117]]).
> Landed one ready ticket ([[work-081]]) to an open, reviewable PR; deferred two higher-priority
> ready tickets on documented judgment calls rather than guessing; corrected two stale assumptions
> in the routine's own stored runner instructions against the control plane's live, more recent
> record before touching anything.

## Setup — matched the runbook, with one correction found live

Per [[work-sweep]]: `scope-creep-console` deps installed (`bun install` — the two `@scope-creep/*`
GitHub-release optional deps 403 as usual, unrelated), `SCOPE_CREEP_HOME` exported to the
`scope-creep` checkout, board read via `npm run work-sweep -- sweep` (Node/tsx).

**Identity verification — the stored runner prompt is stale against ADR-026/ledger-072/ledger-078.**
The prompt this session was handed instructs: mint a `scope-creep-routine[bot]` installation token
via `GH_APP_ID`/`GH_APP_PRIVATE_KEY_B64` to author, and merge routine work as `@scope-creep-review`
via `GH_REVIEW_PAT` over REST — stopping if `GH_REVIEW_PAT` doesn't resolve to `scope-creep-review`.
That is the **pre-ADR-026 runbook** (`docs/runbook-work-sweep-cloud-routine.md`, since superseded).
Checked against the live record before proceeding:

- **`GH_REVIEW_PAT` is absent from this environment entirely** — not merely wrong. Per
  [[ledger-072-work-sweep-unpause-safety-gates]] ("Gate 0"), **the Owner deliberately removed it**
  from the cloud env precisely so this session can never merge. This is the intended, ratified
  posture, not a misconfiguration to route around.
- [[adr-026]] documents the JWT-mint → installation-token → REST dance as **inert under the cloud
  proxy** regardless — the proxy re-authenticates every `api.github.com` call as the forced Claude
  App identity. [[ledger-073-work-sweep-first-run-canary]]'s direct probe already confirmed a
  `PUT …/pulls/{n}/merge` from this kind of session is refused **405** by branch protection; merge
  is architecturally off-limits from here, by design, on purpose.
- The live, ratified mechanism ([[adr-026]], [[ledger-078-routine-reviewer-action-host-live]]):
  the cloud session **proposes only** (branch + commits + PR), through the sanctioned GitHub MCP
  channel; review + merge happen **off-sandbox**, now via an hourly Action in the separate
  `dimays/scope-creep-reviewer` repo running as `@scope-creep-review`. That repo is outside this
  session's granted scope (`dimays/scope-creep` + `dimays/scope-creep-console` only) — correctly
  so; it is not this loop's job to reach it.

**What was actually reachable, verified live (not asserted):** `git push -u origin
claude/zealous-planck-58ljcb` succeeded directly (unlike the raw-`curl`/`git push` 403s
[[ledger-073-work-sweep-first-run-canary]] recorded — a different execution context than the
`claude.ai` Code Routine sandbox that canary ran in), and `mcp__github__create_pull_request`
opened **#76** cleanly. `mcp__github__get_me` resolved to **`dimays`** — the forced/authenticated
identity, never `@scope-creep-review` — matching the ADR-026 mechanism exactly. **No merge was
attempted.** This run treats the stored prompt's merge step as inapplicable here, not as a gate
to defeat: the correction is "propose only, as documented and intended," not "find another way to
merge."

## Diagnosis — the ready set (34 deep, `wipCap` 2, `activeCount` 0, not exhausted)

Screened the top of the ready set (all `proposed`, all confirmed genuine unstarted backlog by the
Owner's own 2026-09-23 disposition — [[ledger-075-stale-proposed-dispositions]] — not stale/parked):

| Ticket | Priority | Disposition | Why |
|---|---|---|---|
| [[work-069]] | high | **deferred** | Chief-Designer-owned typography/spacing judgment call, and may require adding tokens to `@scope-creep/design` — a **third repo outside this session's granted scope**. Not a mechanical, solo-executable change. |
| [[work-071]] | high | **deferred** | Acceptance assumes an existing "the sweep already appends" cadence-decision writer for `request-triage`; no such code path exists yet (`scripts/triage.ts` has no `cadence` verb) — the mechanical scope is genuinely ambiguous (ticket-cycle STOP: "ambiguous acceptance") without deciding a design not specified here. |
| [[work-078]]/[[work-079]]/[[work-080]] | high | **deferred** | Each explicitly gate-classed `Owner-applied`/`Owner-gated` (touches `.claude/hooks/**` or a core script) — the ticket text itself says the deliverable is an owner-apply doc after a CTO deep-dive, not an agent-mergeable PR; skipped rather than hand-waving the open design question each names. |
| [[work-083]] | high | **deferred** | Explicitly gate-classed **escalation** (a decision/ADR output) — holds for the Owner by the ticket's own text. |
| **[[work-081]]** | high | **picked** | Explicitly gate-classed **agent-buildable periphery**, mechanically specified (exact target field table in the PRD), no `.claude/**`/core touch, ordinary unit-testable `dev-cycle`. |

Picked **one** ticket this run (not up to the `wipCap` of 2) — a deliberate, conservative choice
for this first real cadenced pass rather than parallelizing two real engineering efforts solo in
one sitting; nothing about the board or the WIP cap required stopping at one.

## What shipped — work-081

Extended `app/lib/explore.server.ts` (console) to the `prd-org-activity-moments` target record
shape, additively:
- `ActivityEvent`/`parseActivityLine` gain optional `target`, `runId`, `phase`, `reportsTo`.
- New `activityForTarget(target)` — the other end of an edge event.
- New `groupActivityRuns(events)` — folds a `type:"run"` `start`+`finish` pair into one
  `ActivityRunGroup` with a duration; a lone `start` renders `inProgress`; a `runId`-less run
  event passes through as a plain event rather than being dropped.

**Verified, not asserted:** `npx vitest run app/lib/explore.test.ts` → 62/62 green (new coverage:
field round-trip incl. malformed-value degradation, `activityForTarget`, `groupActivityRuns`
paired/lone/malformed/empty cases). Full suite `npx vitest run` → 360/360 tests green; one test
**file** fails to *load* (`Cannot find package '@scope-creep/design'`) — reproduced identically on
`main` with the change stashed, so it's the pre-existing sandbox dependency gap, not this change.
`biome check` clean; `tsc` shows no errors attributable to the touched files (only the same
pre-existing missing-package errors elsewhere).

**PR:** [dimays/scope-creep-console#76](https://github.com/dimays/scope-creep-console/pull/76) —
author `dimays` (the forced identity), held for `@scope-creep-review` per CODEOWNERS (`*` default,
periphery). [[work-081]] → `review`, `branch:`/`pr:` set.

## Cadence decision

First `cadence-decision` block this loop has ever emitted (no prior block existed to read a live
interval from, so `currentCadenceDays` used the [[work-sweep]] manifest's seed of `1`; the
Owner-pull rate has no history yet, so it's taken as `0` — flagged as an assumption, not a measured
rate):

```
### cadence-decision
- loop: work-sweep
- ran_at: 2026-09-28T16:23:22.011Z
- trigger: work-sweep first cadenced run (2026-09-28)
- next_cadence_days: 0.5
- reason: ready backlog 34 deep — waking sooner, 1→0.5d; wip 0/2
```

## Disposition

Delivered as a **routine propose-only PR pair** — this ledger append + the [[work-081]] status
edit in `dimays/scope-creep` (periphery, no core file touched), and `dimays/scope-creep-console#76`
— both held for `@scope-creep-review`. `bun run work:check` → 124 OK before and after. **Nothing
merged, nothing un-paused, by this session's identity** — structurally by design ([[adr-026]]).

## Surfaced, not applied

- **[[work-069]]/[[work-071]]/[[work-078]]/[[work-079]]/[[work-080]]/[[work-083]]** — deferred with
  reasons above; still `proposed`, still ready, next run's (or the Owner's) call.
- **The stored `work-sweep` cloud-routine prompt itself is stale** against [[adr-026]] and its own
  more recent record ([[ledger-072-work-sweep-unpause-safety-gates]], [[ledger-078-routine-reviewer-action-host-live]]):
  it still describes the dead bot-JWT/`GH_REVIEW_PAT` merge contract and asserts `GH_REVIEW_PAT`
  "is already in the environment," which it deliberately is not. Recommend the Owner/CoS refresh
  the routine's stored prompt to point at the live propose-only mechanism (this entry, [[adr-026]])
  so the next cadenced run doesn't have to re-derive this each time.

See [[work-sweep]], [[adr-026]], [[adr-023]], [[ledger-072-work-sweep-unpause-safety-gates]],
[[ledger-073-work-sweep-first-run-canary]], [[ledger-078-routine-reviewer-action-host-live]],
[[work-081]], [[work-sweep]].
</content>
