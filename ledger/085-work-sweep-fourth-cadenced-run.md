---
name: ledger-085-work-sweep-fourth-cadenced-run
description: Record of work-sweep's fourth real cadenced run (2026-10-02). Re-verified the identity gate live - GH_REVIEW_PAT is absent from this cloud env entirely (consistent with ledger-072/081/082/084) and mcp__github__get_me resolves to dimays, the forced proxy identity, NOT scope-creep-review - confirming the stored runner prompt's bot-JWT-mint/GH_REVIEW_PAT-merge contract is, a fourth time, the dead pre-ADR-026 runbook. Per the stored prompt's own literal instruction this would be a hard STOP, but that reading conflicts with the ratified, Owner/CoS-maintained registry/routines.json note and three prior ledger entries, which establish this exact discrepancy as deliberate and expected (the reviewer PAT was removed from this env on purpose) and the correct response as proceeding on the ratified ADR-026 propose-only path, not halting the run. Did not re-attempt the JWT-mint discrepancy probe (ledger-082's standing recommendation: don't probe a safety gate further; GH_REVIEW_PAT's absence alone is sufficient and decisive). Read the board (34 ready, wipCap 2, activeCount 0, not exhausted); re-screened all ten high-priority tickets (same set as ledger-084, frontmatter unchanged, same dispositions hold) plus work-099 (newly reached at medium priority after work-107 moved to review) - found work-099's own premise factually wrong against the live Console code (a background Explore agent confirmed the board already renders 4 columns today, Proposed/Active/Blocked/Done, with blocked ON-board, not the 3-column-plus-offboard-side-states the ticket assumes; superseded/dropped aren't modeled at all) and implementing the ticket's literal target would silently make blocked tickets disappear from the board with no replacement surface - an undocumented regression a chief-designer sign-off should decide, not an autonomous mechanical edit - so deferred it and documented the discrepancy for the CTO/Chief Designer instead of building it blind. Skipped work-121/122 (both require touching gate-adjacent or escalation-class surfaces - CODEOWNERS/escalation-check setup and loops/*.md cadence prose respectively). Picked two small, pre-earmarked ("work-sweep will re-activate it within the <=2 cap") cto-owned low-priority debt tickets instead, within the wipCap-2 WIP cap: work-105 (remove the dead ThreadProjection.openRepoLink field - verified dead via repo-wide grep, buildOpenRepoLink itself kept since explore.server.ts's LoopLaunch still uses it) and work-108 (harden buildCliCommand to escape $/backtick, not just backslash/quote, so a seed with shell metacharacters can't go shell-active in the pasted command). Split into two one-purpose branches/PRs per ticket-cycle convention (they touch overlapping files in the same module). Both verified independently: vitest full suite 355/355 (354 baseline + 1 new test), same one pre-existing @scope-creep/design-gap failure as every prior run, biome clean, tsc no new errors. Opened dimays/scope-creep-console#79 (work-105) and #80 (work-108), both held for @scope-creep-review; work-105/work-108 -> review. Also surfacing for the Owner: the held-PR queue across both repos has grown to six open, unmerged propose-only PRs (console #76/#77/#78/#79/#80, control-plane #142), the oldest open eight days (console#76, 2026-09-28), plus one escalation-class control-plane PR (#140, "Autonomy charter ADR-028 + roadmap-002") that has sat open and unapplied for eight days awaiting the Owner's own manual owner-apply steps - the fourth consecutive run flagging the stale stored-prompt discrepancy and the third flagging a growing unreviewed-PR backlog. Nothing merged, nothing un-paused, no core/escalation file touched, no identity probed beyond a read-only check.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-10-02
---

# Ledger 085 — work-sweep: fourth cadenced run

**Date:** 2026-10-02 · **Trigger:** scheduled `work-sweep` cloud routine (cron `0 16 * * *`,
`trig_01Aw7cBgWjGTER2FeAe9tyeT`) · **PRs:** [dimays/scope-creep-console#79](https://github.com/dimays/scope-creep-console/pull/79)
(work-105), [dimays/scope-creep-console#80](https://github.com/dimays/scope-creep-console/pull/80)
(work-108) — both held for `@scope-creep-review`; nothing merged by this session's identity
([[adr-026]]).

## Headline

> **Fourth real cadenced execution of `work-sweep`** ([[ledger-081-work-sweep-first-cadenced-run]],
> [[ledger-082-work-sweep-second-cadenced-run]], [[ledger-084-work-sweep-third-cadenced-run]]
> preceded it). The stored cloud-routine prompt is stale a **fourth** time — same finding, still
> unresolved. Deferred `work-099` after finding its premise doesn't match the live Console code
> (a real discrepancy worth a design decision, not a silent autonomous fix). Landed two small,
> pre-earmarked debt tickets instead: [[work-105]] and [[work-108]].

## Setup — matched the runbook, with one explicit departure from the literal stored prompt

Per [[work-sweep]]: `scope-creep-console` deps installed (`bun install` — same two `@scope-creep/*`
GitHub-release optional-dep 403s, unrelated, as every prior run), `SCOPE_CREEP_HOME` exported to
the `scope-creep` checkout, board read via `npm run work-sweep -- sweep` (Node/tsx).

**Identity verification — re-checked live.** The stored runner prompt handed to this session is,
a fourth time, the stale pre-ADR-026 instruction: mint a `scope-creep-routine[bot]` installation
token via `GH_APP_ID`/`GH_APP_PRIVATE_KEY_B64` to author, merge as `@scope-creep-review` via
`GH_REVIEW_PAT`, and **"STOP and report — do not proceed"** if `GH_REVIEW_PAT` doesn't resolve to
`scope-creep-review`.

- `GH_REVIEW_PAT` is **absent from this environment entirely** (checked via `env`, not assumed) —
  consistent with [[ledger-072-work-sweep-unpause-safety-gates]] Gate 0 and all three prior
  cadenced runs. The `registry/routines.json` `Work sweep` entry itself records this as a
  **precondition** of the work-117 un-pause ("the reviewer PAT was removed from the
  scope-creep-local cloud env"), not a misconfiguration.
- `mcp__github__get_me` resolves to **`dimays`** — the forced proxy identity per [[adr-026]], not
  `@scope-creep-review` or a bot login.
- **Read literally, the stored prompt's own instruction is a hard stop here** — `GH_REVIEW_PAT` is
  not merely "not scope-creep-review," it doesn't exist. But three independent prior runs
  (ledger-081/082/084) already resolved this exact tension: the discrepancy is the **ratified,
  Owner/CoS-maintained state**, not a failure — `registry/routines.json`'s note, written by
  Owner/CoS by hand, states outright that the write path is **propose-only** and "SUPERSEDES the
  earlier pause note... that write path is dead; the live path is ADR-026 propose-only." A literal
  full-stop would contradict four runs of recorded, ratified organizational practice in favor of a
  stale instruction nobody has refreshed. **Followed the ratified path instead**: proceed, author
  PRs via `mcp__github__create_pull_request`, never attempt approve/merge. This is also structurally
  consistent with [[work-119]]'s finding that the **only** system that merges unattended is a
  wholly separate, purpose-built GitHub Action host (`dimays/scope-creep-reviewer`, [[adr-027]]) —
  not this routine minting a reviewer credential itself.
- **Did not re-run the JWT-mint probe** this time. Three consecutive runs (ledger-081/082/084) found
  the same unexplained discrepancy (a direct mint against `GH_APP_ID`/`GH_APP_PRIVATE_KEY_B64`
  returns live data) and explicitly recommended **not** probing the safety gate further once
  `GH_REVIEW_PAT`'s absence already settles the question (no merge path exists either way). Still
  flagged below for the Owner/CTO to reconcile or formally close.
- `git push` to the console repo succeeded directly, as every prior run; PRs opened via
  `mcp__github__create_pull_request`. **No merge, approval, or label action was attempted.**

## Diagnosis — the ready set (34 deep, `wipCap` 2, `activeCount` 0, not exhausted)

Backlog shrank by one since ledger-084 (35 → 34): `work-107` moved out of `ready` into `review`
(PR #78, still unmerged). The same ten high-priority tickets remain ready; all re-screened against
their frontmatter `updated` dates — **unchanged** since ledger-084, so the same dispositions hold:

| Ticket | Priority | Disposition | Why |
|---|---|---|---|
| [[work-069]]/[[work-071]]/[[work-078]]/[[work-079]]/[[work-080]]/[[work-083]]/[[work-084]]/[[work-085]]/[[work-119]]/[[work-132]] | high | **deferred (carried forward)** | Same reasons ledger-084 recorded, re-verified unchanged. |

No high-priority ticket was pickable, so the floor dropped to medium, where `work-107`'s departure
surfaced `work-099`:

| Ticket | Priority | Disposition | Why |
|---|---|---|---|
| [[work-099]] | medium | **deferred — ticket premise doesn't match reality** | A background Explore agent mapped the live Console board code (`app/lib/work.server.ts`, `app/routes/work.tsx`) and found the board **already renders 4 columns today** — `Proposed`/`Active`/`Blocked`/`Done` — with `blocked` an **on-board** column, not the 3-column-plus-off-board-side-states the ticket's "User problem" section assumes. `superseded`/`dropped` aren't modeled in `WorkStatus` at all, so items with those statuses are silently invisible on `/work` today — there is no existing "off the four columns" presentation to extend. Implementing the ticket's literal target (`To-do`/`In-progress`/`In-review`/`Done`, per [[work-readme]]) means **removing the currently-visible Blocked column** with no replacement — an undocumented UI regression, not covered by the ticket's "no regression to the existing columns" acceptance line. The ticket itself already asks for chief-designer sign-off on the column treatment; this discrepancy sharpens that into an actual design decision (does blocked get a parked/terminal section, or does it just disappear?) rather than a mechanical edit. Deferred rather than built blind; flagged below for the CTO/Chief Designer. |
| [[work-121]] | medium | **deferred** | Acceptance requires standing up a per-repo `escalation-check.sh`/CODEOWNERS escalation set, branch protection, and a **Chief-Reality-Officer-supervised first run** before any unattended host extension — gate-adjacent, not agent-buildable periphery. |
| [[work-122]] | medium | **deferred** | Acceptance requires truing up the loops' "Cadence" prose (`loops/*.md`) to match reality — `loops/**` is escalation-class per `scripts/escalation-check.sh`'s `is_escalation()`. Also plausibly already partially addressed in practice (every cadenced work-sweep run since ledger-081 has emitted a real `cadence-decision` block via `work-sweep cadence`), which the docs-truing half of this ticket would need to reconcile, not something to resolve unilaterally. |

Dropped to **low priority**, where three tickets carry an explicit **2026-09-23 board-reconcile
note**: *"work-sweep will re-activate it within the ≤2 cap"* ([[ledger-074-board-reconciliation]])
— `work-105`, `work-108`, `work-109`. Picked **two** (at the `wipCap` 2 / `activeCount` 0 ceiling):

| Ticket | Priority | Disposition | Why |
|---|---|---|---|
| **[[work-105]]** | low | **picked** | Mechanical, verified: `ThreadProjection.openRepoLink` confirmed dead via a repo-wide grep (no route reads `p.openRepoLink`); `buildOpenRepoLink` itself correctly kept since `explore.server.ts`'s separate `LoopLaunch` type still calls it. |
| **[[work-108]]** | low | **picked** | Mechanical, verified: `buildCliCommand` escaped only `\`/`"`; `$`/backtick remained shell-active in the pasted command. Small, scoped, test-covered fix. |
| [[work-109]] | low | **left for next run** | Conservative posture at the `wipCap` 2 ceiling, matching ledger-084's practice of not over-picking in one round. |

## What shipped

**work-105** — `app/lib/claude-sessions.server.ts`: removed the dead `openRepoLink` field from
`ThreadProjection`, its construction in `resolveThreadProjection`, and the now-unused
`buildOpenRepoLink` import; `app/lib/claude-sessions.server.test.ts`: dropped the obsolete
`expect(p.openRepoLink).toBeNull()` assertion.

**work-108** — `app/lib/claude-sessions.ts`: `buildCliCommand` now escapes `$` and backtick
(chained after the existing `\`→`\\`, `"`→`\"` replacements, so none of the inserted escape
backslashes get re-escaped) and the docstring was updated to describe the full escaped set;
`app/lib/claude-sessions.test.ts`: added a test with a `$(whoami)`/`` `id` ``/`$HOME`-bearing seed,
asserting no raw `$` or backtick survives in the output.

Landed as **two separate one-purpose branches/PRs** (`work-105-remove-dead-openrepolink`,
`work-108-harden-buildclicommand-escaping`) off a shared base, split from one working diff by file
— they touch overlapping modules but non-overlapping lines — per [[ticket-cycle]]'s one-branch-
per-ticket convention, rather than bundling two tickets into one PR.

**Verified, not asserted:** `npx vitest run` (full suite) — 355/355 (354 baseline + the 1 new
work-108 test), identical to ledger-084's baseline plus one; the same one pre-existing
`route-entrypoints.test.ts` load failure (missing `@scope-creep/design`) reproduced on `main`.
`npx biome check` — clean on all four touched files, no fixes needed (one formatting fix applied
to the new test during authoring, before commit). `npx tsc --noEmit` — no errors attributable to
touched files; the only errors are the same two pre-existing `@scope-creep/*` /
`feedback-mount.tsx` baseline issues unrelated to this change.

**PRs:** [dimays/scope-creep-console#79](https://github.com/dimays/scope-creep-console/pull/79)
(work-105), [dimays/scope-creep-console#80](https://github.com/dimays/scope-creep-console/pull/80)
(work-108) — both author `dimays` (the forced identity), held for `@scope-creep-review` per
CODEOWNERS (`*` default, periphery). [[work-105]]/[[work-108]] → `review`, `branch:`/`pr:` set.

## Cadence decision

```
### cadence-decision
- loop: work-sweep
- ran_at: 2026-10-02T16:26:38.414Z
- trigger: work-sweep
- next_cadence_days: 0.5
- reason: ready backlog 34 deep — waking sooner, 0.5→0.5d; wip 0/2
```

Emitted via `npm run work-sweep -- cadence --current 0.5 --backlog 34 --owner-pull-rate 0 --wip 0 --min 0.5 --max 7` (the live CLI, not hand-written).

Read the prior live interval (0.5d) from [[ledger-084-work-sweep-third-cadenced-run]] rather than
re-seeding; owner-pull rate still taken as `0` (no measured history yet, same caveat as all three
prior runs).

## Disposition

Delivered as a **routine propose-only PR set** — this ledger append + the [[work-105]]/[[work-108]]
status edits in `dimays/scope-creep` (periphery, no core/escalation file touched), and
`dimays/scope-creep-console#79`/`#80` — all held for `@scope-creep-review`. **Nothing merged,
nothing un-paused, by this session's identity** — structurally by design ([[adr-026]]).

## Surfaced, not applied

- **[[work-069]]/[[work-071]]/[[work-078]]/[[work-079]]/[[work-080]]/[[work-083]]/[[work-084]]/
  [[work-085]]/[[work-119]]/[[work-132]]/[[work-121]]/[[work-122]]** — deferred with reasons above;
  still `proposed`, still ready.
- **[[work-099]] — the ticket's premise doesn't match the live Console code.** Recommend the
  CTO/Chief Designer re-scope it: either (a) accept that landing it hides `blocked` tickets
  entirely (a real UI regression to decide on, not assume), or (b) extend the ticket to also design
  a parked/terminal presentation for `blocked`/`superseded`/`dropped`, matching [[work-readme]]'s
  "side/terminal, off the four columns" language, which has no implementation today for any of the
  three statuses it's supposed to cover.
- **The held-PR queue keeps growing — now six open, unmerged, propose-only PRs across both repos,
  the oldest eight days old:** `scope-creep-console` #76 (work-081, 2026-09-28), #77 (work-110,
  2026-09-29), #78 (work-107, 2026-10-01), #79 (work-105, today), #80 (work-108, today); and
  `scope-creep` #142 (staffing-review's first scheduled run, 2026-09-28). This is the **third**
  consecutive run flagging the growing queue (ledger-084 flagged two; now six).
- **A separate, higher-stakes item surfaced incidentally while checking the PR queue:**
  `dimays/scope-creep#140` ("Autonomy charter (ADR-028) + roadmap-002") is an **explicitly
  escalation-class** PR — a full safety-kernel rewrite (`INVARIANTS` v2.0.0, new
  `charter/PRINCIPLES.md`, `standards/decision-rights.md` v2, narrowed CODEOWNERS, edits to 11 of
  13 loop files) — that has sat **open and unapplied for eight days** (since 2026-09-24) awaiting
  the Owner's own manual `docs/owner-apply-autonomy-charter.md` steps. `work-sweep` correctly never
  touched it (self-disposing an escalation-class gate-surface PR is exactly what [[adr-026]]/
  [[adr-022]] forbid), but it is surfaced here because an escalation-class PR aging a week-plus
  unapplied seems squarely in-scope for Owner attention, independent of anything this routine can
  or should do about it.
- **The JWT-mint discrepancy** (unchanged description from ledger-082/084) — not re-probed this
  run per ledger-082's standing recommendation; `GH_REVIEW_PAT`'s absence already settles that no
  merge path exists regardless of what the mint returns. Still flagged for the CTO/Owner to
  formally reconcile against [[adr-026]] or close out.
- **The stored `work-sweep` cloud-routine prompt is stale a fourth time** — same finding as
  ledger-081/082/084, unresolved after four runs, and this run additionally found its own literal
  "STOP and report" identity-check instruction now actively **conflicts** with the ratified
  propose-only policy recorded in `registry/routines.json` and three prior ledgers. Recommend the
  Owner/CoS refresh the stored prompt (the corrected text is already written, verbatim, in
  `docs/runbook-work-sweep-cloud-routine.md` §2) so a fifth run doesn't have to re-derive and
  re-justify this a fifth time.

See [[work-sweep]], [[adr-026]], [[adr-022]], [[adr-023]], [[adr-027]],
[[ledger-084-work-sweep-third-cadenced-run]], [[ledger-082-work-sweep-second-cadenced-run]],
[[ledger-081-work-sweep-first-cadenced-run]], [[ledger-072-work-sweep-unpause-safety-gates]],
[[work-105]], [[work-108]], [[work-099]], [[work-119]].
