---
id: work-007
title: Define agent evals
type: feature
status: done
priority: low
owner: chief-product-officer
assignees: rae
spec: prd-console-explore
created: 2026-09-04
updated: 2026-09-07
---
> **DONE (2026-09-07).** Both halves complete: (1) per-role criteria as an **accepted** ADR
> ([[adr-015]], CRO-verified + CoS-ratified, [[ledger-052-evals-cro-verified]]); (2) a **first
> eval surfaced** on every agent profile — an "Eval — contribution history" section (console
> #51): attribution-grounded (authored vs mentioned), descriptive and **explicitly not a
> score**, each item deep-linked, with uncaptured signals named not faked. No score computed;
> Phase 2 (a quantitative score) remains a separate, future acceptance per [[adr-015]] §B.1.
Move agent profiles from transparent contribution history to real performance
scoring — which first requires defining what "good" means per role (CPO + CKM),
recorded as an ADR before any score is claimed.

**Acceptance:** an ADR defining per-role success criteria; a first eval surfaced on
the agent profile.

## Progress (2026-09-06, overnight crank — [[ledger-036-overnight-crank]])

**Delivered (control-plane):** [[adr-015]] — per-role success criteria for the six core
executives + the two standing functional agents ([[qa-tester]], [[git-manager]]), plus a
grounded eval-method sketch (contribution history first; every signal a real in-repo
artifact; an explicit "never fabricate" hard line). This satisfies the gating prerequisite —
"recorded as an ADR before any score is claimed." ADR is `proposed`, pending CRO verification
+ CoS ratification per [[decision-rights]]; **no score may be computed until it is accepted.**

**Still queued (follow-up, console lane):** the second half of acceptance — "a first eval
surfaced on the agent profile" — is a `scope-creep-console` ticket that renders the
transparent contribution history / first eval read-only from existing record-sets (ledger,
`activity/*.ndjson`, git host), per ADR-015 §B. Deliberately **out of scope** for this
control-plane ADR (console agent-profile surfacing is a separate follow-up in the busy
console lane). Status kept `proposed` because surfacing is not yet done.

## Update (2026-09-07, Owner-directed "verify evals")
The [[chief-reality-officer]] verified [[adr-015]]: **ACCEPT-WITH-FIXES**. It caught a real
coverage gap — the [[code-reviewer]] (a live standing function) had no eval criteria — plus CEO
scoping, an absence-signal/clickthrough tension, a citation slip, and a volume-gaming seam. **All
five fixes are applied** (adr-015 → v1.1.0); the ADR is **ready for CoS ratification**, held for
the Owner's go (a recorded readiness caveat ties the gating classification to the Owner's open
[[decision-rights]] question). See [[ledger-052-evals-cro-verified]]. The gating prerequisite is
met on ratify; **no score is computed until then.** The second half (surface a first eval on the
agent profile) stays the console-lane follow-up.
