---
name: ledger-036-overnight-crank
description: The Owner authorized an autonomous overnight push (2026-09-06 night) to take action on every Work Board ticket — build, land across repos, staff freely, create infra per the CTO, make direction calls — with deploy/spend/destroy still Owner-gated. Records the triage of all tickets and the collision-safe execution plan.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 036 — Overnight crank (2026-09-06 night)

**Recorded by:** the operating session, under Owner authorization.

## The mandate
The Owner authorized a full overnight push on the Work Board: *"Take action on every
ticket, whether that's deleting or moving toward completion… staff all tickets
appropriately, push through code changes as needed, merge into main across the repos,
create new repos or infrastructure as dictated by the CTO, and generally make judgment
calls about the direction of the night's work."* Broad approval — including **merges**
(satisfies [[adr-014]] Owner-approval for [[git-manager]] to land green work).

## Standing guardrails (unchanged — [[invariants]] §III)
Still Owner-gated at the moment of action, NOT authorized tonight: **deploy** (`fly deploy`),
**spend**, **delete data**, **publish/release**, force-push. Core `.claude/` changes still go
through [[core-upgrade]]; the [[work-036]] capture hook stays spike-gated (its live proof
needs a fresh session — see [[ledger-034-qa-tester]]).

## Execution architecture (collision-safe)
- Each implementation agent works in an **isolated worktree**, gets tests **green**, opens a
  **focused PR**, and does **not** self-merge. The [[git-manager]] lands green, mergeable PRs
  (Owner pre-approved tonight) and records each in the ledger; [[qa-tester]] proves where a
  claim is load-bearing.
- **Parallelize across repos; serialize within the hot `scope-creep-console` repo.** The
  broad-touch console ticket ([[work-011]]) lands first; others rebase onto it.
- Baseline confirmed green before starting (console `bun run test` — 2026-09-06).

## Triage — action on every ticket
**Bookkept done** (were mislabeled `active`; both merged): [[work-029]], [[work-040]] → done.
**Terminal:** [[work-001]] stays `superseded` (its scope became [[prd-chatbot-extension]] /
[[work-017]]); kept for history, not deleted.

**Build & land tonight** (staffed):
- Wave 1 (independent surfaces): **work-041** design primitives → Chief Designer
  (`scope-creep-design`); **work-018** model selection → CTO (console); **work-034** adopt
  decision-rights + decision loop → Chief of Staff (control plane).
- Wave 2: **work-011** app-state polish (Designer, console, lands first of the console batch);
  **work-030** needs-you queue (CPO/CTO); **work-022** consistency self-checks (CRO);
  **work-038** loops registry + owner_agent lint (CKM, after 034's new loop exists).
- Wave 3: **work-010** feedback lifecycle (CPO); **work-007** agent evals (CPO);
  **work-032** thread branching (CPO); **work-033** level-set loop (CoS);
  **work-035** resource-stewardship standard (CoS); **work-004** heal-on-CI-failure (CTO);
  **work-039** loops explorer (Designer, after 038).
- Dedicated stream: **work-017** flagship interactive preview + in-chat diff + agent edits
  (CTO) — large; scope + foundation tonight, land what's green.

**Deferred with reason** (dependency/gate, not neglect):
- **work-036** delegation capture — core-upgrade + spike-gated; advance the safe projection
  read-path only; the capture hook's live proof is a next-session Owner step.
- **work-037** delegation surface — blocked on 036 being proven (CPO: never render an
  invented/empty feed). Defer until 036 lands real data.
- **work-031** inline agent activity in threads — depends on activity data (036); defer.

## Morning review
Every landed PR is listed here by the git-manager as it merges. Anything ratified under
tonight's delegated authority (e.g. decision-rights → active) is the Owner's to roll back.
