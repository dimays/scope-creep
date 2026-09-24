---
name: decision-rights
description: Who decides what, and the minimal set of things that reach the Owner. Under the ADR-028 autonomy charter, the org decides everything the INVARIANTS don't reserve (guided by the PRINCIPLES). The Owner holds only spend and the §7 actions, credentials and permissions, the safety kernel, red-gate waivers, and irreversible deadlocks. Everything else lands on independent org review and appears in a weekly digest with a revert path. Part of the safety kernel (Owner-held).
metadata:
  type: reference
  status: active
  version: 2.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-24
---

# Decision Rights

> **Default: the org decides** ([[invariants]] §4a). A decision reaches the Owner **only**
> if it appears in the "Owner holds" table below. Escalating anything else is a failure
> mode, not caution. Decide, record, put it in the digest, and make it cheap to override.

## The Owner holds (the complete list)

| # | Class | When it reaches the Owner | Source |
|---|---|---|---|
| 1 | **Spend** | Anything that would purchase, provision paid infra, add a paid dependency or tier, or **enable metered compute** (API key, paid host) | INVARIANTS §7, §10(a) |
| 2 | **The §7 actions** | Production deploy, delete, publish, **at the moment of action**, however the code landed. Local builds and previews on the Owner's machine are **not** deploys. | §7 |
| 3 | **Credentials and permissions** | Creating, rotating, placing, or revoking a secret; granting permissions to any identity; security settings | §10(b) |
| 4 | **The safety kernel** | Any change to INVARIANTS, [[principles]], the gate surface (`.claude/`, workflows, CODEOWNERS, gate scripts, branch protection), this file, the top-level executive and function charters, or dependency/infra manifests. Manifests are **batched weekly**. | §4, §10(d) |
| 5 | **Red-gate waivers** | Only the Owner waives red | §10 |
| 6 | **Irreversible deadlocks** | A C-suite disagreement about something that can't be cheaply reverted, still unresolved after CoS ratification and CRO verification | §10(c) |

**Owner evidence** ([[invariants]] §4b) is only something an agent can't do: the Owner's
own review or action. **Agents never apply `owner-approved`.** See [[adr-028]] for the
Phase A → B transition.

## The org decides (with who)

| Decision | Lead | Verify | Ratify | Surfaced to the Owner as |
|---|---|---|---|---|
| **Direction, priorities, roadmap** | [[ceo]] | CRO | CoS | Roadmap doc + weekly digest |
| **What to build for a kernel** (interpretation, scope, sequencing) | owning exec (CPO by default) | CRO for load-bearing | CoS | The kernel's "heard" line + result |
| **Product / UX / design system** (incl. tokens, palette, APIs) | [[chief-product-officer]] / [[chief-designer]] | CRO | CoS | Digest |
| **Architecture, stack, substrate, new apps** (at $0) | [[cto]] | CRO | CoS | ADR (only if it binds future agents) + digest |
| **Loops, standards, ADRs, registries, docs** | owning exec | CRO for load-bearing | CoS | Digest |
| **Staffing** (summon/retire from templates) | any exec | — | **pre-ratified** (standing rule, §3) | Run record |
| **New or changed template** | owning exec | CRO | CoS (individually) | Digest |
| **Landing a routine PR** (outside the safety kernel) | [[git-manager]] / routine-reviewer ([[adr-027]]) | green CI + [[code-reviewer]] + [[qa-tester]] evidence | independent review (author ≠ merger) | Digest |
| **Landing a held PR** (Owner-holds classes 1–4) | [[git-manager]] | review + CRO | **the Owner** | Owner queue |

## The two invariants of every load-bearing decision

1. **The CRO verifies.** Nothing load-bearing is ratified on assertion. The
   [[chief-reality-officer]] checks it against reality first. **Load-bearing** means
   expensive to unwind, or other decisions will build on it.
2. **The CoS ratifies and it is recorded.** Architectural decisions become an ADR (only
   when it binds future agents). Operational ones become a run record or [[ledger]] entry.
   Records may be generated.

## The weekly digest (replaces per-PR asks)

Once a week the CoS sends the Owner one digest. It lists what shipped (one line per
kernel, with a revert link), decisions made (each with an override link), what's in
flight, trust metrics (revert, false-green, and canary-catch rates), and the items in the
Owner-holds queue. **Silence means keep going** ([[principles]] 5). The Owner can
override anything, at any time, and the org keeps overrides cheap.

## When to convene the full C-suite

- The Owner invites it, **or**
- a decision spans **≥3 domains** or reverses a prior ratified decision.

Otherwise the lead, the CRO and the CoS are enough. Convening everyone for a routine call
is waste.

---

*v2.0.0 (2026-09-24, [[adr-028]]). Supersedes v1.0.0, which was provisionally ratified,
self-contradictory (it marked ADR-022 PROPOSED beside active rows), and routed every
standards, agents, loops or registry change to the Owner.*
