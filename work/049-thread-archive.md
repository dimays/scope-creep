---
id: work-049
title: Archive / restore threads (with a confirm gate + Archive view)
type: feature
status: proposed
priority: medium
owner: chief-designer
spec: prd-cos-threads
created: 2026-09-06
updated: 2026-09-06
---
Owner-requested (2026-09-06): a way to happily terminate threads and clear them out of the
main UI, reversibly.

- **Archive button on every thread** (the thread detail view; a per-row affordance on the
  list is a nice-to-have). One button, clearly labeled.
- **Confirm gate:** an extra validation pop-up before archiving — one deliberate gate for the
  Owner (tasteful in-app confirmation, not just `window.confirm`, per the delight mandate).
- **Archived threads leave the main list** (and the needs-you/active/closed groupings) — the
  main Threads surface only shows non-archived threads.
- **Archive view** — a dedicated place (route or filter) listing archived threads, each with a
  **Restore** button that returns it to the main list. Restore is reversible; no confirm needed.
- **Data model:** an orthogonal nullable `archived_at` on `conversations` (a drizzle migration
  following the work-018/030/032 pattern) — archive is independent of `status` (a thread can be
  closed or open and archived). Archiving sets it; restoring clears it.

**Acceptance:** every thread has an Archive button; archiving asks for confirmation, then the
thread disappears from the main Threads UI and appears in the Archive view; Restore returns it.
Reversible throughout. See [[prd-cos-threads]].
