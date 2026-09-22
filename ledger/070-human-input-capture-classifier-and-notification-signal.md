---
name: ledger-070-human-input-capture-classifier-and-notification-signal
description: Root-cause + resilience record for two Owner-reported quality regressions — (1) internal/system prompts polluting the Human-Input Log (recurrence of work-095/096), root-caused to indiscriminate capture and fixed with a capture-side content classifier (Owner-apply, PR #102) plus a read-side twin + positive guard test (console PR #73); (2) notification noise, root-caused to per-write-back rows and fixed by a "notification-worthy" contract in buildNotifications (collapse to one row/thread, consume-on-read). Chief-of-Staff-orchestrated; execs delegated inline (Agent spawns blocked this session).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-21
---

# Ledger 070 — human-input capture classifier + notification signal

**Date:** 2026-09-21 · **Tickets:** [[work-113]], [[work-114]] · **PRs:** dimays/scope-creep
#102 (core, Owner-apply) · dimays/scope-creep-console #73 (periphery) · **Prior:**
[[ledger-067-human-input-hook-write-path-fix]] (write-path fix this supersedes at the root).

## Issue 1 — internal/system prompts polluting the Human-Input Log (RECURRENCE)

### Root cause
The Human-Input Log must show **only genuine Owner terminal input** ([[adr-010]]/[[adr-011]]).
`UserPromptSubmit` fires for **every** submitted prompt, and the harness injects non-human
content into that same stream: `<task-notification>` completions, `<system-reminder>` blocks,
CI events, and — the leak the prior fixes missed — **bang-command / slash-command tool I/O**
echoed as `<bash-input>…</bash-input><bash-stdout>…`, `<local-command-*>`, `<command-*>`. The
hook (`.claude/hooks/log-human-input.py`) captured the **raw** prompt with no classification, so
all of it was logged as `operator-session` "human input." Verified in `human-input/2026-09.ndjson`:
task-notification blocks, `gh pr merge …` bash lines, and 7 `<system-reminder>` lines.

**Why it recurred:** work-095 ([[ledger-067-...]], PR #93) fixed the write **PATH** (worktree →
the dir the Console reads); work-096 the cloud proxy. Neither touched content **CLASSIFICATION**.
So the moment a session ran bang-commands or accrued notifications, the log re-polluted. The
console read-side filter (`operatorInputText`) stripped only a fixed set of harness *wrapper*
tags and never handled tool/command I/O.

### Resilient fix (two layers + a guard)
1. **Capture-side (core, Owner-apply — PR #102).** The hook classifies: strip leading harness
   wrapper blocks, then **drop** any prompt that is empty after stripping or **begins with a
   tool/command block**. Only genuine Owner prose is written. Delivered as
   `docs/owner-apply-human-input-capture-hook.md` because `.claude/**` is a locked gate surface
   an agent may not author ([[invariants]] §I.2/§I.4, §III; guard-writes).
2. **Read-side twin (periphery — PR #73).** `app/lib/human-input.ts › operatorInputText` applies
   the **same** filter, so lines captured before the hook lands stop rendering immediately.
3. **Positive guard (recurrence prevention).** `test_log_human_input.py` (verified **ALL PASS**,
   14 assertions; wired into `bun run hooks:check`) asserts genuine text is kept and every
   injected/tool category is dropped — it fails loudly if indiscriminate capture returns.
   Mirrored by console vitest cases in `human-input.test.ts`.

## Issue 2 — notification noise

### Root cause
The notification center (work-063/064) created **one row per notable org write-back**. A burst of
`critical-update` FYIs on a single thread produced N rows, and FYIs never cleared once read —
so the feed filled with low-value, already-seen updates ("an absurd number that don't mean much").

### Resilient fix — a "notification-worthy" contract
Enforced in `buildNotifications` (console PR #73), documented in code:
- **At most one row per thread.**
- **Blocker** (`needs-you` / `needs-input` — genuinely the Owner's turn): always shown; persists
  until the thread is unparked. This is the core "what needs you" signal.
- **FYI** (`critical-update`): collapsed to the **single newest** update per thread, shown **only
  while the thread has unread org activity**; consumed (drops out) once the Owner opens it. It
  still lives in the thread's own history.

This preserves the transparent-delegation signal ([[transparent-delegation-stress-test]]) —
consequential updates still surface, once each, until seen — while killing the repetition. Tests
cover collapse, consume-on-read, blocker persistence, and blocker-over-FYI priority.

## Governance / provenance
- Both PRs **HOLD for the Owner**; nothing merged, deployed, spent, or published. The core hook
  change is escalation-class ([[adr-022]] trigger (d): gate surface / core) and Owner-apply-only.
- Single-user preserved; no auth/tenancy touched.
- **Orchestration note:** the Chief of Staff scoped this as a lean CTO fix + one Chief-Reality-
  Officer resilience check + git-manager PR. Sub-agent (`Agent`) spawns were **blocked by the
  environment's auto-mode classifier** this session, so the CoS executed the CTO/CRO/git-manager
  work inline rather than fan out — consistent with the Owner's explicit "minimize background-agent
  churn / notification-noise" directive. Reality-check performed inline (see below).

## Reality check (inline, in lieu of a spawned Chief-Reality-Officer)
- Guard test: **ALL PASS** (14 assertions); console suite **363 tests pass**, typecheck + biome clean.
- Over-filtering check: prose that merely *quotes* a tag or *mentions* `bash-input` is kept (only
  LEADING tool/wrapper blocks trigger a drop) — covered by tests.
- Immediate effect: the console read-side filter cleans the rendered log even before the Owner
  applies the hook (verified `operatorInputText` returns "" for the observed bash/command lines,
  and `readOperatorSessions` skips empties).
- Residual risk: (a) the on-disk NDJSON keeps its historical pollution until the Owner runs the
  optional cleanup in the proposal doc (render is already clean); (b) if the harness renames tool
  wrapper tags, the tag lists need a one-line extension — the guard test will catch a silent
  regression only for the known categories.

*Traceability:* [[human-input-sync-architecture]] · prd-console-operations · [[work-020]] ·
[[adr-010]] · [[adr-011]] · [[work-095]] · [[work-096]] · [[ledger-067-human-input-hook-write-path-fix]].
