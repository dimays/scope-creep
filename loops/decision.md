---
name: decision
description: The load-bearing-decision loop — identify type → convene the required hats per decision-rights → CRO verifies → CoS ratifies → record → Owner-gate where required. Makes "the right people in the room" mechanical.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: decision

How a **load-bearing** decision gets made without ad-hoc judgment about who is in
the room. Operationalizes [[decision-rights]] (the decision-type → required-hats map).
Always terminal. This governs the expensive-to-unwind calls; routine work stays on the
[[ticket-cycle]] and [[request-intake]] loops, which carry their own gates.

## When this loop fires (and when it does not)
Fires for a **load-bearing decision** — one that, wrong, is expensive to unwind:
architectural choices (ADR-worthy), product scope / roadmap changes, design-system /
shared-token changes, a new app, blessed-stack upgrades, resource/budget increases, and
anything touching INVARIANTS, `.claude/`, or a core record set. It does **not** fire for
routine ticket work or a single Owner request — those already have gates ([[ticket-cycle]]
step 5, [[request-intake]] step 3). Rule of thumb matches the ticket-cycle STOP checklist:
**irreversible, outward-facing, core-touching, or a genuine judgment fork → this loop.**

## Inputs
- A decision to be made: a framing (the question), the options, and the forcing context.

## Steps
1. **Identify the type.** Match the decision to a row of [[decision-rights]]'s
   decision-type → required-hats table. If it spans **≥3 domains** or **reverses a prior
   ratified decision**, escalate to a full C-suite dry run (per that standard's "when to
   convene the full C-suite"). If no row fits, default to the INVARIANTS/core row (CoS
   leads, relevant lead consulted) — the safe over-approximation.
2. **Convene the required hats.** Bring in exactly the Lead + Consulted named for that
   row — the fewest heads that can make the call, not the whole roster. The Lead frames a
   recommendation; the Consulted pressure-test it. Two decisive heads beat five hedging ones.
3. **CRO verifies** (invariant #1 of [[decision-rights]]). No load-bearing decision is
   ratified on assertion alone — the [[chief-reality-officer]] checks it against reality
   first: label the load-bearing claims **verified / inferred / assumed**, and verify the
   assumption most likely to break the plan. Prefer a runnable check over an assertion
   ([[adr-007]]). A failed check sends the decision back to step 2.
4. **CoS ratifies** (invariant #2). The [[chief-of-staff]] makes the call and owns it.
   On executive disagreement, the CoS reconciles decisively rather than surveying.
5. **Record.** Architectural → an **ADR** (`standards/adr/NNN-slug.md`, per
   [[doc-standards]] §6). Operational → a **[[ledger]]** entry. The record names the type,
   the hats convened, the CRO verdict, the decision, and its reversal path.
6. **Owner-gate where required.** If the [[decision-rights]] row is Owner-gated
   (blessed-stack upgrade, new scope, new app, palette/API change, spend increase, anything
   touching INVARIANTS / `.claude/` / a core record set), the decision is a **proposal**
   until the Owner approves at the moment of action ([[invariants]] §III.7). Agents propose;
   the Owner disposes. Never route around the gate. A **red** gate is waivable only by the
   Owner.

## Outputs
- A ratified (or Owner-gated proposed) decision, recorded as an ADR or a [[ledger]] entry,
  carrying the type, the hats, the CRO verdict, and the reversal path.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at step 6 with exactly one of —
**recorded-and-ratified** (non-gated), **recorded-and-proposed** (Owner-gate pending), or
**sent-back** (CRO check failed → re-enter at step 2, bounded by the deciders' judgment; a
decision that cannot pass a reality check is declined, not looped forever).

## Delegation note ([[adr-014]])
When the decision is **landing a PR**, the gate is a **green CI gate + Owner approval**, not
the Owner's keystroke — the [[git-manager]] executes once approved and records it. That is the
one row where "ratify" is the Owner's approval and execution is delegated. Every other
Owner-gated row still needs the Owner at the moment of action.
