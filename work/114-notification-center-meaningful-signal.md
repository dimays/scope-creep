---
id: work-114
title: Notification center — reduce to meaningful signal (one row/thread, collapse FYIs, consume-on-read)
type: bug
status: done
pr: https://github.com/dimays/scope-creep-console/pull/73
priority: high
owner: cpo
spec: prd-console-operations
created: 2026-09-21
updated: 2026-09-22
---
Owner: "an absurd amount of notifications that don't appear to mean much." The notification center
(work-063/064) floods with low-value rows.

## Root cause
`buildNotifications` created **one row per notable org write-back**. A burst of `critical-update`
FYIs on a single thread produced N rows, and FYIs never cleared once read — so the feed filled with
repetitive, already-seen updates.

## Scope
Define and enforce a "notification-worthy" contract in `app/lib/threads.ts › buildNotifications`
(console PR #73):
- **At most one row per thread.**
- **Blocker** (`needs-you` / `needs-input`): always shown; persists until the thread is unparked.
- **FYI** (`critical-update`): collapsed to the single newest per thread; shown **only while unread**;
  consumed once the Owner opens the thread (stays in thread history).

Preserve the transparent-delegation signal (the transparent-delegation stress test) — consequential
updates still surface once each until seen.

## Acceptance
- A burst of same-thread updates → one row; a read FYI → no row; a blocker → always one row and
  outranks an FYI on the same thread. Covered by tests (collapse / consume-on-read / persistence /
  priority). Console suite green (363 tests).
- HOLD for Owner. See [[ledger-070-human-input-capture-classifier-and-notification-signal]].
