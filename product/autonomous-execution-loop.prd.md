---
name: prd-autonomous-execution-loop
description: The capstone — a scheduled routine (the time-scheduled sibling of dev-cycle) that pulls ready work-board tickets in priority order and drives them through dev-cycle/ticket-cycle autonomously and continuously, stopping only at an Owner blocker (an ADR-022 STOP/escalation gate) or a defined milestone. Closes the execution side of "run the roadmap autonomously" the way the Request Loop closed the intake side. Extends roadmap-001 Theme 3. Proposed; Owner-gated (ADR-021 loop creation).
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-08
---

# PRD — The Autonomous Execution Loop

> **Status: `proposed` — Owner-gated, and the capstone of the September cycle.** This
> is the **execution** half of the Owner's vision; the Request Loop ([[prd-request-loop]])
> already shipped the **intake** half. It **extends [[roadmap-001]] Theme 3** — it is not a
> separate track (see *Reconcile with Theme 3*). **One decision** is asked of the Owner:
> disposition [[roadmap-001]] accepting Theme 3 *as extended by this PRD*, which greenlights
> the loop. Creating the loop is an **Owner-gated core-upgrade** ([[adr-021]]); this is a
> proposal, never self-authorized.

## The user problem — the intake loop closes; the execution loop doesn't exist yet

The Owner stated the target verbatim (request thread #9, "Planned Work Routine"):

> "We need an autonomous loop to cycle through roadmap items **until they hit a blocker that
> requires my input or a milestone that demands my attention**. Outside of that, I want the
> system to run completely autonomously on roadmap items, and also triage and bring in
> requests, feedback, and bug reports as I submit them."

The second clause — *triage and bring in requests* — is **done and live**: [[request-triage]]
is a registered hourly cloud routine ([[prd-request-loop]]). The first clause — *cycle
through roadmap items autonomously until a blocker or milestone* — has **no runner**:

1. **The execution loops are event-driven, not scheduled.** [[dev-cycle]] (the cohort build
   loop) and [[ticket-cycle]] (its per-ticket engine) only run **inside a launched session**.
   [[adr-021]] §E is explicit: dev-cycle is event-driven, **"No — not cron."** So with nobody
   at the keyboard, **ready work sits still**.
2. **There is no scheduled poller of the work board.** Nothing wakes on a cadence, pulls the
   top `ready` ticket, and drives it to `done`. The Request Loop built exactly this for
   *request threads*; the *work board* has no equivalent.
3. **"Stop at a blocker or a milestone" is defined for blockers, undefined for milestones.**
   The blocker side is fully specified — the [[adr-022]] escalation checklist plus the
   [[ticket-cycle]] STOP checklist. **"A milestone that demands attention" has never been
   defined.** Without a crisp rule the loop either never pauses or pauses on everything.

The rails exist; the **scheduled runner and the milestone rule** are the gap. This PRD is
the execution-side mirror of [[prd-request-loop]]: *same trigger + write-back + notify
substrate, pointed at the work board instead of the request inbox.*

## The experience

What the Owner should feel — the execution analog of "submit and forget":

- **The roadmap builds itself.** The Owner greenlights a body of work and walks away; the
  org **cranks the ready backlog in priority order on its own**, ticket after ticket, landing
  routine periphery work on independent review ([[adr-022]]) — no keystroke per merge.
- **It stops exactly where the Owner said, and nowhere else.** It halts on a **blocker** (a
  STOP/escalation gate that is genuinely the Owner's call) or a **milestone** (a body of work
  the Owner cares about is complete) — and rolls straight through everything in between.
- **The stop reaches out.** A blocker or milestone surfaces to `needs-you` through the **same
  thread + notification path** the Request Loop already built ([[work-063]], [[work-064]]) —
  the Owner is pulled in only when the call is theirs, and finds the whole story in-thread.

## The loop

`wake (cadence) → read the work board → pick the top ready ticket at/above the priority
floor → drive it through [[dev-cycle]]/[[ticket-cycle]] (verify → review → land under
[[adr-022]]) → loop to the next ready ticket → stop only at a blocker or a milestone →
write the outcome back to the owning thread + notify → set needs-you`

The one net-new runner is the scheduled **[[work-sweep]]** loop. Everything downstream —
the build, the review, the merge gate, the write-back — is existing rails, connected.

## The stop rule — blocker vs. milestone (the crisp definition)

> **The loop runs continuously and stops on exactly two things. Both surface as `needs-you`
> via the thread/notification path; they are semantically distinct.**

**A blocker (held mid-flight — "I cannot proceed safely without you").** No new definition —
this is the **union of two existing checklists**, unchanged:

- the [[adr-022]] **escalation checklist** — (a) financial burden/spend, (b) security risk,
  (c) substantial tradeoff / C-suite concern, (d) a change to the safety rails or the core;
- the [[ticket-cycle]] **STOP checklist** — any INVARIANTS §III action at point of action
  (deploy/spend/delete/publish), a core-touch, new scope (a new PRD/ADR), a genuine judgment
  fork, an instruction-boundary trip, or ambiguous acceptance.

A blocked ticket flips `blocked`, writes the resume [[ledger]] entry, and yields — exactly as
[[ticket-cycle]] already prescribes. The sweep **continues to the next ready ticket** unless
the blocker is a global stop (a red gate the whole board waits on).

**A milestone (a clean completion checkpoint — "a body of work you care about is done; look
before I roll on").** This is the net-new rule. The sweep surfaces to `needs-you` and does
**not** auto-start the next body of work when **any** fires:

| # | Milestone trigger | Machine-checkable signal | Why it's the Owner's |
|---|---|---|---|
| 1 | **Theme / PRD boundary** | The last `ready` ticket tracing to a roadmap theme, or to a PRD's "Scope (this cycle)", reaches a terminal state | A themed body of work the Owner set direction on is complete → present it (the [[roadmap]]/[[ceo]] cadence), don't silently roll on |
| 2 | **Release boundary** | Landed-but-unreleased work crosses the release threshold the [[roadmap]] loop defines (a version bump / a themed batch) | A release is outward-facing ([[invariants]] §III) → the Owner dispositions it |
| 3 | **Priority-floor exhaustion** | No `ready` ticket remains **at or above the active priority floor** | The autonomous backlog is dry → hand back for the next direction. **This is also the loop's natural termination** ([[invariants]] §IV.12) |
| 4 | **Explicit `milestone:` marker** | A ticket carries `milestone: owner-review` in its frontmatter | Lets an author or the Owner **pin** a specific deliverable as sign-off-worthy even when it crosses no gate |

> **The distinction that keeps this honest:** a **blocker** is a gate the org is *forbidden*
> to cross alone; a **milestone** is a checkpoint the org is *choosing* to pause at so the
> Owner stays the one steering direction. Neither lets the loop cross a STOP gate — milestones
> add pause points, they never remove any.

## Self-pacing (cadence)

Mirrors [[request-triage]]'s cadence discipline ([[work-067]]), adapted for a heavier,
build-shaped loop:

- **Within a run:** continuous. Once awake, the sweep drives ticket after ticket to terminal
  (the [[dev-cycle]] already parallelizes a cohort under [[ticket-cycle]]'s WIP cap) until a
  blocker, a milestone, or the run budget stops it. It does **not** re-schedule per ticket.
- **Between runs:** the frequency **self-tunes on signal**, never a hard-coded guess — it
  emits a `cadence-decision` block to the [[ledger]] each run (`ran_at`, `trigger`,
  `next_cadence`, `reason`), the same protocol [[staffing-review]] / [[roadmap]] / [[evolve]]
  / [[request-triage]] use. Signals: **ready-backlog depth** (deep → wake sooner; dry → back
  off), **blocker/milestone hit-rate** (frequent Owner-pulls → slow down and batch), and the
  [[ticket-cycle]] **WIP cap**. **Policy** (seed + `cadence_bounds`) lives in the
  [[work-sweep]] manifest and moves only by [[core-upgrade]]; **state** (the live interval)
  lives in the ledger. Governance is [[work-087]].

## Reconcile with roadmap-001 Theme 3 — one decision, not two

> **Verdict: this EXTENDS [[roadmap-001]] Theme 3; it is not a new theme, and it is not
> already-planned work.** Recommend the Owner disposition [[roadmap-001]] accepting **Theme 3
> as extended by this PRD** — that single disposition greenlights the loop.

Theme 3 ("The self-improving loop system, made visible and honest", owned by the
[[chief-of-staff]]) is about the **operational maturity of the *existing* loops** — making
them viewable in the Console, the no-spend heal path ([[work-004]]), and [[evolve]]
re-tuning procedures. It **gestures at** this capstone ("operational maturity") but **never
tickets a scheduled execution routine** — and [[roadmap-001]] as written is the opposite: it
records dev-cycle as event-driven with **"no routine to schedule."** So the autonomous
execution routine is **genuine new scope** relative to the roadmap as it stands, and it lands
squarely inside Theme 3's mandate and its owning executive.

- **It is not Theme 1**, but it **completes** what Theme 1 opened: Theme 1 wants the *first
  fully-autonomous dev-cycle run* observed live (distinct author/reviewer/merger in the
  ledger). This loop is what makes such runs *routine and scheduled*, not one-off.
- **The clean framing for the Owner:** fold this PRD into Theme 3's scope. Accept Theme 3 as
  extended → the loop is greenlit; defer/decline → the loop stays proposed. **One decision.**

## Hard prerequisites (these block activation — name them, don't bury them)

> **The loop cannot be turned on until both clear. Both are Owner-side, not agent-buildable.**

| Prerequisite | State today | Why it blocks | Ticket |
|---|---|---|---|
| **(a) GitHub write access for the cloud routine** | The cloud routine has **read only** — a push fails `403 Resource not accessible by integration`, so it **cannot open PRs** | A scheduled execution loop whose whole job is *ticket → PR → merge* is inert if it can't push a branch or open a PR. This is the single hardest activation blocker | [[work-088]] |
| **(b) Loop creation is Owner-gated core-upgrade** | [[adr-021]] governs loop creation; a new scheduled loop is core machinery | The [[work-sweep]] manifest + this PRD are a **proposal**. The org may draft it; only the Owner dispositions it (via the Theme 3 greenlight above) and registers the claude.ai routine | *callout — the disposition itself* |

Prerequisite (b) is not a build task — it **is** the one decision above. Prerequisite (a) is
a concrete Owner-only provisioning action (a scoped credential, akin to [[work-060]] /
[[adr-023]]) and is ticketed as [[work-088]].

## Scope (tickets)

| Ticket | Intent | Owner | Gate class |
|---|---|---|---|
| [[work-086]] | The [[work-sweep]] runner — scheduled sweep of the work board, drive ready tickets through [[dev-cycle]]/[[ticket-cycle]], stop at blocker/milestone → `needs-you`. The one net-new piece | [[chief-of-staff]] | **Escalation** — new core loop ([[adr-021]]); holds for the Owner |
| [[work-087]] | Execution-cadence **and milestone governance** — the `cadence-decision` self-tune protocol + the machine-checkable milestone rule this PRD defines | [[chief-of-staff]] | Escalation — core loop policy ([[adr-021]]) |
| [[work-088]] | **GitHub write access** for the cloud routine (Owner-only provisioning) — the hard activation blocker | [[cto]] | **Owner-only** — credentials/infra ([[invariants]] §III) |
| [[work-089]] | Bug: a launched thread's view hides the Owner's original prompt — so a cloud-launched thread (which this loop and the Request Loop both produce) shows no ask | [[cto]] | Agent-buildable periphery (Console) |

## Non-goals (this cycle)

- **No new autonomy past the gates.** The loop adds *pause points* (milestones); it removes
  none. deploy/spend/delete/publish/core stay hard-stopped to the Owner regardless of cadence
  ([[invariants]] §III, [[adr-022]]).
- **No self-authorized loop creation.** [[adr-021]] holds — this is proposed, Owner-gated.
- **No multi-user, roles, or tenancy** — the singleton posture is absolute ([[invariants]]
  §II). "Autonomous" means unattended, never multi-principal.
- **No reworking the Request Loop substrate.** Trigger/write-back/notify/store
  ([[work-063]]–[[work-068]], [[adr-024]]) are correct and reused, not rebuilt.
- **No new scheduling daemon.** Scheduling stays on claude.ai Code Routines ([[adr-016]]),
  like every other scheduled loop.

## Success

The Owner greenlights a themed body of roadmap work, closes the tab, and the org lands it
ticket by ticket on independent review — pulling the Owner back **only** at a real blocker or
a defined milestone, with the outcome waiting in-thread. Combined with the live Request Loop,
the Owner's full vision holds: **requests flow in and get triaged; roadmap work flows out and
gets built — autonomously, and stopping only where the Owner said to stop.**

---

Follows [[doc-standards]] (esp. §4 registers and §9 presentation). Living,
supersede-not-destroy (§5): sections are stamped and evolve in git + the [[ledger]] as the
loop is dispositioned, built, and activated.
