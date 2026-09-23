# Owner-apply — align `escalation-check.sh` with CODEOWNERS on the gate scripts

**One-line change to a guard-blocked gate file.** Adds `scripts/escalation-check*.sh` and
`scripts/guard-*.sh` cases to `is_escalation()` so the mechanical rail agrees with `.github/CODEOWNERS`
(which already routes those paths to `@dimays`). This is **ADR-027 build precondition #1** (the
separated routine-reviewer re-runs this classifier, so it must be trustworthy on the gate scripts).
Decision record: ADR-027 (PR [dimays/scope-creep#122](https://github.com/dimays/scope-creep/pull/122)),
`ledger/076-adr-027-decision-loop.md`.

> **Why Owner-applied, not in a PR diff:** `scripts/escalation-check.sh` is on the **locked
> gate-enforcement surface** — `.claude/settings.json` `permissions.deny` blocks `Edit`/`Write` on
> it (lines 10–13), and `guard-writes.sh` fails closed. So an agent may **propose** the patch here;
> **you apply it by hand.** Same pattern as [[work-094]] (the `.github/CODEOWNERS` case) and
> `docs/owner-apply-activity-write-path.md`.

## The bug (a real asymmetry, confirmed against source)

Two rails classify what is "escalation-class," and they **disagree on the gate scripts**:

- **`.github/CODEOWNERS`** (lines 33–34) routes `/scripts/escalation-check*.sh` and
  `/scripts/guard-*.sh` to the human owner **`@dimays`**.
- **`scripts/escalation-check.sh` `is_escalation()`** has **no `scripts/` case at all** — so a PR
  touching `scripts/guard-*.sh` or `scripts/escalation-check*.sh` classifies **ROUTINE** on the
  mechanical check.

Today the safety property still holds (branch protection requires the `@dimays` code-owner review, which `@scope-creep-review` cannot satisfy), so this is a **latent inconsistency, not a live hole**.
But it becomes load-bearing under **ADR-027**: the separated routine-reviewer re-runs
`is_escalation()` to decide whether to auto-approve — and as written it would classify a
`scripts/guard-*.sh` change as routine and approve it. Aligning the rails makes the re-run **real
defense-in-depth** and removes the trap if CODEOWNERS ever regresses.

## The patch — edit `scripts/escalation-check.sh`

In `is_escalation()`, **immediately after** the `.github/CODEOWNERS)` case (line 68) and **before**
the `# --- infra / paid-dependency manifests …` comment, add three lines:

**Before (lines 67–69):**
```sh
    .github/workflows/*)                         return 0 ;;
    .github/CODEOWNERS)                          return 0 ;;
    # --- infra / paid-dependency manifests (trigger (d), overlaps (a)) ---
```

**After:**
```sh
    .github/workflows/*)                         return 0 ;;
    .github/CODEOWNERS)                          return 0 ;;
    # gate scripts (align is_escalation with CODEOWNERS — ADR-027 precondition; the reviewer re-run must catch these)
    scripts/escalation-check*.sh)                return 0 ;;
    scripts/guard-*.sh)                          return 0 ;;
    # --- infra / paid-dependency manifests (trigger (d), overlaps (a)) ---
```

- `scripts/escalation-check*.sh` matches **`escalation-check.sh`** and **`escalation-check.proof.sh`**
  (both exist today) — exactly CODEOWNERS line 33.
- `scripts/guard-*.sh` matches CODEOWNERS line 34. (No `scripts/guard-*.sh` file exists **yet** — the
  guard hooks currently live in `.claude/hooks/`, already escalation via `.claude/*` — but CODEOWNERS
  and `permissions.deny` both reserve the `scripts/guard-*.sh` path defensively, so the classifier
  should too.)
- **Strictly a tightening** (more paths classified escalation) → fail-closed. It cannot make a
  previously-held PR routine.

## Verify after applying

```sh
cd <scope-creep checkout>
# a throwaway diff touching a gate script should now classify ESCALATION (exit 1):
base=$(git rev-parse main); tmp=$(git commit-tree ...)   # or simply:
bash scripts/escalation-check.sh HEAD~1 HEAD             # against any commit that touches scripts/guard-*.sh or escalation-check*.sh
#   → "escalation-check: HOLD …", exit 1
bash scripts/escalation-check.proof.sh                   # if it carries cases, they should still pass
```
The simplest check: run `is_escalation` mentally — a changed path of `scripts/guard-foo.sh` or
`scripts/escalation-check.proof.sh` now returns 0 (escalation) instead of 1 (routine).

## Disposal

`scripts/escalation-check.sh` is escalation-class (CODEOWNERS → `@dimays`). Commit the change on a
branch, `@scope-creep-review` supplies the periphery review if any periphery files ride along, **you**
add the `owner-approved` label (your hand-commit + label is the §I.4 approval) and supply the `@dimays`
code-owner review, then merge. This is a **build precondition** for the ADR-027 separated reviewer —
it is **not** a blocker to disposing ADR-027 (PR #122) itself, and it does not need to land until that
reviewer is built.

## Reference

ADR-027 (PR #122) build precondition #1 · `ledger/076-adr-027-decision-loop.md` · [[work-094]]
(the CODEOWNERS-case precedent) · [[ledger-072-work-sweep-unpause-safety-gates]] ·
[[adr-023]] (the Phase-2 CODEOWNERS split that created the asymmetry) · [[adr-022]] (the escalation
gate this rail enforces).
