---
name: ledger-078-routine-reviewer-action-host-live
description: Record that the ADR-027 separated routine-reviewer now has a LIVE off-cloud host — an hourly scheduled GitHub Action in the private, Owner-owned dimays/scope-creep-reviewer repo (the realized ADR-027 Divergence (ii)). Shipped this session (2026-09-23 local)- reviewer-repo PR #1 (routine-reviewer.yml — hourly + workflow_dispatch, permissions {}, environment ci, checkout SHA-pinned to actions/checkout v4.2.2 = 11bd719, runs bash scripts/routine-reviewer.sh --unattended as @scope-creep-review via a classic repo-scoped REVIEW_PAT stored only as the ci env secret) + full README; PR #2 added reliability workflows heartbeat.yml (weekly .heartbeat commit to defeat GitHub's 60-day scheduled-workflow auto-disable; GITHUB_TOKEN contents:write) and liveness.yml (every 2h; emails the Owner if no successful routine-reviewer run in 4h; GITHUB_TOKEN actions:read). First scheduled run GREEN 2026-09-24 UTC — a clean no-op (reviewer- scope-creep-review + no open PRs targeting main). KEY FINDING- on GitHub's free plan a PRIVATE repo CANNOT be branch-protected (classic branch protection AND rulesets both 403 Upgrade to GitHub Pro or make this repository public); the Owner ACCEPTED a discipline-only posture 2026-09-23 (Owner sole admin + Claude GitHub App the only other actor + no agent ever merges into that repo) in its place, documented in the reviewer repo README. scope-creep's own Actions/Environments stay empty (ADR-026 gate #3(ii) intact); author != merger still holds by environment separation. The safety property is unchanged — the reviewer stays bounded to periphery by the two-rail re-derivation and escalation still holds for @dimays. This entry records the go-live only; it merges nothing and un-pauses nothing.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-24
---

# Ledger 078 — routine-reviewer Action host live

**Date:** 2026-09-23 local (first scheduled run **2026-09-24 UTC**) · **Ticket:** [[work-118]]
· **Spec:** [[adr-027]] (the separated routine-reviewer — this realizes its **Divergence (ii)**)
· **Decision record:** [[ledger-077-adr-027-decision-loop]].

## Headline

> **The ADR-027 separated routine-reviewer now has a LIVE off-cloud host** — an **hourly scheduled
> GitHub Action** in the private, Owner-owned **`dimays/scope-creep-reviewer`** repo. Its **first
> scheduled run was GREEN on 2026-09-24 UTC**, a clean no-op (`reviewer: scope-creep-review` ·
> `no open PRs targeting main`). The human 2-click is now backed by an unattended reviewer that
> **runs entirely outside** any routine's cloud sandbox.

This is the realized **ADR-027 Divergence (ii)** ("the reviewer's home is a scheduled GitHub Action
in a SEPARATE Owner-owned repo"). It records a go-live only — **nothing merged, nothing un-paused.**

## What shipped

| PR (reviewer repo) | What |
|---|---|
| **#1** | `.github/workflows/routine-reviewer.yml` + full `README.md`. The workflow: **hourly** `schedule` + `workflow_dispatch`; `permissions: {}`; environment `ci`; `actions/checkout` **SHA-pinned** to v4.2.2 (`11bd719`); runs `bash scripts/routine-reviewer.sh --unattended` (checked out from `dimays/scope-creep@main`) as **`@scope-creep-review`**. |
| **#2** | Reliability workflows — `heartbeat.yml` + `liveness.yml` (see below). |

- **Credential:** a **classic `repo`-scoped** `REVIEW_PAT` for `@scope-creep-review`, stored
  **only** as the reviewer repo's **`ci` environment secret** — never in `dimays/scope-creep`.
- **First run:** **GREEN, 2026-09-24 UTC** — clean no-op (`reviewer: scope-creep-review`,
  `no open PRs targeting main.`). Both reliability workflows were also dispatched green.

## Reliability workflows (defeat GitHub's failure modes)

| Workflow | Cadence | Job | Token grant |
|---|---|---|---|
| **`heartbeat.yml`** | weekly | commits a `.heartbeat` file so the scheduled workflow is never idle 60 days (GitHub auto-**disables** scheduled workflows after 60 days of repo inactivity) | `GITHUB_TOKEN` `contents:write` |
| **`liveness.yml`** | every 2h | fails (→ GitHub emails the Owner) if there has been **no successful `routine-reviewer` run in 4h** | `GITHUB_TOKEN` `actions:read` |

## Key finding — free-plan private repos cannot be branch-protected

> **On GitHub's free plan a PRIVATE repo CANNOT be branch-protected.** Both **classic branch
> protection** *and* **rulesets** return **403 — "Upgrade to GitHub Pro or make this repository
> public."** So the "protected branch" condition ADR-027 Divergence (ii) lists as part of the
> reviewer repo's lockdown is **unattainable as-built.**

**Owner-accepted posture (2026-09-23) — discipline-only, in place of branch protection:**

- **Owner sole admin** of the reviewer repo.
- **The Claude GitHub App is the only other actor.**
- **No agent ever merges** into the reviewer repo.

This posture is documented in the reviewer repo's `README.md`, which is the **authoritative source**
for the host's lockdown + reliability conditions.

## Why this stays safe (the ADR-027 properties hold)

- **`dimays/scope-creep`'s own Actions/Environments stay empty** → **[[adr-026]] gate #3(ii) is
  intact.** The reviewer credential lives in a **different trust domain** the proposing routine
  cannot reach — this is **not** the "PAT in Actions secrets" option the ADR-027 Alternatives table
  HARD-BLOCKS (that block is about **scope-creep's own** Actions).
- **`author ≠ merger` still holds by environment separation** — author = the `dimays` proxy identity
  ([[ledger-066-cloud-sandbox-proxy-identity-wall]]); merger = `@scope-creep-review` in the separate
  reviewer env.
- **The reviewer stays bounded to periphery** by the **two-rail re-derivation** (trusted
  `escalation-check.sh` **and** `.github/CODEOWNERS`, read from `main`, holds if either flags a
  path). **Escalation-class PRs still hold for `@dimays`** and are never auto-anything — exactly as
  the [[ledger-073-work-sweep-first-run-canary]] canary and PR #133 (which correctly holds for
  `@dimays`) demonstrate.

> **Threat relocation, stated plainly:** the threat ADR-026 gate #3(ii) guards — *a workflow that can
> act as the reviewer* — is **relocated** into the reviewer repo, so **that repo's own access control
> is now load-bearing.** With branch protection unavailable, the discipline-only posture above (plus
> `permissions: {}`, no `pull_request` trigger, and the least-privilege PAT) is what carries it.

## Disposition

The Action host is **live**. This entry records the go-live and reconciles the running system with
the record; a companion **ADR-027 operational-status note** captures the same facts in the spec, and
`docs/owner-apply-routine-reviewer.md` (PR #133) documents the host as **Step 3b** for the Owner.
Nothing merged into `dimays/scope-creep`, nothing un-paused. See [[adr-027]], [[work-118]],
[[ledger-077-adr-027-decision-loop]], [[ledger-073-work-sweep-first-run-canary]],
[[ledger-072-work-sweep-unpause-safety-gates]], [[adr-026]], [[adr-023]], [[adr-022]].
</content>
</invoke>
