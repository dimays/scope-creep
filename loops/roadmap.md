---
name: roadmap
description: The roadmap-planning loop — on a monthly cadence the full C-suite reviews the user experiences, releases, and version-bumps since the last roadmap against the existing roadmap, plans the next one in detail (user stories, PRDs, ADRs), and the CEO presents it to the board (the Owner); the presentation + release notes are stored and shown in the Console. Time-scheduled.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-24
  mode: partially-autonomous
  cadence: 30d            # seed interval; the live value is tracked in the ledger (see "Cadence")
  cadence_bounds: 14d..90d # min..max the re-tuning (via evolve) may move the interval within
---

# Loop: roadmap

The **forward-looking planning loop**. Where [[level-set]] looks *down and back* (what has
drifted, what we got wrong → a ranked paydown backlog) and [[staffing-review]] tends the
roster, this loop looks *up and forward*: on a cadence the full C-suite plans **where the
product goes next** and the [[ceo]] presents that plan to the board — the Owner. It
**produces the roadmap artifacts** (user stories, PRDs, ADRs); the [[dev-cycle]] and
[[ticket-cycle]] then execute them. Ratified by [[adr-021]].

## roadmap vs level-set (no duplication)
Both convene the C-suite on a cadence, but they produce different artifacts at different
altitudes and must not be run as one:
- **[[level-set]]** — a *health/debt/reflection* sweep against ground truth → a ranked
  **paydown-and-lessons** plan. Backward- and inward-looking.
- **roadmap** — a *strategic planning* round → the **next roadmap** (PRDs, user stories,
  ADRs). Forward- and outward-looking.

They feed each other: level-set's debt items are **inputs** the roadmap round weighs
against new bets; the roadmap sets the direction level-set later measures drift against.
Keep them separate loops with separate cadences.

## When this loop fires (time-scheduled)
- **Cadence trigger:** the live interval — seeded at **30 days (monthly)** — since the last
  roadmap [[ledger]] entry. Monthly because the product is young and the Owner's feedback
  is frequent; the [[evolve]] loop may relax it toward the ceiling as the roadmap settles
  (bounds **14–90 days**; see [Cadence](#cadence)).
- **Ad hoc:** the Owner or [[ceo]] may call a round early (a pivot, a big release). The
  cadence is a floor, not a ceiling.
- **Not mid-effort.** Like [[level-set]], it does not interrupt an authorized push; the CoS
  schedules it into the following lull so the C-suite plans against a settled state.

## Cadence
Two homes, split by what changes and how often (the pattern [[staffing-review]] established):
- **Policy — stable, org-governed — the manifest.** `metadata.cadence` (seed) and
  `metadata.cadence_bounds` live here; changing them is a reviewed, CoS-ratified PR, not a
  [[core-upgrade]] ([[adr-028]]). The [[evolve]] loop's portfolio review is what proposes
  moving them.
- **State — live — the [[ledger]].** The current interval is the most recent roadmap ledger
  entry's `next_cadence_days`; on the first run the manifest seed is the live value. Because
  the roadmap's cadence is re-tuned by [[evolve]] (the loop that owns the *portfolio* of
  scheduled cadences), this loop does not self-tune inside itself — it records the interval
  it fired at and lets [[evolve]] adjust the policy when the portfolio review warrants.

## Inputs (typed)
- `since` (ledger entry ref) — the previous roadmap round's ledger entry, or none on first run.
- `domain_hats` (list, default: full C-suite minus [[git-manager]]/[[qa-tester]]/[[code-reviewer]],
  who execute rather than hold a domain) — the executives planning this round; the [[ceo]] chairs.

## Steps
1. **Convene** (CEO chairs, CoS orchestrates). Name the round's hats — default full C-suite,
   subgroups as the agenda warrants. Apply [[resource-budget]] spawn discipline (stagger,
   mix tiers, cap Opus-tier seats) — the full-roster fan-out is the exact shape that has
   broken sessions ([[level-set]] § Spawn discipline); this loop inherits that caution.
2. **Review since the last roadmap, read-only.** Three input streams, each owned:
   - **User experiences** tracked since `since` — Owner feedback, [[request-intake]] threads,
     the Human-Input Log, and Console usage signals ([[chief-product-officer]] owns; the
     metrics that tell us whether a feature earns its place).
   - **Developments / releases / version-bumps** since `since` — landed work, [[ledger]]
     completions, the changelog, and core semver bumps ([[cto]] + [[chief-knowledge-manager]]).
   - **The existing roadmap** — the [[prd]] roadmap section + the `product/*.prd.md` set:
     what shipped, what slipped, what is now stale ([[chief-product-officer]]).
3. **CRO reality-check** ([[chief-reality-officer]]). No planning input is trusted on
   assertion: did the "releases since last roadmap" actually ship (a green gate, a merged
   PR), or is a claimed release assumed? Is a "tracked user experience" real signal or
   inferred? Label load-bearing inputs **verified / inferred / assumed** before they shape
   the plan ([[adr-007]]).
4. **Plan the next roadmap in detail.** Produce the artifacts — **user stories**, **PRDs**
   (`product/*.prd.md`), **ADRs**, and any other planning artifact — each tracing to a user
   problem + an observable success signal ([[chief-product-officer]] discipline). A
   load-bearing call *inside* the plan (a blessed-stack upgrade, a new app, a design-system
   change) routes through the [[decision]] loop rather than being settled here; this loop
   *assembles* the roadmap, it does not shortcut the decisions inside it.
5. **CEO decides, then presents to the board (the Owner).** The roadmap is an **org
   decision** ([[decision-rights]] v2: the [[ceo]] leads, the CRO verifies, the CoS
   ratifies). The CEO composes a board presentation of the ratified roadmap and surfaces it
   to the Owner with the weekly digest. It is **not an approval gate** ([[invariants]] §4a,
   [[adr-028]]): the roadmap stands unless the Owner overrides it, and the org frames it so
   an override is cheap. Items inside it that fall in an "Owner holds" class — spend
   (including enabling metered compute), a §III.7 deploy / delete / publish, credentials or
   permissions, a safety-kernel change ([[core-upgrade]]) — stay held for the Owner
   individually; the CEO cannot self-authorize those ([[ceo]]).
6. **Store & surface.** The presentation **and** the round's release notes are stored and
   shown in the **Console** (the [[prd]] roadmap section is updated supersede-not-destroy;
   the `product/` artifacts land via the gated PR path). The *Console surface* for
   presentations + release notes is a **product concern the [[chief-product-officer]] specs
   in parallel** — this loop only asserts the need and hands off the artifacts; it does not
   design the UI. Storing/showing in the single-user Console is internal, not an external
   publish; any outward publish stays Owner-gated ([[invariants]] §III.7).
7. **Record.** Append a [[ledger]] entry: hats convened, the CRO verdict, the roadmap
   version + artifact ids (PRDs / ADRs / user stories), the CoS ratification and any Owner
   override, and the
   interval this run fired at (for [[evolve]]'s portfolio review). This entry becomes
   `since` for the next cadence count.

## Outputs (typed)
- A [[ledger]] entry carrying the new roadmap version, its artifact ids, the CoS
  ratification, and any Owner override.
- Zero or more new/updated `product/*.prd.md`, ADRs, and user stories (each via the gated PR
  path).
- A **board presentation + release notes** handed to the Console surface (product-owned).
- Zero or more [[dev-cycle]] rounds opened to execute the accepted roadmap.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 7 once the ledger entry
is recorded, in exactly one of — **roadmap ratified** (CoS ratified and surfaced;
artifacts recorded; `since` advances), **revised** (the CRO check failed or the Owner
overrode it → re-enter at step 4, bounded by the deciders' judgment), or **deferred** (the
CEO or the Owner explicitly parks it; `since` still advances so the next cadence starts
clean). The loop's job stops at the recorded roadmap; executing it
is the [[dev-cycle]]'s job.

## Notes
- **`metadata.mode` = partially-autonomous:** convene / review / plan / ratify run
  unattended; step 5 surfaces the result to the Owner for override, not approval
  ([[adr-028]]). Only "Owner holds" items inside the plan wait for the Owner.
- **Release-notes generation** (harvesting landed work + version bumps into human-readable
  notes) and the **Console surface** that stores/shows presentations + notes are *build
  work*, not part of this loop's definition — tracked as tickets against the Console
  (product-owned). This loop assumes those exist and hands them the artifacts.
