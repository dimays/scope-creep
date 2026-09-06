---
id: work-035
title: A resource-stewardship standard (token / API / compute budget)
type: feature
status: done
priority: low
owner: chief-of-staff
spec: tech-sops
branch: work-035-resource-budget
pr: https://github.com/dimays/scope-creep/pull/17
created: 2026-09-05
updated: 2026-09-06
---
From the Owner's org-design question. This session hit the **usage limit twice** (once
mid-dry-run, killing three agents). As the factory runs more autonomously — more agents,
longer loops — someone must own the budget and pace work against limits. Start as a
standard owned by the CoS ([[decision-rights]] assigns resource decisions to the CoS),
not a new executive seat.

- Add `standards/resource-budget.md`: how the factory spends its finite budget — model
  selection by task tier (cheap/routine vs. expensive/agentic, per `reference/models.json`),
  spawn discipline (stagger; don't fan out five Opus agents at once), graceful behavior at
  a usage limit (checkpoint + resume, not lose work), and when a spend increase is
  Owner-gated.
- Tie model-tier selection to [[work-018]] (model selection).

**Acceptance:** a documented budget standard the C-suite follows; the level-set loop
([[work-033]]) references it for spawn discipline. See [[tech-sops]], [[work-018]].

**Revisit:** if resource management outgrows a standard, propose a dedicated role via
[[decision-rights]].

**Done (2026-09-06):** shipped `standards/resource-budget.md` — model selection by
task tier (routine/chat/agentic, sourced from `reference/models.json`, tied to
[[work-018]]), spawn discipline (stagger, bound concurrent expensive agents, mixed
tiers), graceful behavior at a usage limit (checkpoint before fan-out, resume from
committed work, record the incident), and the line between routine tier selection
and an Owner-gated spend increase ([[invariants]] §III.7, [[decision-rights]]). The
level-set loop ([[work-033]]) is cross-linked to pull this for its own spawn
discipline once it lands.
