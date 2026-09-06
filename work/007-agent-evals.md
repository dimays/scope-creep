---
id: work-007
title: Define agent evals
type: feature
status: proposed
priority: low
owner: chief-product-officer
assignees: rae
spec: prd-console-explore
created: 2026-09-04
updated: 2026-09-06
---
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
