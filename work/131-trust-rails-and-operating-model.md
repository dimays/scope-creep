---
id: work-131
title: Trust rails + operating model — evidence bundles, canaries, runaway caps, loops 14→7, weekly digest (roadmap-002 WS6)
type: feature
status: proposed
priority: high
owner: chief-reality-officer
spec: roadmap-002
created: 2026-09-24
updated: 2026-09-24
---

The rails that replace per-PR Owner approval ([[adr-028]], [[decision-rights]]).

## Acceptance
- **Evidence bundle.** The reviewer refuses any PR that lacks one. The bundle holds:
  - the originating kernel id (untraced work is held, which defends against injection);
  - the QA artifact;
  - a green escalation check;
  - an approver who is not the author.
- **Trust metrics.** Seed canary bad-PRs, and publish the revert, false-green and canary-catch rates.
- **Runaway caps.** Cap PRs per day and runs per day. Exceeding a cap pauses the org and pings the Owner.
- **Loops 14 → 7, owned by the CoS.** Keep kernel-intake, build (with demo and delight stages), heal, new-app, core-upgrade, decision, and a weekly org-tune. board-hygiene is cut, and board status comes from GitHub.
- **Weekly digest.** The CoS sends the Owner one digest a week. It lists what shipped, each decision with its override link, what's in flight, the trust metrics, and the Owner queue.
- **Self-tuning cadence.** Retract the claim ([[work-122]]).

Co-owned with the [[chief-of-staff]].
