---
id: work-108
title: Harden buildCliCommand — shell-active $/backtick survive inside the quoted prompt
type: debt
status: proposed
priority: low
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-23
---
Non-blocking note from the [[work-100]] Threads fix review. `buildCliCommand` in
`app/lib/claude-sessions.ts` wraps the seed prompt in double quotes but only escapes `\` and `"`
— so `$` and backtick remain **shell-active** inside the quoted string. The copyable fallback
command is pasted by the Owner (single-user, so low severity), but a seed containing `$(…)`,
`` `…` ``, or `$VAR` would be interpreted by the shell instead of passed literally.

## Scope
Escape (or single-quote) the prompt so `$` and backtick are inert in the copyable
`cd <cwd> && claude "<prompt>"` command; keep the marker tail intact and the command paste-safe.
Add a test case with a `$`/backtick-bearing seed.

## Acceptance
A seed with shell metacharacters produces a paste-safe command that passes the literal prompt to
`claude`; test covers it. See [[work-100]].

> **[2026-09-23] board reconcile:** `active → proposed` — un-started follow-up (no branch/PR); returned to To-do to clear the WIP-cap. work-sweep will re-activate it within the ≤2 cap. See [[ledger-074-board-reconciliation]].
