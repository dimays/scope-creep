---
id: work-063
title: Thread read-state, persistent unread badge, and notification center
type: feature
status: proposed
priority: high
owner: cto
spec: prd-request-loop
created: 2026-09-07
updated: 2026-09-07
---
The only "you have something new" signal today is the `needs-you` thread status, recomputed
on load of `/` and `/threads` — no unread/last-read state, no persistent badge, no way to be
told. So the Owner has to go looking. Pillar III of [[prd-request-loop]], in-app half
(Owner disposition Q1: in-app only this cycle — no email).

Build:
- **Read-state:** a per-thread last-read marker (the `settings` k/v table, or a small
  `thread_reads` table) so "unread" is real, not derived from status alone.
- **Persistent unread badge** in the nav — visible on every page, not just `/` and
  `/threads`.
- **Notification center:** a surface listing what needs the Owner (needs-you threads) and
  recent notable org updates, newest-first, each linking to its thread; opening a thread
  clears its unread.

**Acceptance:** from any page the Owner sees an accurate unread count; opening a thread
clears that thread's unread; the notification center lists `needs-you` threads and notable
updates newest-first with working links. No email or push (deferred). See
[[prd-request-loop]], [[adr-012]], [[work-064]].
