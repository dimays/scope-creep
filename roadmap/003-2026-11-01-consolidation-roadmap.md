---
name: roadmap-003
description: The third roadmap round — a consolidation presentation. No new themes; the CEO asks the Owner to disposition the stuck PR #140 (an unmerged, self-styled "roadmap-002" that bundles a safety-kernel rewrite with ordinary roadmap content) and roadmap-001's four undisposed themes before the org takes on more scope. No release occurred this round, so no release notes accompany it.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: ceo
  last_verified: 2026-11-01
---

# Roadmap Presentation 003 — 2026-11-01

- **Date:** 2026-11-01
- **Horizon:** the next 4–6 weeks — deliberately short, recovery-first.
- **Presented by:** [[ceo]] to the board (the Owner), per [[roadmap]] step 5.
- **Supersedes:** [[roadmap-001]] (the founding round, 2026-09-07) as the latest board
  presentation. **It does not supersede a "roadmap-002"** — none has landed. A second round
  was drafted 2026-09-24 and still sits unmerged as **PR #140**; see below.

> **This round in one line:** the org has been busy, not productive — eight weeks, 127
> tickets, **zero shipped releases**, and the two highest-leverage calls on the table
> (PR #140, and round 1's four undisposed themes) are **the Owner's to make, not the org's
> to work around**. This round proposes no new scope and no charter changes.

## CEO statement — State of the Org

Chairman,

I need to open with the number that matters more than any theme below: **it has been eight
weeks since round 1, and nothing has shipped.** Not a release, not a version bump, not a
line of product code the Owner can point to. In that window the org produced 127 work
tickets (81 done), dozens of ledger entries, and 17 open pull requests — and the overwhelming
majority of that output is the org reviewing, reconciling, and re-flagging its *own* process.
That is not nothing, but it is not the product either, and I'd rather say so plainly than
bury it in a theme.

---

**The org is good at proposing and bad at closing.** `scope-creep-console` has six PRs
(work-081/105/107/108/109/110) sitting **27–32 days old with zero reviews, ever** — the
routine reviewer was never onboarded to that repo ([[work-121]], blocked on [[work-119]]).
On `scope-creep` itself, a "propose-only" queue of **17 open PRs** has piled up since
2026-09-24, most going stale (`mergeable_state: behind`) the moment the next day's
housekeeping PR lands — the close recommendation has been repeated for **ten straight
`work-sweep` cycles** and actioned zero times.

---

**Round 1 was never actually decided.** Of [[roadmap-001]]'s five themes, only Theme 3 has
a disposition — and even that landed as *built and merged*, not *running*: its execution arm
(`work-sweep`) has completed **21 cadenced runs since 2026-10-01 and shipped nothing in any
of them**, for the structural reasons above. Themes 1, 2, 4, and 5 have had **no Owner
response in eight weeks** — they still stand exactly as presented.

---

**Our own `evolve` loop caught a mistake before I could repeat it to you.** A second roadmap
round was drafted 2026-09-24 (self-styled "roadmap-002") and opened as **[PR #140](https://github.com/dimays/scope-creep/pull/140)**
— but it bundled that round's ordinary planning content with a **full safety-kernel rewrite**
(INVARIANTS v2.0.0, a new PRINCIPLES doc, decision-rights v2, narrowed CODEOWNERS, edits to
11 of our 13 loop files) in one escalation-class PR that only the Owner can apply by hand.
`evolve`'s first scheduled round flagged exactly this as the risk ([[work-133]]): a change of
that weight inside a roadmap artifact is unreviewable incrementally, and it has sat untouched
for **38 days** as a result. I am not re-proposing that content here, and this round makes
**zero** changes to INVARIANTS, decision-rights, or any loop file.

---

**So this round is not a sixth theme. It is permission to stop adding and start clearing.**
Before this org takes on anything new, I'm asking you to make two calls only you can make —
disposition PR #140, and disposition round 1's open themes — and I'm asking the Chief of
Staff to get our own backlog of unreviewed, unmergeable PRs down to zero. Everything else
below is a status carry-forward, not a new ask.

— the CEO

## Since last round (since [[roadmap-001]], 2026-09-07)

The three input streams [[roadmap]] step 2 reviews, each labeled by the CRO lens
**verified** (checked directly against a primary source this round), **inferred** (derived
from indirect but consistent evidence), or **assumed** (asserted, not independently checked)
— per [[adr-007]]:

| Stream | Finding | Label |
|---|---|---|
| **User experiences tracked** | No new Owner-authored feedback found in GitHub (PR #140 has zero comments) or the ledger since 2026-09-24. The only "signal" of the period is the org's own repeated, unactioned recommendations to itself. | **verified** (absence checked directly) |
| **Releases / version-bumps landed** | None. No git tag since the v0.2.0 baseline (2026-09-07); no `CHANGELOG.md` in the repo; the last 30 commits on `main` are all `ledger:`/`board-hygiene:`/`work-sweep:` bookkeeping, no feature work. | **verified** |
| **How the existing roadmap held up** | Theme 3 accepted-as-extended but its execution arm has run 21 times and shipped nothing (direct read of [[ledger-125-work-sweep-twenty-first-cadenced-run]]); Themes 1/2/4/5 disposition table unchanged since [[ledger-059-capstone-merge-and-reconciliation]]. | **verified** |
| **The org's structural self-diagnosis** | [[evolve]]'s first round ([[ledger-083-evolve-first-run]]) independently found: [[level-set]] has never fired despite its trigger being true 5×+ over ([[work-132]]), and [[roadmap]] itself lacks a handoff rule for structural asks, which is exactly what produced PR #140 ([[work-133]]). | **verified** (read the tickets and the triggering ledger entry directly) |
| **Whether PR #140's content is still wanted** | Unknown — the PR has had no Owner engagement since it opened. This round **assumes nothing** about its merits; it only surfaces that a decision is overdue. | **assumed absence of a decision, not assumed on the merits** |

## Themes

No new themes this round. The overview below carries round 1 forward unchanged and adds one
operational theme — closing the backlog that is blocking everything else.

| # | Theme | Owner | The ask |
|---|-------|-------|---------|
| 0 | **Clear the backlog before adding to it** | [[chief-of-staff]] · [[git-manager]] · [[cto]] | **New.** Get the stuck PR/review queues to zero and wire [[level-set]]; see below. |
| 1 | Finish the trust rails | [[cto]] · [[chief-reality-officer]] | Carried forward, unchanged, undisposed. |
| 2 | A Console that shows the org to itself | [[chief-designer]] · [[chief-product-officer]] | Carried forward, unchanged, undisposed. |
| 3 | The self-improving loop system, visible and honest | [[chief-of-staff]] | **Status update only** — accepted-as-extended, built, but execution stalled (see Theme 0). |
| 4 | Delight as a standard, not a finishing coat | [[chief-designer]] | Carried forward, unchanged, undisposed. |
| 5 | Threads as the org's window into Claude | [[chief-product-officer]] · [[chief-knowledge-manager]] | Carried forward, unchanged, undisposed. |

### Theme 0: Clear the backlog before adding to it (new)
Three concrete, scoped gaps — not a redesign — each already surfaced by the org itself but
never closed:

- **The `scope-creep-console` review gap.** Six PRs, 27–32 days old, never reviewed, because
  the routine reviewer was never onboarded to that repo. [[work-119]] → [[work-121]] close
  this; both are already `proposed`, nothing new needed except priority.
- **The `scope-creep` propose-only duplicate queue.** 17 open PRs, most superseded the day
  after they open, recommended for closure for ten consecutive cycles with no action. **New
  ticket [[work-134]]** scopes the cleanup and a fix to the pattern that keeps re-creating it.
- **`level-set` has never fired.** True for most of the org's life per [[work-132]], already
  `proposed` — carried here as a Theme-0 priority, not a new ticket.

A fourth, smaller item: the `work-sweep` cloud routine's stored prompt has been stale for
**21 consecutive runs**, correctly self-diagnosed every time but never fixed. **New ticket
[[work-135]]** — a five-minute refresh, repeatedly recommended, never actioned.

**The ask:** authorize [[chief-of-staff]]/[[git-manager]] to drive work-119, work-121,
work-132, [[work-134]], and [[work-135]] to done before any Theme 1/2/4/5 work is staffed.

**Traces to:** [[work-119]], [[work-121]], [[work-132]], [[work-134]], [[work-135]],
[[ledger-125-work-sweep-twenty-first-cadenced-run]], [[ledger-126-board-hygiene-status-reconciliation]],
[[ledger-083-evolve-first-run]].

### Themes 1, 2, 4, 5 — carried forward unchanged
Presented in full in [[roadmap-001]] and not rewritten here (no retroactive edits to a round
already presented, per [[doc-standards]]'s supersede-not-destroy convention). They **stand as
presented**, now eight weeks without an Owner response. This round does not re-argue them; it
only restates that they are still waiting.

### Theme 3 — status update
**Accepted as extended** via PR #78 (2026-09-20) — see [[roadmap-001]]'s disposition table for
the original evidence. New this round: the extension's execution arm (`work-sweep`) has
completed 21 cadenced runs since 2026-10-01 and shipped zero tickets in any of them, for the
two structural reasons named in Theme 0. **No new ask here** — unblocking Theme 0 *is* the ask
for Theme 3.

## What this round deliberately does not propose

- **No changes to INVARIANTS, decision-rights, CODEOWNERS, or any `loops/*.md` file.** That
  content already exists, staged, in PR #140 — re-proposing it here would recreate the exact
  bundling problem [[work-133]] names. If the Owner wants that content, it is disposed via
  PR #140 directly, or re-proposed later as its own PR once [[work-133]]'s handoff rule lands.
- **No new PRDs.** Adding a sixth theme's worth of new product surface on top of an
  eight-week-undisposed backlog is the literal failure mode this org is named for. The next
  new PRD is a round-4 decision, after Theme 0 closes and the Owner has disposed PR #140 and
  rounds 1's remainder.

## Decisions needed from the Owner

1. **Disposition PR #140** — apply it as-is (`docs/owner-apply-autonomy-charter.md`'s three
   steps), reject it, or send it back to be split per [[work-133]]'s proposed handoff rule
   (structural/charter content as its own core-upgrade PR, separate from ordinary roadmap
   content going forward).
2. **Disposition [[roadmap-001]] Themes 1, 2, 4, 5** — accepted / revised / deferred, eight
   weeks overdue.
3. **Authorize the Theme 0 backlog push** — [[chief-of-staff]]/[[git-manager]] drive
   work-119/121/132/134/135 to done before new theme work is staffed.
4. **[[work-133]] itself** (the roadmap-loop doc fix that would have prevented PR #140's
   bundling) — a small, already-drafted `loops/roadmap.md` core-upgrade, independent of
   PR #140's content, ready for a quick Owner yes.

## Release notes

**None this round.** No release or version bump has occurred since v0.2.0 (2026-09-07) — see
"Since last round" above. The next release notes entry fires when `work-sweep` or a dev-cycle
round actually lands a shippable change, which Theme 0 is the precondition for.

## Disposition

_Recorded on the Owner's response ([[roadmap]] step 7 — **accepted** / **revised** /
**deferred**)._

| Theme | Disposition | Evidence |
|---|---|---|
| 0 — Clear the backlog | Pending the Owner | Presented this round. |
| 1, 2, 4, 5 (carried from round 1) | Pending the Owner | Unchanged since [[roadmap-001]]; no disposition recorded in eight weeks. |
| 3 — status update | Pending the Owner | Accepted-as-extended stands; execution-stall note is new information, not a new ask. |
| PR #140 ("roadmap-002" + ADR-028) | Pending the Owner | Unmerged, 38 days, zero comments. Not disposed by this round. |
