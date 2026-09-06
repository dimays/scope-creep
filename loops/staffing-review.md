---
name: staffing-review
description: The recurring staffing-health loop — the Chief of Staff audits the employee roster, the template catalog, and the model presets on a cadence, retiring stale employees and truing up presets against the resource budget, then tickets any change through the gated path. The "ongoing, automated" staffing project.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
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
  **or 3 calendar weeks** since the last staffing-review [[ledger]] entry — whichever comes
  first. The CoS counts against the previous round's ledger entry; mechanical, not a
  judgment call.
- **Event trigger:** immediately after a **new template lands** or a **model-catalog
  change** (`reference/models.json`), to re-true presets against the tiers.
- **Ad hoc:** the Owner or CEO may invite a round early. The cadence is a floor, not a ceiling.
- **Not mid-effort.** Like [[level-set]], it does not interrupt an authorized push; the CoS
  schedules it into the following lull so it assesses a settled roster.

## Inputs
- `since` (ledger entry ref) — the previous staffing-review's ledger entry, or none on the first run.
- `events_count` (int) — spin-ups + retirements since `since`; the cadence counter.
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
7. **Record.** Append a [[ledger]] entry: what was audited, retirements proposed, catalog
   changes, preset trues-up, the CRO verdict, and the resulting ticket ids. This entry
   becomes `since` for the next cadence count.

## Outputs
- A [[ledger]] entry carrying the staffing-health verdict and the resulting ticket ids.
- Zero or more new/updated `work/` tickets, handed to [[ticket-cycle]].
- Zero or more [[decision]] loop invocations, where a finding is itself load-bearing.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 7 once the ledger entry
is recorded, in exactly one of two states — **findings-ticketed** (one or more tickets
opened) or **clean** (roster/catalog/presets healthy, no tickets this round). Either way
`since` advances so the next cadence count starts clean. Executing any ticketed fix is
[[ticket-cycle]]'s job, not this loop's.

## Notes
- **`metadata.mode`** follows [[glossary]]'s Loop definition. This loop is
  `partially-autonomous`: harvest/audit/synthesize run unattended; the gates are the
  ordinary [[ticket-cycle]]/PR approvals on any change it proposes (no separate Owner step
  inside the loop, since it only produces proposals).
- This loop assesses staffing; it does not decide load-bearing questions on its own
  authority — step 6 hands those to [[decision]]. It is the mechanical sweep that keeps the
  [[staffing]] standard from rotting between [[level-set]] rounds.
