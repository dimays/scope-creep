---
id: work-118
title: Owner batch-merge tool — "one click for many" for routine PRs (ADR-027 interim softener)
type: feature
status: review
priority: medium
owner: cto
spec: adr-022
branch: claude/owner-batch-merge-tool
created: 2026-09-23
updated: 2026-09-23
---
The friction the Owner named on 2026-09-23: since the cloud sandbox cannot merge anything
(ADR-026 / Gate 0, proven by the ledger-073 canary's 405), **every** routine PR — even a
board-hygiene status correction — waits for the Owner's off-sandbox review+merge. At a daily
cadence that is a real, repeating cost.

This is the **interim softener** ADR-027 (PR #122) endorses: not the full automated cloud
reviewer (deferred), but a **local CLI the Owner runs** that clears the safe, routine PRs in one
pass — human authority, one command for many.

## What shipped (this ticket)
`scripts/owner-batch-merge-routine.sh` — runs **off-sandbox, as `@scope-creep-review`**. For each
open PR it **independently re-derives "routine + safe"** and approves+merges only if all hold:
1. the diff is classified **routine** by a **trusted** re-run of `scripts/escalation-check.sh`
   (base…head) — **not** the PR's own CI/label (both forgeable from the cloud, ADR-026);
2. author ≠ reviewer;
3. required checks green;
4. GitHub reports it mergeable.
Anything escalation-class or ambiguous is **skipped** and left for `@dimays`. **DRY-RUN by
default**; `--yes` to act. It refuses to run as any identity other than `@scope-creep-review`.

## Why a local CLI, not a Console button
The Console reads **local files, not live GitHub** today (see work-083). A Console web action
would need net-new live-GitHub read+write in the app — a larger build and its own design
question. A local CLI is the right shape for "runs as the Owner, off-sandbox" and delivers the
relief now. A Console surface can come later if wanted.

## Acceptance
- The script exists, is fail-closed (skips escalation/ambiguous), dry-runs by default, and
  refuses the wrong identity.
- The Owner runs it once and it correctly clears green routine PRs while holding escalation PRs.
- **First-cut caveat:** it performs merges — review it before the first `--yes` run; treat the
  dry-run output as the source of truth until trusted.

See ADR-027 (PR #122, the interim-softener decision) · [[adr-022]] (routine-merge posture) ·
[[adr-023]] (the human-only escalation code owner it preserves) ·
[[ledger-072-work-sweep-unpause-safety-gates]] (Gate 0 — why the reviewer must be off-sandbox).
