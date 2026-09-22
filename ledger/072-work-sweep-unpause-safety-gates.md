---
name: ledger-072-work-sweep-unpause-safety-gates
description: Plan-of-record + decision loop (CTO owns / CRO verifies / CoS ratifies) for safely un-pausing the work-sweep cloud routine. Session ground-truth this run (origin/main both repos, 2026-09-22)- work-sweep still paused; ADR-023 Phase-2 not landed; work-094 open (control-plane escalation-check has no .github/CODEOWNERS case, console does); ADR-026 compensating controls re-verified clean via CLI (secrets empty + environments 0 both repos, main protection live). Three pre-un-pause unknowns are all Owner-read or cloud-only and CANNOT be closed from a local session- (1) is the @scope-creep-review PAT in the scope-creep-local cloud env (reviewer-identity runbook step 11 instructs adding it -> HARD-BLOCK candidate), (2) Administration write absent from the Claude App grant (Owner UI-read), (3) the proxy wall proven by a supervised cloud canary. Outcome- work-sweep STAYS PAUSED; this session delivers the plan-of-record, the decision-loop determinations, and the drafted Owner-apply artifacts + needs-you card; it un-pauses nothing.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-22
---

# Ledger 072 — work-sweep un-pause: safety gates (plan-of-record + decision loop)

**Date:** 2026-09-22 · **Ticket:** [[work-117]] · **Loop:** [[decision]] (CTO owns · CRO verifies · CoS ratifies)
· **Specs:** [[adr-026]] (write path / tiered un-pause), [[adr-023]] (Phase-2 residual), [[adr-022]] (escalation).

## Headline

**work-sweep STAYS PAUSED.** Every decisive un-pause gate is Owner-read or cloud-only and is
**not reachable from a local session.** This session's deliverable is the durable plan-of-record,
the decision-loop determinations below, and the drafted Owner-apply artifacts + a `needs-you`
card enumerating the exact Owner/cloud steps in order. It **un-pauses nothing** and lands no
escalation-class change (all such changes require the Owner marker + `@scope-creep-review`
code-owner review, both Owner-applied — the harness blocks an automated session from either).

## Session ground-truth (re-verified this run, origin/main both repos)

- work-sweep `paused` in `registry/routines.json`; `request-triage` active + clean; `board-hygiene`
  active (Tier-1 canary — [[ledger-071-board-hygiene-first-run-canary]]).
- ADR-023 Phase-2 not landed: `.github/CODEOWNERS` = `* @scope-creep-review` both repos, no split.
- [[work-094]] open: control-plane `scripts/escalation-check.sh` `is_escalation()` has **no
  `.github/CODEOWNERS` case**; console's copy has it (line 122). Asymmetry confirmed.
- **ADR-026 compensating controls (CLI-verified this session):** `gh secret list` empty both
  repos; `environments.total_count = 0` both; `main` protection LIVE both
  (`require_code_owner_reviews`=true, `require_last_push_approval`=true, escalation-check a
  required status check, `enforce_admins`=true). → gate #3(ii) holds; gate #3(i) is Owner-UI.

## The three pre-un-pause unknowns (all unresolvable locally)

1. **@scope-creep-review PAT in the `scope-creep-local` cloud env? — HARD-BLOCK candidate.**
   `docs/owner-apply-reviewer-identity.md` **step 11** instructs the Owner to add it there so the
   routine's review step could approve autonomously. If it was added, an unattended reviewer
   identity sits in work-sweep's own env. Mitigating fact ([[ledger-066-cloud-sandbox-proxy-identity-wall]]
   + [[adr-026]]): the egress proxy overwrites any presented token and re-authenticates as the
   shared Claude App (`dimays`). **Precision (CRO §5) — two claims, two proof levels:** the
   *identity-override* (a custom PAT cannot present a distinct identity in-sandbox) is **directly
   proven** (ledger-066: real PAT / garbage / no-token all returned `dimays` at 200;
   [[ledger-071-board-hygiene-first-run-canary]] writes succeed 201 *as `dimays`*); the
   *merge-refusal* (criterion-4 — the forced identity cannot actually merge) is **NOT yet directly
   proven** (ledger-071 skipped the `PUT /pulls/{n}/merge` probe, saw only `mergeable_state:
   "blocked"`). So the sense of "inert" that matters for un-pause (no merge can occur) is reasoned +
   indirectly supported, **not proven**; do NOT record it as "read-only" either — post-ADR-026 the
   forced identity now HAS Contents+PR write (the ledger-066 "read-only" premise is superseded for
   writes). Resolution: Owner **removes** the PAT from that cloud
   env (belt-and-suspenders — it is moot for the cloud path; review happens off-sandbox per
   ADR-026 parts 3/5) **OR** the supervised canary's direct `PUT /pulls/{n}/merge → 405/409`
   probe proves it inert. Until one holds → **HARD BLOCK**.
2. **Administration / branch-protection write ABSENT from the Claude App grant** (ADR-026 gate
   #3(i)). Owner GitHub-UI read; CLI cannot verify without the App JWT. Gate #3(ii) re-verified
   clean this session.
3. **Proxy wall re-confirmed by a supervised cloud canary** — not assumed. Cloud-only.

## Decision loop

### CTO (owns) — determination

**Bottom line: HOLD work-sweep paused. Do NOT un-pause in any tier this session. Fail closed.**

1. **Sequencing → Phase-2-FIRST.** work-sweep is Tier-2 by nature: its charter drives *any* ready
   ticket, so it will touch escalation/core/gate paths. There is no mechanical path-filter to bound
   it to Tier-1, so an "earlier Tier-1 propose-only work-sweep" is unsafe theater for this loop.
   Tier-1 stays reserved for `board-hygiene` (already canaried). Concurs with CRO's counsel.
2. **Unknown #1 → do BOTH: remove the PAT AND prove-inert via canary.** Reviewer-identity step 11
   seeded the `@scope-creep-review` PAT into `scope-creep-local` (work-sweep's env). Removal is free
   (the PAT is moot for the cloud path — proxy discards it; review is off-sandbox) and closes the
   "one config change from a live merge-capable credential" gap the canary alone does not. Gate #1
   does not clear until removal is Owner-confirmed.
3. **work-094 patch** = add `    .github/CODEOWNERS)                          return 0 ;;` after the
   `.github/workflows/*)` case (control-plane line 67), matching console. **Owner-applied** — the
   file is guard-blocked for agents.
4. **CODEOWNERS split** — escalation set → `@dimays` (human-only); periphery → `@scope-creep-review`;
   sets per repo as in [[work-117]]/`docs/owner-apply-work-sweep-unpause.md`. **`require_last_push_approval`
   trap:** `@dimays` cannot be both last pusher and approver — the split PR should be agent-authored
   so `@dimays` disposes as pure code-owner.
5. **No un-pause step can be LANDED from this local session.** The routine's system of record is
   **claude.ai, not the repo** ([[adr-016]]); `registry/routines.json` `status` is a **mirror**, not
   the switch. *(Correction per CRO §6: `registry/routines.json` and `.github/CODEOWNERS` are
   contained at the **merge gate** — escalation-class → owner label + `@scope-creep-review` review —
   **not** the write gate; `guard-writes.sh` blocks only `INVARIANTS.md`/`.claude/**`/
   `.github/workflows/**`/`escalation-check.sh`/`guard-*.sh`. So an agent could author those two
   branches locally but cannot LAND them. `scripts/escalation-check.sh` (work-094) IS
   guard-write-blocked.)* Correct outcome: land only propose-side artifacts + emit one Owner
   `needs-you` card. **Open risk:** gate #3(i) (Administration write ABSENT from the Claude App
   grant) is Owner-UI-only and NOT verified this session — re-confirm before any un-pause.

### Chief Reality Officer (verifies) — determination

Independently re-ran every check (origin/main both repos, live GitHub API, actual hook/script
source). **Net: the plan's disposition is sound and appropriately fail-closed — work-sweep stays
paused, this session un-pauses nothing, every decisive gate is Owner-read or cloud-only. No
hallucinated facts or fabricated verifications.** Per-claim:

- **Facts 1–4 CONFIRMED** (paused; CODEOWNERS no-split both repos; escalation-check asymmetry real;
  ADR-026 controls — secrets empty, environments 0, protection live — re-run clean). Gate #3(i)
  correctly flagged as NOT CLI-verifiable → stays an open Owner-read unknown.
- **Claim 5 (HARD-BLOCK): wording CONFIRMED; "proven inert" DISPUTED → keep the block.** Step 11
  verbatim confirmed. Identity-override is *directly* proven; merge-refusal (criterion-4) is *not
  yet* — so keep the HARD BLOCK until the PAT is removed **or** the direct `PUT …/merge` probe runs.
- **Claim 6 (overclaim) CONFIRMED — no un-pause progress claimed that wasn't made**, with framing
  correction: say "cannot **LAND**," not "guard-blocked," for `registry/routines.json` +
  `.github/CODEOWNERS` (merge-gated, not write-gated). *(Corrected in CTO §5 above.)*
- **Claim 7 (sequencing): CONCUR — Phase-2-first.** Option C is defensible only if unknown #1 is
  verified clean AND work-094 has landed AND the Owner accepts human-reviewer-caught escalation
  containment — more conditions = less robust.

**Must-fix before un-pause:** (1) unknown #1 stays a HARD BLOCK — remove the PAT or run the direct
criterion-4 probe; `mergeable_state:blocked` is not a substitute. (2) Criterion #4 must be
*directly* exercised in the ADR-026 canary. (3) Gate #3(i) is unverified locally — keep it an open
unknown, don't let CLI-verified #3(ii) imply #3 as a whole is proven. (4) Record precision fixes
(applied above). (5) Land work-094 **before** any control-plane CODEOWNERS change, even under
Option C — else the split PR itself classifies routine on the required check.

### Chief of Staff (ratifies) — RATIFIED (2026-09-22)

**RATIFIED as written.** The disposition is sound and correctly fail-closed. No send-back.

- **Disposition ratified.** work-sweep STAYS PAUSED. This local session un-pauses nothing,
  lands no escalation-class change, and delivers only the plan-of-record, the decision-loop
  record, the drafted Owner-apply runbook, and one Owner `needs-you` card. Every decisive gate
  is Owner-read or cloud-only. Confirmed against INVARIANTS §7/§10 (propose, never dispose;
  human-gated deploy/merge) — nothing here routes around a gate.
- **Sequencing ratified: Phase-2-FIRST.** work-sweep is Tier-2 by nature (drives any ready
  ticket → will touch escalation/core/gate paths); no mechanical path-filter bounds it to
  Tier-1, so an "early Tier-1 propose-only work-sweep" is unsafe theater for this loop. Tier-1
  stays reserved for `board-hygiene` (canaried, ledger-071). Option C remains defensible ONLY if
  all three hold: unknown #1 verified clean AND work-094 landed AND the Owner explicitly accepts
  human-reviewer escalation containment — more conditions, less robust; not adopted.
- **Unknown #1 ratified as a HARD BLOCK.** Do BOTH: Owner removes the `@scope-creep-review` PAT
  from the `scope-creep-local` cloud env AND the supervised canary proves-inert via the direct
  criterion-4 `PUT /pulls/{n}/merge → 405/409` probe. `mergeable_state: "blocked"` is not a
  substitute. The block does not clear until the removal is Owner-confirmed. Endorsed: the PAT is
  moot for the cloud path (proxy discards it), so removal is free and closes the
  "one-config-change-from-a-live-merge-credential" gap the canary alone does not.
- **CRO must-fix items 1–5 ratified** as folded into this ledger, including #5 (land work-094
  BEFORE any control-plane CODEOWNERS change) and #3 (gate #3(i) Administration-write stays an
  open Owner-read unknown; CLI-verified #3(ii) does not imply #3 as a whole).
- **Precision ratified:** "cannot LAND" (merge-gated) not "guard-blocked" for
  `registry/routines.json` + `.github/CODEOWNERS`; `scripts/escalation-check.sh` IS
  guard-write-blocked. The `require_last_push_approval` trap mitigation (agent/`git-manager`
  authors the split PR so `@dimays` disposes as pure code-owner) is correct and load-bearing.

**Org routing (who drives each remaining step):**
- **Gate 0 (PAT removal), Gate 1(i) (Administration-write re-confirm), Phase 2a apply
  (escalation-check.sh is guard-blocked for agents):** Owner-only. On the card.
- **Gate 1(ii) re-verify secrets empty / environments 0 post-change:** agent CLI (`git-manager`
  or any exec). Not on the card.
- **Phase 2b CODEOWNERS-split PRs (both repos):** `git-manager` authors (agent-authored so
  `@dimays` is never last pusher); Owner disposes (review + `owner-approved` label).
- **Phase 2c ADR-023 → Phase-2-active bump + live-verify capture:** `chief-knowledge-manager`
  drafts, `git-manager` lands once Owner-approved; Owner disposes; evidence to ledger.
- **Phase 3 canary:** `qa-tester` runs the supervised cloud canary and captures criteria
  1/2/4/6 (incl. the direct merge probe) + propose-only + escalation-refusal + WIP-cap; `CRO`
  verifies the evidence; Owner un-pauses at the claude.ai `manage_url`; `git-manager` authors the
  `registry/routines.json` mirror PR; Owner disposes.
- **Nothing agent-doable is pushed onto the Owner:** verified. The three Owner-apply steps are
  genuinely Owner-only (cloud env, GitHub App grant UI, and a guard-blocked gate file); all
  authoring/canary/verification is routed to agents.

**Board status (RATIFIED): flip work-117 `active → blocked` (Owner-blocked).** Per the
ticket-cycle / work-sweep STOP convention (`loops/ticket-cycle.md`, `loops/work-sweep.md`): the
next actionable step is a `needs-you` Owner gate (Gate 0 is a HARD BLOCK) and no agent-doable
step can proceed until the Owner clears it — so `active` would falsely imply live agent work.
Resume entry = this ledger (072); unblock trigger = the `needs-you` card below. Flip work-117
back to `active` only when Gate 0 is Owner-confirmed clear.

**Transparency / Console (Owner's surfacing mandate):** surface this decision loop and its
delegation in the Console — one `needs-you` card carrying the ordered Owner actions, linked to
this ledger's decision record (CTO owns · CRO verifies · CoS ratifies). This is the
transparent-delegation case the Owner asked to see; a `needs-you` card + the linked ledger is the
right surface — do not over-build it.

## Owner-apply artifacts drafted this session
- `docs/owner-apply-work-sweep-unpause.md` — the ordered `needs-you` runbook (Gate 0 PAT removal →
  Gate 1 controls → Phase 2 ADR-023 close → Phase 3 ADR-026 canary + un-pause), with the exact
  work-094 patch line, the per-repo CODEOWNERS split sets, the `require_last_push_approval` trap
  mitigation, and the criterion-4 direct merge-probe the board-hygiene canary skipped.
- **Pre-authored (propose-only, at Owner request 2026-09-22 — NOT merged/labeled/approved):**
  - `dimays/scope-creep#110` — control-plane CODEOWNERS split. **Flagged DO-NOT-MERGE until
    work-094 lands** — verified live that its escalation-check classifies **ROUTINE (PASS)** today
    (the must-fix #5 gap). Escalation set → `@dimays`; periphery → `@scope-creep-review`. (Added
    `scripts/guard-*.sh` beyond the brief's literal list — flagged in the PR for the Owner to trim.)
  - `dimays/scope-creep-console#75` — console CODEOWNERS split (mirror). Verified live that its
    escalation-check classifies **ESCALATION → HOLD** (console already covers `.github/CODEOWNERS`),
    so it correctly holds for the owner marker with no work-094-style prerequisite.
  - `dimays/scope-creep#111` — **ADR-023 → `active` (Phase-2-landed) bump.** **Flagged MERGE-LAST**:
    it asserts Phase 2 is live, so it must be disposed only AFTER #110 + console#75 + work-094 land
    and the live-verify gate is captured — merging it earlier would falsely claim an active control.
    Retains the verbatim CRO residual (marked closed, not deleted) and the honest remainder
    (periphery auto-review stays; label forgeable but code-owner identity is the load-bearing gate).
    Classifies **ESCALATION → HOLD** (verified live).
  - Branch-authored in throwaway worktrees off `origin/main` (since removed); the console working
    checkout (on `cto/work-115…`) and the PR #109 branch were left untouched.

## needs-you card (Owner / cloud steps, in order) — CoS-signed 2026-09-22

**work-sweep — un-pause: 6 Owner steps, in order. Do not skip a gate.** (Full runbook:
`docs/owner-apply-work-sweep-unpause.md`. Record: this ledger.)

1. **[Gate 0 — HARD BLOCK] Remove the reviewer PAT from the cloud env.** At
   `https://claude.ai/code` → Environments → `scope-creep-local` → env vars, remove the
   `@scope-creep-review` PAT (reviewer-identity step 11 seeded it). It is moot for the cloud path
   (the egress proxy discards it), so removal is free and closes the merge-capable-credential
   gap. **Nothing else proceeds until you confirm this is removed.**
2. **[Gate 1(i)] Re-confirm the GitHub App grant.** In the GitHub UI, confirm
   `Administration` / branch-protection write is **ABSENT** from the shared Claude GitHub App on
   **both** repos. If present → stop (HARD BLOCK). Do not rely on the 2026-09-21 report; re-read.
3. **[Phase 2a] Apply the work-094 patch** to the control-plane `scripts/escalation-check.sh`
   (guard-blocked for agents): add `    .github/CODEOWNERS)                          return 0 ;;`
   after the `.github/workflows/*)` case (line 67). `@scope-creep-review` approves; you add the
   `owner-approved` label; merge. (Must land BEFORE any CODEOWNERS change.)
4. **[Phase 2b] Dispose the CODEOWNERS-split PRs** — **now pre-authored & open** (propose-only):
   `dimays/scope-creep#110` (control plane) + `dimays/scope-creep-console#75` (console). **#110
   must NOT merge until Phase 2a (work-094) lands** — until then its required check reads routine.
   Dispose each: `@scope-creep-review` reviews + you add `owner-approved`; you are not the last
   pusher (both were authored on their own branches). Escalation set → `@dimays`, periphery →
   `@scope-creep-review`.
5. **[Phase 2c] Dispose the ADR-023 → Phase-2-active PR** — **now pre-authored & open** as
   `dimays/scope-creep#111`. **Merge LAST** — only after step 3 (work-094) + step 4 (#110 +
   console#75) land AND the live-verify gate evidence is captured to the ledger. It asserts Phase 2
   is active, so merging it earlier is a false claim.
6. **[Phase 3] After the supervised canary passes** (criteria 1/2/4/6 incl. the direct
   `PUT …/merge → 405/409` probe, + propose-only + escalation-refusal + WIP-cap; `qa-tester`
   runs, `CRO` verifies): **un-pause the routine at its claude.ai `manage_url`**
   (`https://claude.ai/code/routines/trig_01Aw7cBgWjGTER2FeAe9tyeT`) — the real switch — then
   dispose the separate control-plane PR mirroring `registry/routines.json` `paused → active`
   (`git-manager` authors).

Any permission denial at any step → the ticket stays `blocked` + this card, never silent, never
`done`.

## Disposition
work-sweep remains `paused`. Nothing merged, nothing un-paused, no escalation-class change
**landed** by this session. Four propose-only PRs are open and held for the Owner: `#109`
(this plan-of-record, routine), `#110` (control-plane CODEOWNERS split, DO-NOT-MERGE-until-work-094),
`console#75` (console CODEOWNERS split, correctly holding), `#111` (ADR-023 → active bump,
MERGE-LAST after the substance lands). See [[work-117]], [[adr-026]],
[[adr-023]], [[adr-022]],
[[ledger-071-board-hygiene-first-run-canary]], [[ledger-066-cloud-sandbox-proxy-identity-wall]].
