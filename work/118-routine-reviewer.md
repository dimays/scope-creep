---
id: work-118
title: Routine-reviewer — automated review+merge of routine PRs (ADR-027), with a manual batch mode
type: feature
status: review
priority: high
owner: cto
spec: adr-022
branch: claude/routine-reviewer-build
created: 2026-09-23
updated: 2026-09-23
---
Builds the **ADR-027 automated routine-reviewer** — the fix for the friction the Owner named on
2026-09-23: because the cloud sandbox cannot merge anything (ADR-026 / Gate 0, proven by the
ledger-073 canary), **every** routine PR waits for the Owner's off-sandbox review+merge. This
tool removes that per-PR click for ordinary work while keeping escalation strictly human.

Supersedes the manual-only batch tool (PR #125): this is **one tool, two modes** — manual
("one click for many") and unattended (a scheduled job, the actual automated reviewer).

## What shipped (this ticket)
- `scripts/routine-reviewer.sh` — runs **off-cloud, as `@scope-creep-review`**. For each open PR
  it **independently re-derives "routine + safe"** from a **trusted** re-run of
  `scripts/escalation-check.sh` (base…head) — **not** the PR's forgeable CI/label — and
  approves+merges only routine + green PRs (direct approve-then-merge; no `allow_auto_merge`
  needed). Escalation-class PRs are always skipped for `@dimays`. Dry-run by default; `--yes`
  (manual) / `--unattended` (scheduled).
- **Fail-closed whole-run preconditions** it self-enforces: (A) the trusted escalation-check must
  carry the gate-script cases (ADR-027 precondition #1 / PR #124) or it refuses to run; (B) gate
  #3(ii) — no code-owner credential in Actions secrets/Environments — re-verified every run.
- `scripts/routine-reviewer.launchd.plist` — scheduling template (Owner's Mac, reads the review
  PAT at run time; token never stored).
- `docs/owner-apply-routine-reviewer.md` — install runbook: supervised first run → CRO sign-off →
  schedule unattended.

## Not live until (build gate)
1. **PR #124 (rails alignment) merges** — the reviewer refuses to run until then.
2. **The reviewer's own files join the escalation set** (`scripts/routine-reviewer*`, its
   `.launchd.plist`, and `docs/owner-apply-routine-reviewer.md` → CODEOWNERS `@dimays` +
   an `escalation-check.sh` case) so *any* change to them requires `@dimays` — otherwise a
   change to the reviewer itself could be merged as routine. Fold this into the PR #124
   gate-file patch. *(The in-script self-modification guard covers the automated path in the
   meantime, but the CODEOWNERS lock is the durable fix.)*
3. A **supervised first run** (dry-run + a watched `--yes` run) is captured.
4. **CRO signs off** the run confirms the un-spoofability preconditions in practice.
Only then is it scheduled `--unattended`.

## Acceptance
The Owner installs it; a supervised run merges only routine + green PRs and holds every
escalation PR; CRO signs off; it is scheduled and clears routine PRs on a cadence with no
per-PR action. Reversible (unload the job → back to the manual 2-click).

See ADR-027 (PR #122) · [[adr-022]] · [[adr-023]] ·
[[ledger-072-work-sweep-unpause-safety-gates]] · `docs/owner-apply-routine-reviewer.md`.
