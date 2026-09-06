---
id: work-031
title: Inline agent activity in threads (ledger-projected)
type: feature
status: proposed
priority: medium
owner: chief-product-officer
assignees: rae
spec: prd-cos-threads
created: 2026-09-05
updated: 2026-09-06
---
Phase 3 of [[prd-cos-threads]]; the **episodic lens** of [[prd-transparent-delegation]].
Let the Owner watch the org work inside a thread.

- Project **C-suite spin-ups**, **delegations to employee agents**, and
  **CoS↔executive confers** into the thread timeline as read-only activity events.
- **Refit (2026-09-06, [[adr-013]]):** source the delegation **graph** from the structured
  `activity/*.ndjson` log ([[work-036]]), **not** the prose ledger — projecting typed events
  from prose would mean inventing them. Decisions link to the ledger entries agents write.
  The thread never invents activity, it reflects what was already logged.
- **Depends on:** [[work-036]] (capture) + [[work-037]] (the ActivityRow primitive).

**Acceptance:** a thread that triggered agent work shows the spin-ups/delegations/confers
inline, each deep-linking to its artifact. See [[prd-cos-threads]] and [[adr-013]].
