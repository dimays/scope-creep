---
name: ledger-077-adr-027-decision-loop
description: Decision-loop record (CTO owns · CRO verifies · CoS ratifies) for ADR-027 (autonomous routine-merge), run 2026-09-23 at the Owner's request. Outcome- CRO verdict SOUND-WITH-FIXES (core safety confirmed against live source, no fabrications; 4 precision fixes required); CoS RATIFIED with the fixes folded; all fixes applied to the ADR on PR #122. The decision- define a separated routine-reviewer (outside the routine's sandbox, decides from an independent escalation-check re-run, periphery-only, escalation stays @dimays) but BUILD IT ONLY on the volume trigger; keep the human 2-click interim. CRO caught a real precision defect- escalation-check.sh is_escalation() has no scripts/ case so the load-bearing lock on the gate scripts is CODEOWNERS→@dimays not the re-run; and an untested capability- auto-merge enablement from the sandbox (needs a build canary + allow_auto_merge=true). CoS added a build precondition- align the two rails (Owner-applied gate-file patch, work-094 pattern). ADR-027 stays proposed, escalation-class, HOLDS for the Owner; nothing merged or built this session.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-23
---

# Ledger 077 — ADR-027 decision loop (autonomous routine-merge)

**Date:** 2026-09-23 · **Spec:** [[adr-027]] · **Loop:** [[decision]] (CTO owns · CRO verifies · CoS ratifies)
· **Trigger:** Owner asked to run the loop on the ADR-027 draft · **PR:** [dimays/scope-creep#122](https://github.com/dimays/scope-creep/pull/122).

## Outcome

**RATIFIED with fixes folded.** The decision — a **separated routine-reviewer** (outside the
routine's sandbox; decides from an *independent* `escalation-check` re-run, never the PR's forgeable
CI/label; periphery-only; escalation stays human `@dimays`), **defer the build to the volume
trigger**, **keep the 2-click interim** — is sound and fail-closed. ADR-027 stays `proposed`,
escalation-class, HOLDS for the Owner. Nothing merged or built this session.

## CTO (owns)

Authored ADR-027: the separated-reviewer design, the explicit HARD-BLOCK on any reviewer credential
in the routine's env or Actions secrets (protects Gate 0 / [[adr-026]] gate #3(ii)), defer-the-build,
2-click interim.

## CRO (verifies) — SOUND-WITH-FIXES

Independently re-checked every load-bearing claim against live source and GitHub; **no hallucinations,
no fabricated verifications.** Confirmed: the friction is real (#119/#120/#121 all `merged_by: dimays`
off-sandbox, not the routine); the un-spoofability core is intact (`is_escalation()` catches
`.github/workflows/**` + `.github/CODEOWNERS`); the HARD-BLOCK reasoning is correct. **4 must-fix
precision items** (all folded into ADR-027):

1. **Rails asymmetry** — `escalation-check.sh` `is_escalation()` has **no `scripts/` case**, so the
   load-bearing lock on the gate scripts is **CODEOWNERS→`@dimays`**, not the re-run. Fixed the ADR's
   attribution; added rail-alignment as a build precondition.
2. **Auto-merge capability asserted but untested** — the canary never exercised
   `enablePullRequestAutoMerge` from the sandbox; needs `allow_auto_merge=true`. Downgraded to a
   build-gated canary.
3. **`review-pat` "already exists"** softened to "attested in ledger-066/072."
4. **Three residuals named** — the rails asymmetry; the CI-adjacent non-`.github/workflows` surface
   (inside [[adr-022]]'s accepted residual, not locked); gate #3(ii) is point-in-time → the reviewer
   must re-verify it per run.

## CoS (ratifies) — RATIFIED (with the CRO fixes folded)

Not "as written" (two fixes correct inaccurate statements); not a send-back (no blocker). INVARIANTS
upheld — §7/§10 (`author ≠ merger`, here by **environment separation**), §II (single-user; a machine
reviewer is identity separation, not roles/auth), §I.4 (building the reviewer is a **core-upgrade**,
Owner-approved). Defer-the-build and the 2-click interim both endorsed; the Console batch
approve+merge (runs *as the Owner*) approved as an interim softener. **Added routing:** align the two
rails as a build precondition — an **Owner-applied** gate-file patch (`escalation-check.sh` is
guard-write-blocked, the [[work-094]] pattern).

## Org routing (for the eventual build — not now)

- **Fold the CRO fixes into the ADR:** done this session (on PR #122).
- **Align `is_escalation()`** (add `scripts/escalation-check*.sh` + `scripts/guard-*.sh` cases):
  CTO drafts the exact patch → **Owner applies** (guard-blocked gate file) → git-manager lands. Build precondition.
- **Build the separated reviewer** (on the volume trigger): CTO (architecture; `.claude/**` + review-env = core-upgrade) · git-manager (auto-merge + branch-protection wiring) · CRO (re-signs the three preconditions) · Owner (approves the core-upgrade).
- **Build-time auto-merge canary:** qa-tester runs it; git-manager confirms `allow_auto_merge`.

## Disposition

ADR-027 is escalation-class (`standards/`) authored under the forced `dimays` proxy identity →
**deadlocked as authored** (author == sole eligible code owner). The Owner disposes **off-sandbox**:
`@scope-creep-review` supplies the periphery review, `@dimays` supplies the code-owner review, the
`owner-approved` label clears escalation-check, then merge — the intended escape hatch, nothing routed
around it. See [[adr-027]], [[adr-022]], [[adr-023]], [[adr-026]], [[ledger-072-work-sweep-unpause-safety-gates]].
