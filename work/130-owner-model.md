---
id: work-130
title: Owner Model — taste.md + kernel files in the private scope-creep-owner repo (roadmap-002 WS5)
type: feature
status: proposed
priority: high
owner: chief-knowledge-manager
spec: roadmap-002
created: 2026-09-24
updated: 2026-09-24
---

The org remembers its process but almost nothing about the Owner. Fix that in
`dimays/scope-creep-owner`, which is **private** and was created on 2026-09-24.

## Acceptance
- **Human-input log.** Move it into the private repo, and point the capture hook at it.
- **`taste.md`.** Each line cites its source input and date. Superseded preferences are kept.
- **Kernel files.** One file per kernel: the Owner's words verbatim, the interpretation, what shipped, the reaction, and the next wave.
- **`owner.json`.** A generated, non-verbatim summary that every agent loads as step 0 (AGENTS.md).
- **Replay set.** Classify the M3 replay set of real kernels, and re-derive the "Owner touches per kernel" baseline.
- **Privacy.** No verbatim Owner text ever lands in a public repo (INVARIANTS §6).
