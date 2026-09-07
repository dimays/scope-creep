---
name: staffing-review
description: The recurring staffing-health loop — the Chief of Staff audits the employee roster, the template catalog, and the model presets on a cadence, retiring stale employees and truing up presets against the resource budget, then tickets any change through the gated path. The "ongoing, automated" staffing project.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
  cadence: 14d           # seed interval; the LIVE value is self-tuned in the ledger (see "Cadence")
  cadence_bounds: 7d..42d # min..max the self-tuning may move the interval within
---

# Loop: staffing-review

Makes the [[staffing]] standard an **ongoing project**, not a one-time setup: on a
cadence the [[chief-of-staff]] checks that the org is staffed for consistent quality —
employees are ephemeral (not lingering), the template catalog is coherent and current, and
every model preset still matches [[resource-budget]]. It complements [[level-set]] (which
assesses *technical + organizational debt* across all domains) by owning the **staffing
slice** specifically; where level-set would surface a staffing problem in passing, this
loop is the standing, mechanical sweep that catches it first. Owned and run by the CoS,
whose mandate is *who & how* the org staffs work ([[adr-018]], [[adr-020]]).

## When this loop fires
- **Cadence trigger:** every **10 employee spin-ups or retirements** since the last run,
  **or the current time interval** — the self-tuned `cadence`, seeded at **14 days** and
  revised by the CoS each run (see [Cadence](#cadence-self-tuning-cos-owned) below) — since
  the last staffing-review [[ledger]] entry, whichever comes first. The CoS counts against the
  previous round's ledger entry; mechanical, not a judgment call.
- **Event trigger:** immediately after a **new template lands** or a **model-catalog
  change** (`reference/models.json`), to re-true presets against the tiers.
- **Ad hoc:** the Owner or CEO may invite a round early, or the CoS may self-trigger one when
  a real staffing need arrives before the cadence catches it. The cadence is a floor, not a
  ceiling. **Every ad-hoc run is logged** (a [[ledger]] entry whose `cadence-decision` block
  is marked `trigger: ad-hoc`) so the next scheduled run can count them — they are the
  TOO-SLOW signal that dials the cadence *up* (see [Cadence](#cadence-self-tuning-cos-owned)).
- **Not mid-effort.** Like [[level-set]], it does not interrupt an authorized push; the CoS
  schedules it into the following lull so it assesses a settled roster.

## Cadence (self-tuning, CoS-owned)

The schedule is a **staff-driven decision, not a fixed cron the Owner edits**. The CoS owns
the number, and the loop revises it on itself every run. Two homes, split by *what changes and
how often*:

- **Policy — stable, core-gated — the manifest.** `metadata.cadence` (the seed interval) and
  `metadata.cadence_bounds` (min..max), plus the protocol in this section, live in this loop
  manifest. They are the *mechanism*; changing them reshapes how tuning behaves and is a
  [[core-upgrade]] (Owner-gated, rare).
- **State — live, self-tuned — the [[ledger]].** The **current** interval is whatever the most
  recent staffing-review ledger entry recorded as `next_cadence_days`. Moving it is ordinary
  loop output (an append to the ledger), so self-tuning needs **no core edit and no gate** —
  the "automated" the Owner asked for, without routing around [[invariants]] §I.4. On the
  first run (no prior entry) the manifest seed is the live value.

**Initial cadence: 14 days (2 weeks)**, alongside the unchanged event triggers (10 spin-ups/
retirements; immediately after a template lands or `reference/models.json` changes). Chosen
because the roster is young and actively churning — 13 templates were just seeded ([[adr-020]])
and employees are about to start spinning up — so drift should be sensed *often* early; the
self-tuning below is expected to relax the interval toward the ceiling as the roster settles.

**Bounds: min 7 days, max 42 days.** The floor stops runaway thrash (the loop can never
schedule itself more than weekly); the ceiling stops dormancy (staffing can't rot unseen for
more than ~6 weeks). Every computed interval is clamped into `[7, 42]` and rounded to whole
days.

### The self-tuning protocol (step 7 of every run)

Runs after the audit, before Record. Read two signals from the [[ledger]] since the last
`trigger: scheduled` entry:

| Signal | Meaning | Adjustment |
|---|---|---|
| **Too frequent** — the last **2 consecutive scheduled runs were empty** (clean: no tickets opened, no catalog/preset change) | the cadence is running ahead of real change | **dial DOWN** (lengthen): `next = round(current × 1.5)`, clamped to max |
| **Too slow** — **≥1 ad-hoc run since the last scheduled run** (a real staffing need beat the cadence — the Owner's named signal) | the cadence is trailing real change | **dial UP** (shorten): `next = round(current ÷ 1.5)`, clamped to min; **≥2 ad-hoc runs → `÷ 2`** |
| neither | the cadence is tracking reality | **hold** |

- **Precedence:** if both fire, **too-slow wins** — responsiveness beats economy; a real need
  that beat the cadence is the stronger evidence.
- **Reflect, don't reflex.** The table is the default; the CoS may override with a one-line
  reason in the ledger (e.g. hold through a known one-off churn spike). The number is the CoS's
  call — that is what *staff-driven* means. Bounds are never overridable.
- The run **records the decision and the new interval to the ledger** (block below); that
  recorded `next_cadence_days` is the live cadence for the next cycle.

### How a run requests a reschedule

The operating session wires an actual recurring trigger (a scheduled task) that fires this
loop. The contract between the loop and that trigger is a single fenced block every run
appends to its ledger entry — scheduled, ad-hoc, or event:

```yaml
cadence-decision:
  ran_at: 2026-09-06
  trigger: scheduled          # scheduled | ad-hoc | event
  ran_at_cadence_days: 14     # the interval this run actually fired at
  signals:
    empty_scheduled_streak: 0            # consecutive empty scheduled runs incl. this one
    adhoc_runs_since_last_scheduled: 0
  decision: hold              # lengthen | shorten | hold
  next_cadence_days: 14       # the live cadence from here on (bounds-clamped)
  reason: on-cadence; roster churning as expected
```

The recurring trigger reads the **most recent** staffing-review ledger entry's
`next_cadence_days` and sets its next fire that many days out. Nothing else needs updating —
the ledger is the single moving value, and the manifest seed only ever serves the first run.
An **ad-hoc** run emits the same block with `trigger: ad-hoc` (its `next_cadence_days` may
equal the current value); the *fact* of the ad-hoc run is what the next scheduled run counts.

## Inputs
- `since` (ledger entry ref) — the previous staffing-review's ledger entry, or none on the first run.
- `events_count` (int) — spin-ups + retirements since `since`; the cadence counter.
- `cadence_days` (int) — the live interval this run fired at: the most recent ledger entry's
  `next_cadence_days`, or the manifest `cadence` seed on the first run.
- `catalog` — `reference/models.json` (the model tiers to true presets against).

## Steps
1. **Harvest, read-only.** Regenerate the registries (`bun run registry:build`) and read
   `registry/agents.json` (employees + their `reports_to`/`template`/`status`),
   `registry/employee-templates.json` (the catalog + `owner_agent` + `default_model`), and
   the `assignees` across `work/*.md`. Ground truth, not prior claims. Apply
   [[resource-budget]] spawn discipline if any sub-assessment is fanned out — but this loop
   is deliberately low-fan-out (the CoS runs it directly; heavy fan-out is the pattern that
   has broken sessions).
2. **Audit employees (ephemerality).** For each employee: is it `active` with a live,
   unfinished `assignees` ticket? An employee whose tickets are all `done`/`dropped`, or
   that has sat `idle` past a round, is a **retirement candidate** (status → `retired` + a
   reason — never `rm`, [[invariants]] §III.10). Flag orphans (no resolving ticket) and
   over-loaded employees (too many live tickets for one worker).
3. **Audit the template catalog.** Does each executive have a sensible set to summon from?
   Flag **gaps** (a role repeatedly summoned ad hoc with no template), **duplicates** (two
   near-identical templates that should merge), and **stale operating manuals** (a template
   whose guidance drifted from current standards). Templates are mutable — improving one is
   the expected outcome here.
4. **True up model presets.** For every template `default_model` and every per-employee
   override, confirm it (a) resolves in `reference/models.json` (a retired ID must fail hard
   and fall back to the tier default — [[work-018]]) and (b) still sits on the *cheapest
   tier that plausibly does the role's work* ([[resource-budget]] §1, [[staffing]] §4).
   Flag any preset that drifted up to a pricier tier without a demonstrated need.
5. **CRO spot-check.** Any finding that would retire an employee, reshape the catalog, or
   change a preset is verified by the [[chief-reality-officer]] against reality before it
   reaches a ticket — the same discipline [[decision]] and [[level-set]] apply, scoped to
   the load-bearing findings.
6. **Synthesize + ticket.** The CoS turns accepted findings into `work/` tickets (retire
   employee X; add/merge/refresh template Y; re-tier preset Z), each running the ordinary
   [[ticket-cycle]] gate. A finding that is itself a **load-bearing call** (e.g. reshaping
   the taxonomy, or a spend-touching catalog change) is routed through [[decision]], not
   silently folded in. This loop **proposes and tickets**; it never executes a fix itself,
   and every authoring change stays on the gated propose → PR path ([[adr-017]] §E).
7. **Tune the cadence (self-tuning).** Read the two cadence signals from the [[ledger]] since
   the last `trigger: scheduled` entry — the empty-scheduled-run streak and any ad-hoc runs —
   and decide **lengthen / shorten / hold** per the [Cadence](#cadence-self-tuning-cos-owned)
   protocol (bounds-clamped), carrying the chosen `next_cadence_days` into the record below.
   This is the step where the schedule becomes a staff-driven decision *each run*, not a fixed
   config: the CoS revises its own cadence in response to whether the loop is firing too often
   (empty runs) or too late (a need beat it to the punch).
8. **Record.** Append a [[ledger]] entry: what was audited, retirements proposed, catalog
   changes, preset trues-up, the CRO verdict, the resulting ticket ids, **and the
   `cadence-decision` block** (signals → decision → `next_cadence_days` → reason). This entry
   becomes `since` for the next cadence count, and its `next_cadence_days` is the live cadence
   the recurring trigger reads to reschedule itself.

## Outputs
- A [[ledger]] entry carrying the staffing-health verdict and the resulting ticket ids.
- A **cadence decision** (`next_cadence_days` + reason) recorded in that same ledger entry —
  the live interval the recurring trigger reads to reschedule itself.
- Zero or more new/updated `work/` tickets, handed to [[ticket-cycle]].
- Zero or more [[decision]] loop invocations, where a finding is itself load-bearing.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 8 once the ledger entry
is recorded, in exactly one of two states — **findings-ticketed** (one or more tickets
opened) or **clean** (roster/catalog/presets healthy, no tickets this round). Either way the
entry carries a `cadence-decision` block and `since` advances, so the next cadence count and
the next tuning cycle both start from a recorded baseline. Executing any ticketed fix is
[[ticket-cycle]]'s job, not this loop's.

## Notes
- **`metadata.mode`** follows [[glossary]]'s Loop definition. This loop is
  `partially-autonomous`: harvest/audit/synthesize run unattended; the gates are the
  ordinary [[ticket-cycle]]/PR approvals on any change it proposes (no separate Owner step
  inside the loop, since it only produces proposals).
- This loop assesses staffing; it does not decide load-bearing questions on its own
  authority — step 6 hands those to [[decision]]. It is the mechanical sweep that keeps the
  [[staffing]] standard from rotting between [[level-set]] rounds.
