---
name: level-set
description: The recurring paydown-and-reflection loop — the C-suite (or a scoped subset) each assesses its domain read-only, the CoS synthesizes a ranked plan spanning tech debt AND organizational lessons, and the Owner picks the track. Cadence-triggered; feeds the ticket-cycle.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: level-set

Institutionalizes the ad hoc dry run that found the lying `/healthz`, the unratified
RR8 bump, and doc drift ([[ledger-027-level-set-round]]), so the factory self-corrects
on a cadence instead of only when the Owner happens to notice something ([[work-033]]).
Complements [[decision]] rather than duplicating it: [[decision]] resolves one
load-bearing call framed in advance; this loop is the recurring, multi-domain health
check that *produces* the ranked backlog those calls (and ordinary tickets) come from.
The `mode` field anticipates [[work-038]]'s registry lint (not yet wired — see
"Notes" below).

## When this loop fires
- **Cadence trigger:** every **15 tickets landed** (`work/*.md` flipping to `status:
  done`) since the last level-set, **or 2 calendar weeks** since the last level-set
  [[ledger]] entry — whichever comes first. The CoS counts `done` tickets against the
  previous round's ledger entry; mechanical, not a judgment call.
- **Ad hoc:** the Owner may invite a round early, as in [[ledger-027-level-set-round]].
  The cadence is a floor, not a ceiling.
- **Not mid-effort.** This loop does not interrupt an authorized push (e.g. an
  overnight crank in flight) — the CoS schedules the next round into the following
  lull so hats assess a settled state, not a moving target.

## Inputs
- `since` (ledger entry ref) — the previous level-set's ledger entry, or none on the
  first run.
- `tickets_done_count` (int) — tickets landed since `since`; the cadence counter.
- `domain_hats` (list, default: full C-suite minus [[git-manager]]/[[qa-tester]], who
  execute and verify rather than hold a domain) — which executives assess this round.
  The Owner or CoS may scope to a subset for a lighter pass (e.g. CTO + CKM only, for
  a debt-focused check with no reflection mining).

## Steps
1. **Convene.** CoS names the round's hats (default: full C-suite). Apply
   [[resource-budget]] spawn discipline before fanning out — see "Spawn discipline"
   below; a full-roster level-set is precisely the fan-out shape that has broken
   sessions before.
2. **Assess, read-only, per hat.** Each convened executive reviews its own domain
   against ground truth (code, config, running gates) — never against its own prior
   claims. Two input streams, not one:
   - **Debt** (the original scope) — stale docs, unenforced standards, drifted
     records, deferred/blocked tickets, coverage gaps.
   - **Reflection** (Owner-directed 2026-09-06 — extends this loop rather than adding
     a new one): mine the [[ledger]] — and, once populated, `activity/*.ndjson`
     ([[work-036]]) — for **mistakes, reversals, and gate-catches**: a decision later
     walked back, a gate that should have fired and didn't, a claim that turned out
     false, an Owner-gated change that shipped without its gate recorded. The target
     is the org *learning* from its own history, not only clearing a backlog.
3. **CRO spot-check.** For convergent findings (multiple hats agree) or anything that
   would reprioritize the backlog, the [[chief-reality-officer]] verifies against
   reality before it reaches the Owner — the same discipline [[decision]] applies at
   its step 3, scoped here to the findings that are actually load-bearing.
4. **CoS synthesizes** one **ranked paydown-and-lessons plan**: convergent findings
   first, then hat-specific ones, each scored on leverage × cheapness (as
   [[ledger-027-level-set-round]] did). A reflection finding that reveals a **process
   gap** — not a one-off mistake — is routed through [[decision]] as its own
   load-bearing call, not silently folded into a paydown line item.
5. **Owner picks the track.** The plan is a proposal; the loop parks here until the
   Owner selects a track (e.g. "stabilize first," [[ledger-027-level-set-round]]) or
   explicitly defers it. Owner-gated: this is the moment-of-action approval that
   green-lights reprioritizing the backlog around the round's findings.
6. **Tie-in to [[ticket-cycle]].** Every accepted item — debt or lesson — becomes a
   `work/` ticket (new, or reprioritized within its workstream), with this round's
   ledger entry cited as context. Tickets then run the ordinary [[ticket-cycle]] gate;
   this loop never executes a fix itself, only proposes and tickets it.
7. **Record.** Append a [[ledger]] entry: hats convened, verdict, convergent findings,
   the ranked plan, the Owner's track choice, and the resulting ticket ids. This entry
   becomes `since` for the next cadence count.

## Spawn discipline (bakes in [[resource-budget]] §2)
A full-C-suite level-set is the exact fan-out pattern that has already broken
sessions — three hats hit the session rate limit mid-round in
[[ledger-027-level-set-round]]'s dry run, it recurred later the same night (the
incident [[resource-budget]] was written to prevent), and it recurred **again**
during tonight's overnight crank ([[ledger-036-overnight-crank]]) — the same failure
mode, three times in one operating window. This loop must not repeat it:
- **Stagger hat spawns** rather than launching the whole roster in the same instant.
- **Mix models across the batch** — not every hat needs the flagship tier; route
  read-only survey work to a cheaper tier per [[resource-budget]] §1 and reserve Opus
  for the hat(s) doing the hardest synthesis.
- **Cap concurrent Opus-tier spawns** per [[resource-budget]] §2 — five at once is the
  known-bad pattern. (This ticket's own implementation pass deliberately ran with
  zero subagent fan-out, for the same reason it's writing down here.)
- **On a limit hit mid-round, checkpoint** ([[resource-budget]] §3) — resume the
  remaining hats' assessments against what already landed; don't restart the round.

## Outputs
- A [[ledger]] entry carrying the ranked paydown-and-lessons plan, the Owner's chosen
  track, and the resulting ticket ids.
- Zero or more new/reprioritized `work/` tickets, handed to [[ticket-cycle]].
- Zero or more [[decision]] loop invocations, where a reflection finding surfaces a
  process gap rather than a one-off fix.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 7 once the ledger
entry is recorded, in exactly one of two states — **track chosen** (Owner picked; step
6's tickets proceed) or **deferred** (Owner explicitly parks the plan; no tickets open
this round, but `since` still advances so the next cadence count starts clean). The
loop's job stops at the recorded plan; executing it is [[ticket-cycle]]'s job.

## Notes
- **`metadata.mode`** values follow [[glossary]]'s Loop definition (`autonomous |
  partially-autonomous | manual` — one property, how many steps are human-gated).
  This loop is `partially-autonomous`: convene/assess/synthesize run unattended, step
  5 (track selection) is a hard Owner gate. The field is populated here ahead of
  [[work-038]], which wires it into `registry/loops.json` and a `docs-lint` rule —
  that wiring is its own Owner-gated change ([[adr-013]] decision 7c); adding the
  field to this manifest is not.
- This loop assesses; it does not decide load-bearing questions on its own authority.
  Where a finding is itself a load-bearing decision (a standards change, a reversal of
  a prior ratified call), step 4 hands it to [[decision]] rather than resolving it
  here.
