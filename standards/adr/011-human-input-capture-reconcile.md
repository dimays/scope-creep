---
name: adr-011
description: Reconciles the shipped Human-Input capture with ADR-010 — human-input/ is local-only gitignored; capture is project-scoped (Owner operates from scope-creep), not a user-level global hook; the raw NDJSON record shape differs from the projection schema.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-05
---

# ADR-011: Human-Input capture — reconcile with shipped reality

- **Status:** accepted
- **Date:** 2026-09-05
- **Deciders:** Owner (directed), CRO + CKM (surfaced the drift in the level-set,
  [[ledger-027-level-set-round]]), Chief of Staff (ratified)
- **Supersedes (in part):** [[adr-010]] — its core (the log is a projection that owns
  no data; union-read + interludes) stands. This ADR corrects three specifics that
  implementation (work-020/021) settled differently.

## Context
[[adr-010]] was written before v1b shipped. Building it surfaced choices the ADR
either left open or stated differently, and the level-set ([[ledger-027-level-set-round]])
caught the resulting doc-vs-reality drift.

## Decision
1. **`human-input/` is local-only and gitignored — never pushed.** ADR-010 implied a
   tracked "core record set." The repo is public; the Owner chose to keep raw prompts
   private. `.gitignore` excludes `human-input/`; the Console reads it locally via
   `SCOPE_CREEP_HOME`. (Backfilled + live records live together here.)
2. **Capture is project-scoped; the Owner operates from `~/code/scope-creep`.** The
   `UserPromptSubmit` hook lives in `scope-creep/.claude/` and fires only in
   scope-creep-rooted sessions. A user-level `~/.claude` hook was **rejected**: it would
   pull every unrelated project (finance, phrasewood) into the Scope Creep log. The
   Owner runs Scope Creep sessions from the control-plane repo;
   `scripts/backfill-human-input.py` reconstructs anything run elsewhere from the
   session transcript (idempotent, `backfill:true`).
3. **Raw capture schema ≠ projection schema.** The hook writes
   `{source, ts, session, cwd, text}` (+ `backfill` on reconstructed rows). `intent`
   and the richer projection fields in [[prd-human-input-log]] are **derived in the
   Console reader**, not stored at capture. The PRD's data model describes the
   projection, not the on-disk record.

## Consequences
- Honest boundary: raw prompts stay on the Owner's machine; only the projection is ever
  rendered. Redaction guard still strips obvious secrets before write.
- The capture channel is only as complete as the Owner's discipline to work from the
  repo; backfill is the accepted safety net (not automatic everywhere — a deliberate
  trade against global capture).
- **Still open:** the Consistency self-checks ADR-010 promised remain unbuilt
  ([[work-022]]); until then a missed/uninstalled capture is undetected. Note the
  gap-check must account for the Owner sometimes working elsewhere, or it false-positives.

## Alternatives considered
- **User-level `~/.claude` global hook** — rejected: over-captures unrelated projects;
  a broad standing side effect on every session. (See decision 2.)
- **Amend ADR-010 in place** — rejected: ADRs are immutable once accepted
  ([[engineering-policy]]); supersede with a new record instead.
