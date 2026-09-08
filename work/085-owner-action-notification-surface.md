---
id: work-085
title: Notification-center extension — Owner-action items as a first-class, actionable type
type: feature
status: proposed
priority: high
owner: chief-designer
spec: prd-owner-action-notifications
created: 2026-09-07
updated: 2026-09-07
---
The render half of [[prd-owner-action-notifications]] on the **agent-buildable periphery**
(`scope-creep-console`). The notification center shipped in [[work-063]]
(`app/routes/notifications.tsx`, `buildNotifications` in `app/lib/threads.ts`, the nav unread
badge) but carries only **thread**-level rows. This extends it to a **second, distinct class**:
Owner-action items — the org's asks only the Owner can do. **Extends the surface; must not
duplicate or rebuild it.**

## What to change (`app/routes/notifications.tsx`, `@scope-creep/design`)
- **A distinct "Action needed" section**, separate from the thread notifications, rendering
  the PRD's row schema per item: **action** (the imperative), **why** (the driving
  PRD/ADR/invariant, and why it's Owner-only), and **link/instructions** (deep-link to the
  `owner-apply` doc or the PR, or the inline checklist). Read the two sections as one
  place-to-look but two shapes — thread rows are resolved by *reading*, action rows by
  *doing* ([[prd-owner-action-notifications]] "Distinct from…" table).
- **Mark-done / dismiss affordance.** An action row can be **marked done** (a display state —
  never an action in the world) or **dismissed/snoozed**; an item also **auto-clears** when
  the read-model reports its source state changed (doc applied, PR merged). Persist the
  display state the same way thread read-state is persisted ([[work-063]] `settings`/reads).
- **Feed from the read-model, not a second scan.** Consume the pure `buildOwnerActions`
  read-model specced in [[work-083]] (mirrors `buildNotifications`) — the route stays a thin
  loader + render, so ordering/dedup/done-detection stay unit-testable in the lib seam.
- **Nav badge.** Fold genuine Owner-action items into the persistent unread/needs-you count
  from [[work-063]] so "something needs you" is one number — without double-counting an item
  already surfaced as a thread.
- **Honest-empty.** When there are no Owner-action items the section is honestly empty (its
  own copy) — never a fabricated row, matching the activity feed / thread-notification
  discipline.

## Gate class — agent-buildable
Periphery only (the Console app + `@scope-creep/design`). Ordinary [[dev-cycle]]; QA drives
the surface with real Owner-action items (a pending owner-apply doc, an open escalation PR).
If a **new status color / motion token** is needed for the "action needed" affordance, that
is a `@scope-creep/design` API change and is **Owner-gated** per [[decision-rights]]
([[adr-022]] §7b precedent, as in [[work-082]]) — call it out in review, don't slip it in.
The app **never** spends, applies a file, applies `owner-approved`, or merges — it surfaces
and links only ([[invariants]] §II–III).

## Dependencies
Depends on [[work-063]] (the surface it extends — do not duplicate), [[work-083]] (the
`buildOwnerActions` read-model shape), and [[work-084]] (the owner-apply `pending|applied`
source). Shows full value once all three land.

**Acceptance:** with real Owner-action items present, the Owner sees a distinct "action
needed" section listing each ask with its action, why, and a working link; can mark an item
done or dismiss it and see it leave the plate; an item auto-clears when its source state
changes; the nav badge reflects genuine action items without double-counting threads; the
section is honestly empty when nothing is on the Owner's plate.
