---
name: ledger-117-staffing-review-first-run
description: The staffing-review loop's first real scheduled run (2026-10-26) — audited the employee roster, template catalog, and model presets. Clean except Quill, idle 32 days past its own flagging note with matching unstaffed doc-debt work sitting in its own executive's queue (ticketed as work-134, CRO-verified). First genuine machine-readable cadence-decision block on disk for any loop; cadence held at the 14-day seed.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-10-26
---

# Ledger 117 — staffing-review: first real run

**Date:** 2026-10-26 · **Recorded by:** Chief of Staff · **Trigger:** scheduled
(`trig_01D3wGKgqvTAwEV7Y5avk7tf`, per [[ledger-044-staffing-loop-automated]]).

## Due check
No prior staffing-review ledger entry carries a real `cadence-decision:` block
([[ledger-043-staffing-cadence-self-tuning]] and [[ledger-044-staffing-loop-automated]]
only describe the protocol — see [[work-122]]). Per [[staffing-review]]'s cadence
section, no prior entry means this is the **first run**, which is always due. Ran the
full loop.

## Harvest (read-only)
`bun run registry:build` → 15 agents, 15 employee templates, 14 loops; no diff against
committed `registry/` (clean, nothing to regenerate). `bun run work:check` → 126 items
OK. Read `registry/agents.json`, `registry/employee-templates.json`, and `assignees`
across `work/*.md`.

## Employee audit (ephemerality)
5 employees total. **4 already clean:** ada, linus, rae, vera were all retired
2026-09-24 in a prior system audit, each with its tickets `done`/`superseded` and zero
open tickets referencing it — re-confirmed, still accurate.

**1 finding — Quill.** `agents/employees/quill.md`: summoned 2026-09-06, corrected
`active → idle` 2026-09-24 with a note that it has never been staffed and the CKM
should staff-or-retire it, "held for CoS/Owner." 32 days later, nothing moved: still
`idle`, `grep -il quill work/*.md` → zero matches, and the matching work is still
sitting unstaffed in the CKM's own queue — [[work-123]] (doc-debt refresh, `proposed`
since 2026-09-24) and [[work-120]] (doc-freshness loop, `proposed`). A durably-idle
employee with in-scope, same-executive work waiting is exactly the drift
[[staffing]] §2 and this loop exist to catch.

**CRO spot-check** (per loop step 5, this finding would retire/restaff an employee):
verdict **verified**, independently re-checked against the files, not the summary —
Quill's idleness, the zero-ticket state, and work-123/120's open/in-scope status all
confirmed. Recommended ticketing a CKM disposition this round.

→ **Ticketed:** [[work-134]] — CKM stages Quill onto work-123 (and/or work-120) or
retires it. This loop proposes/tickets only; it does not execute either disposition.

## Template-catalog audit
15 templates, all `status: active`, no gaps or near-duplicates against the current
executive roster (each of the 6 non-CoS/CEO executives has a sensible set to summon
from; CoS has program-coordinator). All share `last_verified: 2026-09-06` (50 days,
unmoved since 4 real employee engagements completed against several of them) — a
freshness-sweep candidate, but spot-checking `frontend-engineer.md` against the
dark-mode-only decision ([[work-045]]) found no actual contradiction, and a systemic
doc-freshness sweep is already correctly ticketed ([[work-120]]/[[work-123]], endorsed
by [[evolve]]'s first run). Not duplicating that proposal here — no new ticket opened
for template staleness this round.

## Model-preset audit
All 15 templates' `default_model` resolves in `reference/models.json` and sits on the
cheapest tier that plausibly fits the role, matching [[staffing]] §4's table exactly:
14 on `claude-sonnet-5` (balanced/chat), 1 (`program-coordinator`) on
`claude-haiku-4-5-20251001` (routine/fast), **0 on the agentic/Opus tier** — correct
per [[resource-budget]] ("no template defaults to Opus"). No drift, no re-tiering
needed.

## Cadence-decision mechanism (relates to [[work-122]])
No loop — staffing-review included — had ever emitted a literal, parseable
`cadence-decision:` YAML block before this entry; 043/044 only describe the protocol
in prose. **This entry's block below is the first spec-conforming one on disk for any
loop.** Noted and partially closed [[work-122]] for staffing-review's slice; left it
open for the other scheduled loops (work-sweep's own blocks are a `### cadence-decision`
markdown heading, not the spec'd key — still non-conforming).

## Result
One finding, one ticket ([[work-134]]), CRO-verified. No catalog changes, no preset
re-tiers, no decision-loop escalation needed (routine staffing hygiene, not
load-bearing). Registry already matched harvested manifests — no regeneration commit
needed this round.

```yaml
cadence-decision:
  ran_at: 2026-10-26
  trigger: scheduled
  ran_at_cadence_days: 14
  signals:
    empty_scheduled_streak: 0
    adhoc_runs_since_last_scheduled: 0
  decision: hold
  next_cadence_days: 14
  reason: first run — no prior scheduled entry to compare against, so neither
    self-tuning signal fires; holds at the manifest seed (14d). One real finding
    was ticketed, so this was not an empty run; nothing to dial down. Next scheduled
    run should start building the empty/ad-hoc streak for real.
```
