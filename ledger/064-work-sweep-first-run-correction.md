---
name: ledger-064-work-sweep-first-run-correction
description: Correction/append to ledger-062 (work-sweep first run). Finding #1 there — "GH_REVIEW_PAT authenticates as dimays, not @scope-creep-review" — was a SANDBOX ANOMALY of the supervised run, not a real Owner misconfiguration; the Owner verified the token locally resolves to @scope-creep-review, and Phase-1 CODEOWNERS (scope-creep #86 / console #65) list @scope-creep-review as the sole code owner. So 062's premise (a reviewer-identity misconfig) is misleading and is corrected here — the identity MUST be re-verified in the sandbox on the next supervised run before any unattended trust (run-1 read dimays for an unexplained sandbox reason). Also records that Finding #2 (installation-ID handling) is fixed by runtime derivation of the numeric installation ID from the App client_id (PR #91 / commit cc4cf50), NOT an Owner env change. Does not edit ledger-062 destructively.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-21
---

# Ledger 064 — Correction to ledger-062 (work-sweep first run)

**Date:** 2026-09-21 · **Recorded by:** Chief Knowledge Manager · **Corrects:**
[[ledger-062-work-sweep-first-run]] (non-destructive append; 062 is left intact).

[[ledger-062-work-sweep-first-run]] recorded the findings of the first supervised `work-sweep`
run honestly, but two of its findings need correcting now that the Owner and CTO have
reconciled them off-sandbox. This entry records the corrections so 062's premise is not left
misleading.

## Correction 1 — Finding #1 was a SANDBOX ANOMALY, not a reviewer-identity misconfig

**062 said:** *"`GH_REVIEW_PAT` authenticates as `dimays`, not `@scope-creep-review` — the
reviewer identity the live CODEOWNERS require; `dimays` is reserved for escalation."* — and
queued it as a hard Owner-side blocker.

**Correction:** the Owner **verified the token locally resolves to `@scope-creep-review`**. The
PAT is configured correctly; Phase-1 CODEOWNERS (`* @scope-creep-review`, scope-creep #86 /
console #65) name `@scope-creep-review` as the sole code owner, and the runbook (scope-creep
#85) is consistent. The run-1 sandbox reading of `dimays` was an **anomaly of that sandbox
invocation**, not a real misconfiguration. Finding #1 is therefore **not** a standing Owner
blocker.

**Caveat — do NOT drop the guard:** the *why* of the sandbox reading `dimays` on run 1 is not
yet explained, so the reviewer identity **must be re-verified inside the sandbox on the next
supervised run** (`gh api user` → expect `scope-creep-review`) **before** the routine is
trusted to run unattended. Reconcile the sandbox identity against the local verification before
un-pausing (`registry/routines.json` status `paused` → `active`).

## Correction 2 — Finding #2 is fixed in code, not by an Owner env change

**062 said:** *"`GH_APP_INSTALLATION_ID` holds the App client_id, not the numeric installation
ID — the bot installation token can't mint (404)"* — and queued it toward [[work-093]] as if it
needed an Owner env correction.

**Correction:** this is fixed **in code** — the runner now **derives the numeric installation
ID at runtime** from the App (the client_id is a valid JWT issuer), so no Owner env change is
required. Landed on `main` via the work-093 followups (commit `cc4cf50`, in PR #89's branch;
carried forward by the CTO's docs PR **#91**). The App/JWT auth itself always worked.

## Net for the board / activation

- Finding #1: **not** an Owner blocker — a sandbox anomaly to re-verify, not re-provision.
- Finding #2: **resolved in code** (runtime derivation), not an Owner env edit.
- The remaining hard activation blocker is unchanged: **a working GitHub write path from the
  sandbox** (REST author→review→merge with a correctly-minted bot token), tracked in
  [[work-093]] (PR #91). The routine stays **paused** until it lands and is re-verified.

See [[ledger-062-work-sweep-first-run]], [[ledger-065-checkpoint-reconciliation]], [[work-093]],
[[adr-023]].
