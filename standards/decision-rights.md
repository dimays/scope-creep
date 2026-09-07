---
name: decision-rights
description: Who is in the room for each kind of decision — the decision-type → required-hats map that makes "the right people in the room" mechanical instead of ad hoc. Active; operationalized by the decision loop.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Decision Rights

**Active.** Proposed by the Chief of Staff after the level-set
([[ledger-027-level-set-round]]); ratified proposed → active on 2026-09-06 and wired into
the [[decision]] loop by [[work-034]]. Today, who gets consulted on a decision would
otherwise be the CoS's ad-hoc judgment (e.g. convening the C-suite dry run). This standard
makes it a rule: every load-bearing decision has a known set of hats, is empirically
checked, ratified, and recorded.

> **Provisionally ratified under delegated authority (2026-09-06) — Owner confirmation
> requested.** This proposed → active flip was **not** reviewed by the Owner directly. It
> was made the first live subject of the [[decision]] loop it defines
> ([[ledger-037-decision-loop-sample]]). At step 3 the [[chief-reality-officer]] **dissented**:
> [[invariants]] §I.4 lists `standards/` as core, changeable only via [[core-upgrade]] with
> explicit Owner approval, and this standard's own table Owner-gates a "core record set… always."
> The CRO recommended keeping this `proposed`. The Chief of Staff ratified it **provisionally**
> because [[ledger-036-overnight-crank]] explicitly names "decision-rights → active" as an
> action taken under tonight's delegated authority and rollback-able in the morning — reading
> that as the Owner's provisional approval, with reversibility (§III.10) as the guarantee.
> Because a live CRO dissent stands, this **needs the Owner's explicit sign-off** at the next
> review — confirm, or roll back (one line) per [[ledger-036-overnight-crank]] "Morning review".

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
| **Landing a routine PR (periphery / non-core)** | [[git-manager]] | [[code-reviewer]] + [[qa-tester]] (green) | green CI **+ code-review cycle + escalation checklist** ([[code-reviewer]]) | **independent org review** (author ≠ merger) | **No** — self-merges on review ([[adr-022]], PROPOSED) |
| **Landing an *escalated* PR** (financial / security / substantial tradeoff / safety-rail-or-core) | [[git-manager]] | [[code-reviewer]] + relevant lead + CRO | green CI + review + **escalation trigger raised** | Owner **approval** (implicit or explicit) | **Yes** — held for the Owner ([[adr-022]] / [[adr-014]]) |

**Delegated merge ([[adr-014]]):** a merge is gated on a **green CI gate + Owner approval**,
not the Owner's keystroke. Once the Owner approves (a conversational go-ahead or an explicit
yes), the [[git-manager]] may execute the merge and records it. This does **not** loosen the
`deploy` / spend / `delete` / publish gates ([[invariants]] §III.7) or let any agent waive a
**red** gate (only the Owner does). Load-bearing/core-upgrade merges still carry their own
Owner approval + CRO verification.

**Autonomous merge with escalation ([[adr-022]] — PROPOSED, awaiting Owner ratification of the
INVARIANTS §10 amendment; the two rows above are proposed and become active on ratification):**
a **routine** PR (periphery / non-core) merges on **independent org review** — green CI + the
[[code-reviewer]] cycle + [[qa-tester]] proof, **author ≠ merger** — with **no Owner
approval**. Before every autonomous merge the [[code-reviewer]] applies the **escalation
checklist**; if any trigger fires the PR is **held for the Owner**: **(a)** any financial
burden / cost / spend (INVARIANTS §7 — absolute, no one drives cost without explicit Owner
approval); **(b)** security risk (auth, secrets, attack surface, data exposure, permissions);
**(c)** substantial tradeoff / C-suite concern (above the review's altitude); **(d)** a change
to the safety rails or the core — INVARIANTS, `guard-gates`, `.claude/` gate/permission config,
a permission grant, the decision-rights / escalation model, or core `standards`/agents/loops/
registries (§I.4). A **core-touching PR always escalates** — it aligns with the "Anything
touching INVARIANTS, `.claude/`, or a core record set" row above (**Yes**, always). The
`deploy` / spend / `delete` / publish gates and the no-agent-waives-red rule are **unchanged**.

**Landing gate refined ([[adr-021]]):** in the [[dev-cycle]], green CI is *necessary but not
sufficient* to land — the diff must also clear the [[code-reviewer]] cycle (review → QA →
debug until it meets [[cto]]-set standards) and the CKM doc review first. Approval is still
the Owner's; the [[code-reviewer]] decides *ready*, [[qa-tester]] *proves*, and
[[git-manager]] *lands*. The **Product scope / roadmap** row is operationalized by the
[[roadmap]] loop (the [[ceo]] presents the plan to the Owner as the board); org **machinery**
changes proposed by [[evolve]] route through [[core-upgrade]] (Owner-gated).

## When to convene the full C-suite (a dry run)
- The Owner invites it, **or**
- a decision spans **≥3 domains** or reverses a prior ratified decision.
Otherwise the lead + CRO + CoS suffice — convening everyone for a routine call is waste.

## What this is not
Not a bureaucracy layer on routine work: the [[ticket-cycle]] and [[request-intake]]
loops already carry their own gates. This governs **load-bearing** decisions — the ones
that, wrong, are expensive to unwind. The [[decision]] loop operationalizes this map into a
runnable sequence ([[work-034]]).
