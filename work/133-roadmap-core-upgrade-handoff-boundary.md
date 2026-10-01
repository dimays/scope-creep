---
id: work-133
title: Clarify loops/roadmap.md — structural/charter asks surfaced mid-round hand off to core-upgrade, don't bundle into the roadmap artifact
type: debt
status: proposed
priority: medium
owner: cto
spec: adr-021
created: 2026-10-01
updated: 2026-10-01
---

[[adr-021]] §D's handoff rule is explicit for [[evolve]]: a *structural* need surfaced during a
loop round escalates **up**, as its own proposal — it doesn't get folded into that round's own
artifact. [[roadmap]]'s loop doc never states the equivalent rule for itself, and the gap showed
up in practice: the open **PR #140** ("Autonomy charter (ADR-028) + roadmap-002") bundles a
roadmap round with a full safety-kernel rewrite in one escalation-class PR — new
`charter/PRINCIPLES.md`, `INVARIANTS v2.0.0`, `standards/decision-rights.md` v2, narrowed
CODEOWNERS, and edits to **11 of the 13 loop files** including [[evolve]] and [[level-set]]
themselves. Whatever its merits, a structural/charter-level change of that size inside a
single roadmap PR makes the artifact hard to review incrementally and ties ordinary roadmap
content (user stories, PRDs) to an Owner-apply-only mega-change — the PR has sat open and
unmerged for a week, `mergeable_state: behind`, blocking nothing by design but illustrating the
risk the handoff rule exists to avoid.

## Acceptance
- `loops/roadmap.md` states a handoff rule mirroring [[adr-021]] §D/[[evolve]]'s own: a
  structural or safety-kernel-touching need surfaced during a roadmap round (a new standing
  function, an INVARIANTS/decision-rights change, a loop-portfolio rewrite) is **named** in the
  roadmap artifact but **proposed as its own [[core-upgrade]] PR**, reviewable and
  mergeable independently of the roadmap's ordinary product content.
- No retroactive change to PR #140 itself — this is a documentation fix for future rounds, not a
  request to split up work already in flight.

## Notes
Surfaced by [[evolve]]'s first scheduled round ([[ledger-083-evolve-first-run]]), step 3
(scheduled-loop portfolio review) — roadmap's cadence verdict is **hold** (30d seed is fine;
nothing here is a timing problem), but the loop's own handoff boundary needs the same explicit
statement [[evolve]] already has. A `loops/*.md` edit is a core change — route through
[[core-upgrade]], Owner-approved.
