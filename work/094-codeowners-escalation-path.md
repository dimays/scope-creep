---
id: work-094
title: Add .github/CODEOWNERS to the control-plane escalation-check path-set (ADR-023 Phase 2 gap)
type: chore
status: done
priority: high
owner: cto
spec: adr-023
pr: https://github.com/dimays/scope-creep/pull/114
created: 2026-09-21
updated: 2026-09-23
---
A live gap found during the 2026-09-21 checkpoint reconciliation ([[ledger-065-checkpoint-reconciliation]]).
On the control plane, `scripts/escalation-check.sh` classifies a PR's changed paths and its
`is_escalation()` case-list covers `charter/INVARIANTS.md`, `.claude/*`, `standards/*`,
`.github/workflows/*`, and the paid-dependency manifests — but it has **no `.github/CODEOWNERS`
case**. `.github/CODEOWNERS` lives at `.github/CODEOWNERS`, not under `.github/workflows/`, so a
change to it classifies as **routine**.

**Why it matters (ADR-023 Phase 2).** Under [[adr-023]] Phase 1 the `@scope-creep-review`
reviewer/merger identity runs **unattended** in [[work-sweep]]. If a CODEOWNERS edit is routine,
that identity could **rewrite the control plane's own code-owner list** — the mechanism that
makes escalation review meaningful — without tripping the Owner hold. This is exactly the
"org edits its own gates as routine" class the escalation rail exists to prevent. The
`scope-creep-console` escalation-check already covers CODEOWNERS (console #64); the control
plane does not.

**Owner-applied — locked gate surface.** `scripts/escalation-check.sh` is on the locked
gate-enforcement surface (`guard-writes.sh` + `permissions.deny`), so an agent may **not** edit
it. The fix ships as an Owner-applied patch via a `docs/owner-apply-*.md` (the
[[ledger-057-transparent-delegation-visibility-fix]] pattern), not a plain agent PR.

**Fix:** add a `.github/CODEOWNERS` case (return 0 / escalation-class) to `is_escalation()` in
the control-plane `scripts/escalation-check.sh`, matching the console's coverage, so a
CODEOWNERS change HOLDS for the Owner marker. Consider covering `.github/CODEOWNERS` explicitly
(it is not under `.github/workflows/`).

**Gate class — escalation.** Touches the locked gate surface → Owner-applied; holds for the
Owner marker. Part of [[adr-023]] Phase 2 (the human-only code-owner split).

**Acceptance:** a PR that touches `.github/CODEOWNERS` on the control plane is classified
escalation-class by `scripts/escalation-check.sh` and HOLDS without the `owner-approved` marker;
the two-repo coverage is symmetric (console already covers it); the change is delivered as an
Owner-applied patch, not an agent edit to the gate surface. See [[adr-023]], [[adr-022]],
[[ledger-065-checkpoint-reconciliation]].

> **[2026-09-23] board reconcile:** `proposed → done` — landed via [scope-creep#114](https://github.com/dimays/scope-creep/pull/114) (merged; `.github/CODEOWNERS` case added to `is_escalation()`). See [[ledger-076-board-hygiene-status-reconciliation]].
