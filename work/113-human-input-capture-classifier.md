---
id: work-113
title: Human-Input Log — classify at capture (hook) + read-side twin, so internal/system prompts never log
type: bug
status: proposed
priority: high
owner: cto
spec: prd-console-operations
created: 2026-09-21
updated: 2026-09-21
---
Recurrence of [[work-095]]/[[work-096]] (PR #93): internal/system content is again showing in the
Human-Input Log — `<task-notification>` blocks, `<bash-input>gh …</bash-input><bash-stdout>…`
bang-command I/O, and `<system-reminder>` lines, all tagged `operator-session`. Verified in
`human-input/2026-09.ndjson`.

## Root cause
The `UserPromptSubmit` hook (`.claude/hooks/log-human-input.py`) logs every prompt **raw**, with no
content classification. The harness injects non-human content into the prompt stream (notifications,
reminders, CI events, and bang-/slash-command tool I/O). Prior fixes corrected the write **path**,
never **classification** — so it recurs. The console read-side filter (`operatorInputText`) stripped
only fixed *wrapper* tags and missed tool/command blocks entirely.

## Scope
- **Capture-side (core, Owner-apply):** classify in the hook — strip leading harness wrapper blocks,
  drop anything empty or beginning with a tool/command block; log only Owner prose. Gate surface, so
  delivered as `docs/owner-apply-human-input-capture-hook.md` (PR #102) for the Owner to apply.
- **Read-side twin (console):** extend `operatorInputText` with the same filter (PR #73) so already-
  captured lines stop rendering.
- **Guard:** `test_log_human_input.py` (`bun run hooks:check`) + console vitest cases.

## Acceptance
- Injected/tool/command prompts are never written (hook) and never rendered (console); genuine Owner
  prose — including prose that quotes a tag or mentions a command — is kept.
- Positive guard test fails loudly on reintroduced indiscriminate capture. (Verified: ALL PASS.)
- HOLD for Owner (core is Owner-apply / escalation-class). See [[ledger-070-human-input-capture-classifier-and-notification-signal]].
