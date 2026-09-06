---
id: work-034
title: Adopt decision-rights + a decision loop for load-bearing calls
type: feature
status: done
priority: medium
owner: chief-of-staff
spec: decision-rights
created: 2026-09-05
updated: 2026-09-06
---
From the Owner's ask — "make sure every decision has the right people in the room."
[[decision-rights]] (proposed) is the map; this ticket ratifies it and wires it into a
loop so it's mechanical, not the CoS's ad-hoc judgment.

- Ratify [[decision-rights]] (proposed → active) after Owner review.
- Add `loops/decision.md`: for a load-bearing decision — identify its type → convene the
  required hats per [[decision-rights]] → **CRO verifies** → CoS ratifies → record (ADR
  for architectural, [[ledger]] for operational) → Owner-gate where required.
- Keep it off routine work: the [[ticket-cycle]] and [[request-intake]] already gate that.

**Acceptance:** [[decision-rights]] is active; the decision loop is documented; a sample
load-bearing decision runs through it (right hats convened, CRO check, recorded).
See [[decision-rights]].

**Done (2026-09-06):** [[decision]] loop added; sample run recorded in
[[ledger-037-decision-loop-sample]] (CoS + CRO convened, CRO dissented on §I.4, CoS ratified
provisionally). [[decision-rights]] is `active` **provisionally** under the crank's delegated
authority ([[ledger-036-overnight-crank]]) — a live CRO dissent means the Owner must **confirm
or roll back** at the next review. Acceptance met provisionally; the `active` status is the one
item pending Owner sign-off.
