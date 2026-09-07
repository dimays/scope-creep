---
name: evolve
description: The org self-improvement / evolution loop (meta) — on a monthly-to-quarterly cadence the org generates the new machinery scaling demands (procedures, employee templates such as DevOps and Security, new loops/functions) AND re-tunes the whole portfolio of scheduled loops (are they firing at the right cadence, still needed, any missing?). Distinct from level-set: generativity + meta-cadence governance, not debt paydown. Time-scheduled; it re-tunes every other loop's cadence.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
  cadence: 30d            # seed interval; the live value is tracked in the ledger (see "Cadence")
  cadence_bounds: 30d..90d # min..max: monthly while the org is young, relaxing toward quarterly
---

# Loop: evolve

The **meta loop**: the org improving *itself*. On a cadence it asks two questions no other
loop owns — **what new machinery does the org need as it scales?** and **is the standing
portfolio of scheduled loops still right?** It is **generative and structural**, where
[[level-set]] is *debt paydown + reflection* and [[staffing-review]] is *roster
maintenance*. Ratified by [[adr-021]]. This loop is deliberately **distinct from
[[level-set]]**, not an extension of it — folding generativity into the debt sweep would
overload a loop already carrying two input streams (the same reason [[adr-020]] rejected
folding staffing into level-set).

## The three self-tending loops — clean boundaries
| Loop | Owns | Horizon | Cadence |
|---|---|---|---|
| [[staffing-review]] | the **roster**: employees, the template catalog, model presets | maintenance | ~14d self-tuning |
| [[level-set]] | **debt + lessons** across existing domains | backward/inward | 15 tickets or 2wk |
| **evolve** (this loop) | **new machinery** + the **scheduled-loop portfolio** | forward/structural | 30d, → quarterly |

**Handoffs both directions** (so nothing is done twice):
- A finding that is really a *catalog gap or a stale template* → hand to [[staffing-review]]
  (its job), don't seed it here.
- A finding that is really *debt in an existing domain* → hand to [[level-set]] (its job).
- [[staffing-review]] or [[level-set]] surfacing a *structural* need (a whole new function
  tier, a new loop, a new procedure) → escalate **up** to this loop.

This loop seeds the **proactive/anticipatory** machinery (a role we can see we'll summon
repeatedly *soon*; a procedure we keep improvising); the other two handle the
**reactive/existing** surface.

## When this loop fires (time-scheduled)
- **Cadence trigger:** the live interval — seeded at **30 days (monthly)** — since the last
  evolve [[ledger]] entry. Monthly while the org is young and scaling fast (DevOps and
  Security are near-term, per the Owner); relaxing toward **quarterly** as machinery
  settles (bounds **30–90 days**; see [Cadence](#cadence)).
- **Ad hoc:** the Owner or [[ceo]] may call a round early when a scaling pressure is
  obvious. The cadence is a floor.
- **Not mid-effort.** It schedules into the following lull, like [[level-set]].

## Cadence
This loop **owns the portfolio of scheduled cadences** — it is the one that re-tunes *every*
time-scheduled loop, and itself:
- **Its own cadence** self-tunes the [[staffing-review]] way: the live `next_cadence_days`
  lives in the [[ledger]]; the seed/bounds in this manifest are the mechanism and change
  only by [[core-upgrade]]. On the first run the seed is the live value.
- **Other loops' cadences** ([[level-set]]'s 15-tickets/2wk, [[roadmap]]'s 30d,
  [[staffing-review]]'s bounds): step 3 reviews whether each is firing at the right rate.
  Moving a loop's **live** interval (the ledger value) is ordinary loop output, no gate;
  moving a loop's **seed/bounds** (the manifest policy) is a [[core-upgrade]] this loop
  *proposes*, Owner-disposes. **Exception — [[staffing-review]]'s live value is
  staffing-review's alone:** evolve touches staffing-review only at its **policy/bounds**
  (a [[core-upgrade]]), never its ledger interval. staffing-review self-tunes its own live
  value between evolve rounds; this loop is the portfolio-level backstop, not a second hand
  on the same dial.

## Inputs (typed)
- `since` (ledger entry ref) — the previous evolve round's ledger entry, or none on first run.
- `loop_portfolio` — `registry/loops.json` + each loop manifest's `mode`/`cadence` (the
  scheduled-loop set under review).
- `pressure_signals` — the [[ledger]], recurring ad-hoc summons ([[staffing-review]] output),
  recurring manual procedures, and the [[roadmap]]'s near-term direction.

## Steps
1. **Convene** ([[ceo]] + [[chief-of-staff]] lead — direction + org structure — with C-suite
   subgroups as the agenda warrants). Apply [[resource-budget]] spawn discipline.
2. **Scan for scaling pressure, read-only.** Where is the org repeatedly *improvising*?
   - **Recurring ad-hoc roles** → a new **employee template** (the Owner named **DevOps** and
     **Security** as likely-soon; seed a template when evidence warrants, per [[staffing]]).
     **Tie-break with [[staffing-review]] (template creation):** a template for a
     *not-yet-recurring, anticipated* role is **evolve's** to seed; a template for a role
     *already summoned ad hoc N times* is **[[staffing-review]]'s gap to fill**. When both
     could claim it, **staffing-review (reactive, evidence-based) wins and evolve stands down.**
   - **Recurring manual procedures** → a new **procedure or loop**.
   - **A capability the [[roadmap]] implies we'll need soon** → propose the machinery ahead
     of the crunch, not after.
3. **Re-evaluate the scheduled-loop portfolio (the meta-cadence review).** For each
   scheduled loop ([[staffing-review]], [[roadmap]], and **evolve** itself — all
   time-scheduled with a manifest seed/bounds + a ledger live value; **plus [[level-set]],
   which is *hybrid*** — event-driven on ticket count *and* time, with its cadence homed in
   prose, not a policy/state split): is it firing at the **right cadence**? **Still needed**?
   Is any loop **missing** that the org keeps needing? Record a cadence verdict per loop
   (hold / retune-live / propose-policy-change). **`retune-live` applies only to the loops
   that carry a ledger live value; [[level-set]] has no live-retune path — its cadence moves
   only by [[core-upgrade]].**
4. **CRO reality-check** ([[chief-reality-officer]]). Anti-bloat is the point: is a proposed
   template/loop/procedure actually needed *by evidence* (a role summoned N times, a
   procedure improvised N times), or speculative? "Keep the shelf small and sharp"
   ([[adr-020]]) — a new piece of machinery the org won't use is drift, not evolution.
   Verified need proceeds; speculative machinery is declined or parked.
5. **Propose (all gated).** Turn accepted findings into proposals:
   - New **templates** / new/retired **loops** / new **standards or procedures** are **core**
     → route through [[core-upgrade]] (Owner-approved), or open `work/` tickets that do.
   - **Cadence policy changes** (a loop's seed/bounds) → [[core-upgrade]]; **cadence live
     retunes** (a loop's ledger interval) → ordinary ledger output.
   - A finding that is itself a **load-bearing call** (reshaping the taxonomy, a new function
     tier) routes through [[decision]]. This loop **proposes and tickets**; it never executes
     a structural change itself, and every authoring path stays gated ([[adr-017]] §E).
6. **Record.** Append a [[ledger]] entry: scaling pressures found, machinery proposed
   (templates / loops / procedures), the per-loop cadence verdicts, the CRO verdict, the
   resulting ticket/ADR ids, and this loop's own `next_cadence_days`. This entry becomes
   `since` for the next round.

## Outputs (typed)
- A [[ledger]] entry carrying the scaling-pressure findings, the proposed machinery, and the
  portfolio cadence verdicts.
- Zero or more new **employee templates**, new/retired **loops**, or new **procedures/standards**
  (each via [[core-upgrade]] or the gated ticket path).
- Zero or more **cadence retunes** (live ledger value) or **cadence policy proposals**
  (manifest seed/bounds, via core-upgrade).
- Zero or more [[decision]] invocations where a finding is itself load-bearing.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 6 once the ledger entry is
recorded, in exactly one of — **evolution-proposed** (one or more machinery/cadence proposals
opened) or **clean** (portfolio healthy, no new machinery this round). Either way the entry
carries the portfolio cadence verdicts and `since` advances. Executing any proposal is
[[core-upgrade]]'s / [[dev-cycle]]'s job, not this loop's.

## Notes
- **`metadata.mode` = partially-autonomous:** scan / portfolio-review / synthesize run
  unattended; the gates are the [[core-upgrade]] Owner approval (for new/retired machinery and
  cadence-policy changes) and the ordinary [[ticket-cycle]]/PR approvals on anything ticketed.
- **Seeded this round ([[adr-021]]):** the [[devops-engineer]] and [[security-engineer]]
  templates — the Owner-named near-term roles — as the loop's first concrete output. Both are
  gated changes landing in this Owner-approved PR; summoning the first *employees* from them
  waits for real work.
