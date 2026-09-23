---
id: work-106
title: Extract a shared CommandRow/CopyButton primitive into @scope-creep/design
type: chore
status: proposed
priority: low
owner: chief-designer
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-23
---
Follow-up from the [[work-104]] Threads design polish. The launcher renders an inline
"copyable command + Copy button" row (`.launcher__cmd*` in the console) for the
`claude --resume <uuid>` and the copyable `claude-cli://` fallback. This is a genuinely reusable,
headless pattern (a monospace command + a copy affordance with copied-state feedback) that other
Console surfaces will want.

## Scope
Extract a shared **CommandRow / CopyButton** primitive into `@scope-creep/design`
(`/Users/davidmays/code/scope-creep-design`), then adopt it in the Threads launcher, replacing
the inline console implementation. Keep it dark-mode-correct and token-driven.

## Acceptance
A design-system CommandRow/CopyButton primitive exists and the Threads launcher consumes it in
place of its inline `.launcher__cmd*` markup; design package + console build/tests green. See
[[work-104]], design system.

> **[2026-09-23] board reconcile:** `active → proposed` — un-started follow-up (no branch/PR); returned to To-do to clear the WIP-cap. work-sweep will re-activate it within the ≤2 cap. See [[ledger-074-board-reconciliation]].
