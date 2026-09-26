# Owner needs-you — unlock unattended autonomous execution

> **Superseded, 2026-09-24, by [[adr-028]] (the autonomy charter) and [[roadmap-002]].**
> This page is historical. Its escalation path set (`standards/**`, `agents/**`, `loops/**`,
> `registry/**`) no longer applies. The Owner now holds only the **safety kernel**
> (INVARIANTS v2.0.0 §4), and the substrate is the local-first `org-run` runner
> ([[work-125]]), not the cloud sandbox.

> **The answer up front — it's a TWO-TIER milestone.**
> **Tier 1 unlocks now:** the matured board, the self-healing `board-hygiene` routine, and
> `work-sweep` **scoped to non-escalation periphery** — all safe under the write grant you already
> made. **Tier 2 is gated:** before `work-sweep` may drive anything that can reach
> **escalation-class / core / gate-touching** paths, one more Owner-provisioned control must land
> (close [[adr-023]] Phase-2). Key rotation is **done**. The grant itself is **safe to keep** — this
> is only about what runs **unattended**.

**What changed:** the sandbox proxy makes a separate bot author impossible in-cloud
([[ledger-066-cloud-sandbox-proxy-identity-wall]]), so [[adr-026]] uses **propose-only** — the routine
proposes as the shared Claude GitHub App; **merge stays gated** by the `@scope-creep-review`
code-owner identity no cloud session can present. You granted that App write; the CRO independently
verified the merge-block holds against automated bypass — with one sharp caveat that creates Tier 2.

---

## Verified grant + config (CRO-blessed, both repos)
| Fact | State | Consequence |
|---|---|---|
| Administration / branch-protection write | **ABSENT** (your GitHub-UI manifest read) | Branch protection is uneditable by any claude.ai session — **please double-confirm Administration is not listed** |
| workflows / actions / checks / issues write | **PRESENT, accepted** | Signal/CI tampering only — reviewable and **non-merging** (see the sharp truth below) |
| Repo Actions secrets / environments | **EMPTY / none** | No `@scope-creep-review` credential stored for a rogue workflow to steal |
| Branch protection on `main` | code-owner review + last-push-approval + dismiss-stale + 1 review + enforce_admins; required checks **pinned to app_id 15368** | A check posted under the Claude App's own app_id does **not** satisfy them |
| CODEOWNERS | `* @scope-creep-review` (User, non-admin, can't self-approve; `can_approve=false`) | Merge needs a code-owner approval the cloud identity can't present |

**All automated bypass probes FAIL CLOSED** (checks-forge under a different app_id doesn't count;
workflow-disable → stuck "Expected"; Actions-token self-merge triple-blocked; no feature→main path
without code-owner review).

## The sharp truth (why Tier 2 exists)
Because workflows:write lets a cloud session **rewrite a check workflow on a PR branch** (github-actions
then posts it green → the pinned required check is satisfied) and issues:write lets it **forge the
`owner-approved` label**, **both of ADR-022's non-identity signals — green CI and the escalation label
— are forgeable** by a deliberate/prompt-injected cloud session. The **only trustworthy merge-gate
left is the `@scope-creep-review` code-owner identity**, with no defense-in-depth beneath it. It holds
against a cloud session — but the moment the **unattended** `@scope-creep-review` PAT auto-approves
([[adr-023]] Phase-2, **still open**), a cloud session could have pre-staged everything else, **including
a change to the gates themselves.** So work-sweep must not touch escalation/core unattended until a
**human-trustworthy, non-auto-approving** code owner guards those paths.

---

## Tier 1 — do now (safe under the current grant)

1. **Confirm the manifest** — double-check the Claude App's permissions on both repos show **no
   Administration / branch-protection write** (you read this in the UI; a CLI check needs the App JWT).
   If Administration ever appears → stop and bring it back to the CTO/CRO.
2. **Merge the three held PRs — #96 → #97 → #99.** All are escalation-class core and correctly held
   for you: #96 (PM maturity: `review` state + `board-hygiene` loop), #97 (ADR-026 + runbook +
   amended provisioning doc), #99 (this checklist + ledger-068). *board-hygiene must be on `main`
   before it can be registered.*
3. **Register `board-hygiene`** per `docs/owner-apply-board-hygiene-routine.md` (registration spec
   below). Registration is programmatic; **your approval is the gate** ([[adr-021]]) — it turns on
   recurring spend.
4. **Supervised canary run** — board-hygiene's first run **is** the in-sandbox test of un-pause
   criteria 1/2/4/6. Watch for: proxy-identity **opens a PR** (criteria 1&2 pass); a `PUT …/merge`
   from the sandbox is **blocked** by the code-owner gate (criterion 4 pass); a 403 surfaces to
   **needs-you**, never a silent drop (criterion 6 pass). **All pass → proceed; any fail → both stay
   paused, routed to needs-you.**
5. **Un-pause `board-hygiene` + `work-sweep` SCOPED to non-escalation periphery.** Board-hygiene edits
   only `work/*.md` status and opens a non-escalation PR — lowest blast radius. Non-escalation routine
   periphery work is safe because a routine merge still needs the code-owner identity and touches no
   gate.

## Tier 2 — gate before work-sweep may drive escalation/core-reachable work
6. **Close [[adr-023]] Phase-2** — provision a **human-trustworthy, non-auto-approving** code owner on
   the escalation/core path set. Concretely:
   - a **CODEOWNERS split** so the escalation set (`charter/INVARIANTS.md`, `.claude/**`,
     `standards/**`, `agents/**`, `loops/**`, `registry/**`, `.github/workflows/**`, gate scripts,
     non-append `ledger/**`, **and `.github/CODEOWNERS` itself**) requires review from a code owner the
     unattended work-sweep reviewer identity is **not** — i.e. `@dimays` (human) or a human-only team —
     while `@scope-creep-review` stays code owner for routine periphery;
   - the companion fix: add a `.github/CODEOWNERS` case to `scripts/escalation-check.sh`
     `is_escalation()` (CODEOWNERS rewrites currently classify **routine** — a hole) — a locked
     gate-surface change, Owner-only.
   Until this lands, work-sweep stays **scoped to non-escalation periphery**. The full ADR-023 residual
   is stated in [[adr-026]] §residuals.

---

## Registration spec (you execute; the org specifies — never fabricated ahead of a real trigger)
| Field | **board-hygiene** (Tier 1, register first) | **work-sweep** (un-pause, scope-limited until Tier 2) |
|---|---|---|
| Loop | `loops/board-hygiene.md` | `loops/work-sweep.md` (registered, `paused`) |
| Source / topology | `github.com/dimays/scope-creep`; console sibling; env `scope-creep-local` ([[adr-025]]) | same |
| Runtime | **Node** (`npm run …`, **not bun** — proxy drops bun fetch) | same |
| Cron seed | `0 15 * * *` | `0 16 * * *` (unchanged) |
| `cadence_bounds_days` | `[0.5, 7]` | `[0.5, 7]` |
| Model | `claude-sonnet-5` | `claude-sonnet-5` |
| Write path | Propose-only (ADR-026): opens one hygiene PR; you/local merge | Propose-only (ADR-026) |
| Un-pause gate | supervised canary criteria 1/2/4/6 | canary proven **and** scope = non-escalation until Phase-2 |

Record each real `trigger_id`/`cron`/`cadence_bounds_days` in `registry/routines.json` (small
follow-up PR — never a fabricated `trigger_id`) and log it in the [[ledger]].

## What you get to poke around at
- **After Tier 1:** a matured board with an **in-review** column (Console column ticketed as
  [[work-099]]; [[work-097]] already dogfoods it); a board that **keeps itself honest** daily
  (`board-hygiene` proposes tidy status-reconciliation PRs — routine backlog pruning on its own); and
  `work-sweep` landing **non-escalation periphery** roadmap tickets unattended, pausing to `needs-you`
  only at a blocker or milestone.
- **After Tier 2:** `work-sweep` cleared to drive the **full** ready backlog, including core/loop work,
  with the gates provably human-held.

---

Reference: [[adr-026]] · `docs/owner-apply-board-hygiene-routine.md` ·
`docs/owner-apply-github-write-access.md` (Part 1′) · `docs/runbook-work-sweep-cloud-routine.md` ·
[[ledger-068-scheduled-execution-automation-cycle]] · PRs #96, #97, #99.
