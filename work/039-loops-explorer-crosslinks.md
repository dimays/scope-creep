---
id: work-039
title: Loops explorer + cross-link pass (one cohesive graph)
type: feature
status: done
priority: medium
owner: chief-designer
spec: prd-console-explore
created: 2026-09-06
updated: 2026-09-06
---
Render Loops in the Console and complete the exposure graph so every point of interest
links into one experience (Theme 3). Extends [[prd-console-explore]].

- Console: a **Loops** panel on home + `/explore/loops` index + `/explore/loops/:name`
  profile, mirroring the agent pattern (reuse the [[work-019]] clickable-registry precedent).
- **Backlinks** ("referenced by") from the inverted `[[wiki-link]]` index, on doc/agent/loop
  pages — pure derivation, zero new authoring.
- Agent-page rollups: loops owned, docs owned, tickets owned (`owner_agent`/`owner` fields);
  fix ledger-contribution rows to deep-link the actual entry, not `/explore/timeline`.

- **Depends on:** [[work-038]] (`loops.json`).

**Acceptance:** an agent ↔ its docs ↔ loops ↔ ledger events ↔ tickets form a closed,
navigable loop; a doc shows what references it. See [[prd-console-explore]].
