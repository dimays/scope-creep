---
name: decision-rights
description: Who is in the room for each kind of decision — the decision-type → required-hats map that makes "the right people in the room" mechanical instead of ad hoc. Proposed.
metadata:
  type: reference
  status: proposed
  version: 0.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Decision Rights (proposed)

**Proposed** by the Chief of Staff after the level-set ([[ledger-027-level-set-round]]).
Today, who gets consulted on a decision is the CoS's ad-hoc judgment (e.g. convening the
C-suite dry run). This standard makes it a rule: every load-bearing decision has a known
set of hats, is empirically checked, ratified, and recorded.

## The roster
Six core executives ([[chief-of-staff]], [[cto]], [[chief-product-officer]],
[[chief-designer]], [[chief-knowledge-manager]], [[chief-reality-officer]]). Each may
spin up employee/app-bound agents; the CoS ratifies (INVARIANTS §I).

## The two invariants of every load-bearing decision
1. **The CRO verifies.** No load-bearing decision is ratified on assertion alone — the
   [[chief-reality-officer]] checks it against reality first (the level-set proved the
   value: it caught the lying `/healthz` and the unratified RR8 bump).
2. **The CoS ratifies and it is recorded.** Architectural → an ADR; operational → a
   [[ledger]] entry. Owner-gated classes need the Owner's explicit approval on top.

## Decision-type → required hats
| Decision | Lead (Responsible) | Consulted | Verify | Ratify | Owner-gated? |
|---|---|---|---|---|---|
| Blessed-stack / framework upgrade | [[cto]] | Chief Designer | CRO | CoS | **Yes** ([[core-upgrade]], INVARIANTS §I.4) |
| Product scope / roadmap | [[chief-product-officer]] | CoS | CRO | CoS | New scope: **yes** (§I.4) |
| Design system / shared tokens | [[chief-designer]] | CTO (consumers) | CRO | CoS | Palette/API change: **yes** |
| Docs / knowledge standards | [[chief-knowledge-manager]] | — | CRO | CoS | No |
| New app | [[cto]] + CoS | CPO, Chief Designer | CRO | CoS | **Yes** ([[new-app]]) |
| Anything touching INVARIANTS, `.claude/`, or a core record set | CoS | relevant lead | CRO | CoS | **Yes** (always) |
| Resource / budget (token, API, compute) | CoS | CTO | CRO | CoS | Spend increase: **yes** |
| Routine ticket work | the ticket's `owner` agent | — | gate (green `test`) | PR merge | No — the [[ticket-cycle]] |

## When to convene the full C-suite (a dry run)
- The Owner invites it, **or**
- a decision spans **≥3 domains** or reverses a prior ratified decision.
Otherwise the lead + CRO + CoS suffice — convening everyone for a routine call is waste.

## What this is not
Not a bureaucracy layer on routine work: the [[ticket-cycle]] and [[request-intake]]
loops already carry their own gates. This governs **load-bearing** decisions — the ones
that, wrong, are expensive to unwind. See [[work-034]] for the loop that operationalizes
this.
