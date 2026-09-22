---
id: work-117
title: Safely un-pause work-sweep — resolve the pre-un-pause unknowns, close ADR-023 Phase 2, run the ADR-026 canary
type: chore
status: blocked
priority: high
owner: cto
spec: adr-026
created: 2026-09-22
updated: 2026-09-22
blocked_on: owner
blocked_reason: Every next step is an Owner needs-you gate (Gate 0 PAT removal is a HARD BLOCK). CoS-ratified 2026-09-22; resume when Gate 0 is Owner-confirmed clear. See ledger-072 needs-you card.
---

The plan-of-record for turning on autonomous cadenced execution of the work board:
un-pause the [[work-sweep]] cloud routine so it works ready tickets on a cadence, **without**
weakening "propose, never dispose" ([[invariants]] §7/§10, [[adr-022]], [[adr-023]], [[adr-026]]).

Convened via the [[decision]] loop: **CTO** owns · **[[chief-reality-officer]]** verifies ·
**[[chief-of-staff]]** ratifies. Decision record: [[ledger-072-work-sweep-unpause-safety-gates]].

## Verified state (2026-09-22, re-confirmed this session against origin/main both repos)

- **work-sweep is `paused`** (`registry/routines.json`); `request-triage` active + store clean
  ([[work-115]]). `board-hygiene` active (Tier-1 canary passed — [[ledger-071-board-hygiene-first-run-canary]]).
- **ADR-023 Phase-2 NOT landed:** `.github/CODEOWNERS` = `* @scope-creep-review` on BOTH repos
  (no human-only split); ADR-023 status = "active (Phase 1) / proposed (Phase 2)".
- **[[work-094]] open:** the control-plane `scripts/escalation-check.sh` `is_escalation()` has
  **no `.github/CODEOWNERS` case** (console's copy does — line 122). A CODEOWNERS rewrite there
  classifies **routine** today.
- **ADR-026 compensating controls re-verified via CLI this session:** `gh secret list` **empty**
  both repos; `environments.total_count = 0` both repos; `main` protection LIVE both repos
  (`require_code_owner_reviews`, `require_last_push_approval`, escalation-check is a required
  status check, `enforce_admins` true).
- **work-sweep works arbitrary tickets → Tier-2 by nature** (can author escalation-class diffs).
  [[adr-026]] gates Tier-2 autonomous merge on Phase-2.

## Unknowns to resolve BEFORE any un-pause (Owner-confirmed; not in repo)

1. **[HARD-BLOCK candidate] Is the `@scope-creep-review` PAT in the `scope-creep-local` cloud
   env?** `docs/owner-apply-reviewer-identity.md` **step 11** explicitly instructs the Owner to
   add it there. If present → an unattended reviewer identity lives in work-sweep's own env →
   even propose-only is unsafe → **HARD BLOCK until removed or proven inert** by the proxy wall.
   *Owner-read (cloud env; not visible from any repo or local session).*
2. **Re-confirm ADR-026 gate #3(i):** `Administration`/branch-protection write ABSENT from the
   Claude App grant. *Owner GitHub-UI read (CLI cannot verify without the App JWT).* Gate #3(ii)
   (secrets/environments) re-verified clean this session.
3. **Re-confirm the ledger-066 proxy wall via a supervised cloud canary** — not assumed.
   Cloud-only; a local session cannot reproduce the egress-proxy identity override.

## Execute (sequence — see the ledger entry for the live checklist)

- **A. Close ADR-023 Phase-2** (unlocks Tier-2): land [[work-094]] first (Owner-applied — the
  gate file is guard-blocked for agents), then the CODEOWNERS-split PR in BOTH repos (escalation
  set → `@dimays` human-only; `* @scope-creep-review` stays for periphery), bump ADR-023 →
  Phase-2 active, run the reviewer-identity live-verify gate.
- **B. Un-pause work-sweep per ADR-026** with a supervised canary capturing criteria **1/2/4/6**
  — including the direct in-sandbox `PUT /pulls/{n}/merge` → 405/409 probe that
  [[ledger-071-board-hygiene-first-run-canary]] only observed indirectly — plus propose-only,
  escalation-refusal, and WIP-cap proofs. Flip `registry/routines.json` `paused → active` as a
  **separate** Owner-approved control-plane PR (work-sweep may not un-pause itself).
- **C. Optional earlier partial win:** IF unknown #1 is clean AND the proxy-wall canary passes, a
  Tier-1 propose-only work-sweep (authors PRs on cadence; human/off-sandbox merge) is a safe
  early step. CRO's counsel: because work-sweep is Tier-2 by nature, Phase-2-first is more
  robust. CTO/CoS decide (recorded in the ledger).

## Constraints (INVARIANTS / ADR-022/023/026)

Propose, never dispose. Escalation-class changes (`registry/**`, `standards/**`, `.claude/**`,
`.github/CODEOWNERS`, gate scripts, …) need the owner-approved **label** + `@scope-creep-review`
code-owner review, **both Owner-applied** — an automated session cannot self-approve or
self-label. **Fail closed:** any permission denial → the ticket stays `ready` + a `needs-you`
card, never silent, never `done`.

## Acceptance

work-sweep runs on a cadence and, for any escalation-reachable path, HOLDS for the Owner; the
un-pause happened only after (1) unknown #1 resolved clean, (2) ADR-023 Phase-2 landed, (3) the
ADR-026 canary captured criteria 1/2/4/6, and (4) a separate Owner-approved control-plane PR
flipped the routine `active`. Every Owner-only / cloud-only step surfaced as a `needs-you` card,
never silently skipped. See [[ledger-072-work-sweep-unpause-safety-gates]].
