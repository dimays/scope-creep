---
name: ledger-081-staffing-review-first-run
description: First-ever scheduled staffing-review run (2026-09-28) — audited the employee roster (5 employees; 4 correctly retired, quill durably idle since 2026-09-06 with no ticket), the 15-template catalog (coherent, no gaps/dupes/stale manuals), and every model preset against reference/models.json (all correctly tiered, no drift to the agentic tier). Ticketed one CRO-verified finding (work-125 — restaff Quill onto work-123 or retire) and emitted the first machine-readable cadence-decision block (closing part of work-122's gap for this loop), holding the cadence at the 14-day seed.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-28
---

# Ledger 081 — staffing-review first run (2026-09-28, scheduled)

**Date:** 2026-09-28 · **Trigger:** scheduled `staffing-review` cloud routine (cron `0 14 * * 1`,
`trig_01D3wGKgqvTAwEV7Y5avk7tf`) · **Due check:** no prior `cadence-decision` block exists anywhere
in the ledger (confirmed by search) — the mechanism was wired 2026-09-06
([[ledger-043-staffing-cadence-self-tuning]], [[ledger-044-staffing-loop-automated]]) but had never
actually fired end-to-end, the exact gap [[work-122]] surfaced. Per the loop's own rule ("on the
first run (no prior entry) the manifest seed is the live value"), this run is **DUE** by
definition.

## What ran

Per [[staffing-review]] steps 1–4, run directly by the CoS (deliberately low-fan-out — one CRO
spot-check only, per the loop's own guidance):

1. **Harvest.** `bun run registry:build` — clean, no diff (15 agents, 15 templates, 14 loops;
   pre-existing apps/extensions manifest warnings unrelated to staffing). Read
   `registry/agents.json`, `registry/employee-templates.json`, `agents/employees/*.md`,
   `reference/models.json`, and cross-checked `work/*.md` `assignees`.

2. **Employee ephemerality audit (5 employees).**
   | Employee | Template | Status | Finding |
   |---|---|---|---|
   | ada | frontend-engineer | retired | Correct — staffed tickets landed, no open ticket refs it. |
   | linus | backend-engineer | retired | Correct — same. |
   | rae | researcher | retired | Correct — same. |
   | vera | qa-verifier | retired | Correct — same. |
   | **quill** | technical-writer | **idle** | **Flag.** Created 2026-09-06, corrected `active`→`idle` by [[ledger-079-system-audit]] (2026-09-24) after never being staffed. Still idle 4 days later with zero `assignees` references anywhere in `work/*.md` (confirmed by grep) — durably idle past a round, per [[staffing]] §2's own definition. The 079 audit explicitly held the retire-or-restaff call for this loop. |

3. **Template catalog audit (15 templates).** Every executive has a sensible, non-overlapping
   set to summon from; every employee's `template` field resolves to a real template; no
   role found summoned ad hoc without one. No gaps, no near-duplicate templates, no operating
   manual visibly drifted from current standards (`last_verified` dates 2026-09-06…2026-09-24,
   all inside the current standards regime). **No catalog changes proposed this round.**

4. **Model preset true-up.** `reference/models.json` defaults: `routine`=`claude-haiku-4-5-20251001`,
   `chat`=`claude-sonnet-5`, `agentic`=`claude-opus-4-8`. Checked every template `default_model`
   and every employee manifest for a per-instance override:
   - `program-coordinator` → `claude-haiku-4-5-20251001` (routine tier) — correct, the sole
     fast-tier template, matches [[staffing]] §4's table exactly.
   - All 14 other templates → `claude-sonnet-5` (balanced tier) — correct; **zero templates
     default to the agentic tier**, matching the "default down, escalate up" rule.
   - **Zero per-employee overrides found** across all 5 employee manifests (`grep model
     agents/employees/*.md` matched no `model:` field, only prose) — no drift to the expensive
     tier without demonstrated need. **No preset changes proposed this round.**

## CRO spot-check (step 5)

The one load-bearing finding (Quill retire-or-restaff) was independently verified by the
[[chief-reality-officer]] before ticketing: confirmed quill.md's `idle` status and zero
`assignees` references first-hand (not taking the CoS's summary on faith); confirmed
[[work-123]] is still `proposed`/owned by the CKM and its acceptance criteria are a plausible
technical-writer fit, with the caveat that a couple of work-123 sub-items (the ADR-003
dead-reference reconciliation, the design-package pin confirmation) lean toward engineering
judgment and should stay out of Quill's scoped slice; confirmed the CoS is proposing a ticket
for the CKM's own call, not unilaterally retiring Quill itself, per [[staffing]] §2. **Verdict:
PASS**, no corrections needed. The ticket below incorporates the scoping caveat.

## Ticketed (step 6)

- **[[work-125]]** — Resolve Quill's durably-idle status: restaff onto (a scoped slice of)
  [[work-123]], or retire with a one-line reason. Owner: `chief-knowledge-manager` (Quill's
  `reports_to`) — the CoS proposes, does not execute. Proposed → ordinary [[ticket-cycle]] gate.

No template-catalog or model-preset tickets this round (both clean).

## Cadence tuning (step 7)

```yaml
cadence-decision:
  ran_at: 2026-09-28
  trigger: scheduled
  ran_at_cadence_days: 14
  signals:
    empty_scheduled_streak: 0
    adhoc_runs_since_last_scheduled: 0
  decision: hold
  next_cadence_days: 14
  reason: first run ever recorded (no prior cadence-decision block existed — the wiring gap work-122 surfaced); manifest seed (14d) stands as the live value per the loop's own first-run rule. Not empty (one ticket opened) and no ad-hoc runs to weigh, so neither tuning signal fires on its own terms either. Hold at 14d and let the next scheduled run make the first real tuning call.
```

This is also the **first machine-readable `cadence-decision` block ever emitted** by any
scheduled routine — it directly advances [[work-122]] (the "zero live blocks on disk" gap) for
the `staffing-review` loop specifically. The other five scheduled routines (`roadmap`, `evolve`,
`request-triage`, `work-sweep`, `board-hygiene`) still need their own first emission; work-122
stays `proposed` and open for those, not closed by this entry.

## Registry / gates

No harvested field changed by this run's findings (no template/preset edit landed — those are
`work-125`'s, not this ledger entry's). `bun run registry:check` clean (already confirmed at
harvest, step 1). `bun run work:check` to be reconfirmed after `work-125` is added (new ticket,
schema-valid: required fields present, `owner: chief-knowledge-manager` resolves, `spec: adr-020`
resolves).

## Governance

Propose-only, as every scheduled routine must be ([[invariants]] §III): this entry + `work-125`
land via a PR the Owner (or `@scope-creep-review`) dispositions; nothing is merged by this
session. Sets `since` for the next staffing-review cadence count and hands the next scheduled
run (or any ad-hoc round the CoS self-triggers before then) a recorded baseline to tune against.
