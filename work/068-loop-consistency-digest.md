---
id: work-068
title: Request Loop consistency check + away-digest
type: feature
status: proposed
priority: medium
owner: chief-reality-officer
spec: prd-request-loop
created: 2026-09-07
updated: 2026-09-07
---
The difference between a demo and something the Owner would actually stop watching. A
projection loop drifts from its records; a Chief-Reality-Officer self-check catches it,
grounded in what the records actually show — the same discipline as the Human-Input Log
consistency check ([[adr-010]]).

Build:
- A **grounded consistency check** for the loop: flag real drift between threads, tickets,
  and notifications — e.g. a `needs-you` thread with no unread signal, a triaged request
  with no ticket, a shipped ticket with no thread outcome. Honest posture: report only what
  the records show; "no data" is never a false all-clear.
- An **away-digest**: "here's what the org did while you were gone" — the outcomes,
  merges, and open needs-you items since the Owner's last visit — so returning after a day
  away is a 20-second read, not an archaeology dig.

**Acceptance:** the check surfaces real drift (grounded, no false all-clear) and stays quiet
when the loop is consistent; the Owner can read a digest of org activity since their last
visit. See [[prd-request-loop]], [[adr-010]], [[work-063]].
