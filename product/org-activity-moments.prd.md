---
name: prd-org-activity-moments
description: Make the Console's Org Activity surface tell three specific stories the Owner cares about — an agent running a process end-to-end, an agent kicking off other agents, and an agent spinning up an employee — by fixing the activity record so it can represent them. Extends transparent delegation; grounded in a verified diagnosis that today's data is both under-captured and structurally unable to distinguish the three.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-07
---

# PRD — Org Activity: the three moments

> **Status:** `proposed` — Owner-directed 2026-09-07, drafted by the CPO on a verified
> diagnosis. **Extends [[prd-transparent-delegation]]**; does not supersede it. **The root
> cause is the record shape, not the CSS** — Org Activity can't tell these stories apart
> because the activity event can't *represent* them. **Prerequisite: [[work-077]]** (the
> capture hook doesn't fire and its writes miss the Console) must land first, or there is no
> live data to enrich. **Every capture change here is Owner-applied** (touches `.claude/**`
> / the core capture surface); the read + render changes are agent-buildable periphery.

## The user problem
*(Owner-facing register — [[doc-standards]] §4.)*

The Owner wants to watch the org work and, at a glance, recognize **three moments that
matter** — but Org Activity today renders every row the same way and most of it is missing
entirely. The Owner's own read was that **the data structure itself is the problem**. The
diagnosis confirms it, on two axes:

1. **An agent runs a process end-to-end.** *Not captured at all* — there is no run concept,
   no start/finish, no run id. A whole unit of work leaves no trace.
2. **An agent kicks off other agents.** *Captured, but structurally blind.* The hook logs the
   **child** (`subagent_type`) with **no parent field** (`log-activity.py:37-48`), so the
   parent→child **edge** the Owner wants to see — *who* kicked off *whom* — isn't in the data.
3. **An agent spins up an employee agent** (creates an agent to task work). *Not captured.* A
   new `agents/employees/*.md` with a `reports_to` supervisor edge is a git/registry event
   (`scripts/registry-build.ts:64,123`) that no hook observes — so a staffing moment never
   reaches the log.

> **The load-bearing fact.** The read path already *anticipates* richer data —
> `activityVerb()` maps `spawn→"spun up"`, `delegate→"delegated"`, `staff→"staffed"`,
> `confer→"conferred"` (`explore.server.ts:348-361`) — but the writer only ever emits
> `type:"spawn"` with no edge, so **every row renders identically and most links are dead**
> (`refUrl` is never written; `threadId` rarely set). This is a **data-capture +
> data-structure** gap, not a surfacing gap. Fixing the render without fixing the record
> would just re-style undifferentiated rows.

## The experience
*(Owner-facing register.)* When the org works, the Owner opens **Explore → Activity** (or an
agent's page) and reads the three moments at a glance, each visibly distinct and truthfully
linked:

- **A run, end-to-end.** *"the triage routine ran — started 10:02, finished 10:07"* — a run
  reads as one framed unit with a start and a finish, not a scatter of unrelated rows.
- **One agent kicking off others.** *"the Chief of Staff spun up the CTO and the CPO"* — the
  **edge** is legible: the parent and each child are named and linked, so a fan-out reads as
  a fan-out.
- **A new hire.** *"the CTO staffed a Frontend Engineer, reporting to the CTO"* — creating an
  employee agent is its own moment, distinct from merely delegating a task, and shows the
  `reports_to` edge.
- **Honest when empty or partial.** Unchanged from [[prd-transparent-delegation]]: the surface
  never invents an event, a decision, or a "why"; a quiet workspace says so plainly.

## The gap, precisely
*(Agent-facing register.)* Per moment — where capture stands and why the structure fails:

| Moment (Owner's words) | Today | Root cause | Record fields it needs |
|---|---|---|---|
| **Runs a process end-to-end** | Not captured | No `Stop`/`SubagentStop` hook; no run concept | `type:"run"`, `runId`, `phase:start\|finish` |
| **Kicks off other agents** | Partial — child logged, edge missing | `actor` = child; **no parent field** | `actor` (parent) + `target` (child) = the edge |
| **Spins up an employee** | Not captured | No hook on the employee-manifest / registry path; no `staff` type written | `type:"staff"`, `target`, `reportsTo` |

## Target record shape
*(Agent-facing register — the contract the tickets build to. Supersedes the [[adr-013]] §4
event for going-forward writes; old records remain valid — every new field is optional and
additive, so the tolerant reader (`explore.server.ts:279-302`) keeps parsing the 63
backfilled rows.)*

| Field | Req? | Meaning |
|---|---|---|
| `ts` | yes | Event time (ISO). |
| `type` | yes | `spawn \| run \| staff \| delegate \| confer`. The three moments key off `run`, `spawn`/`delegate`, and `staff`. |
| `actor` | yes | **The agent that acted** — the parent/delegator, the creating executive, the runner. (Today `actor` is the *child*; correcting this is the edge fix.) |
| `target` | edge events | **The agent acted upon** — the child spun up, the employee staffed. The other end of the edge. |
| `runId` | run events | Correlates a run's `start` and `finish` into one framed unit. |
| `phase` | run events | `start \| finish`. |
| `reportsTo` | staff events | The supervisor edge captured at employee creation. |
| `summary` | yes | Human-readable one-liner (already redacted for secrets). |
| `refUrl` | best-effort | The artifact/ledger/PR/thread the event points at. **Currently never written** — the reason links are dead. |
| `threadId` | optional | Thread association (episodic lens, [[work-031]]). |
| `sessionId` | yes | Capturing session. |
| `id` | best-effort | Stable event id — enables the read-path **dedup** the surfacing ticket needs. |

> **Why `actor`-means-parent is the crux.** The agent page filters by actor
> (`activityForActor`, `explore.server.ts:326-329`). With `actor` = child, "what this agent
> did" actually lists "times this agent *was spawned*" — backwards. Making `actor` the doer
> and adding `target` is what turns the log into the **delegation graph** the Owner asked to
> watch. Resolving the parent from a `PreToolUse` payload is a real open question
> (`log-activity.py:11-14` admits it) — it is the CTO deep-dive in [[work-078]], not
> hand-waved here.

## Scope (this cycle)
*(Every item traces to a ticket; new scope is Owner-gated, [[invariants]] §I. Gate class is
called out because the capture side is **not agent-editable**.)*

| Ticket | Intent | Owner | Gate class |
|---|---|---|---|
| **[[work-077]]** | *(Prerequisite, already open)* matcher `Task\|Agent` + write-path converge — makes capture fire and reach the Console at all. | [[cto]] | **Owner-applied** (`.claude/**`) |
| **[[work-078]]** | Spawn capture: record the **parent→child edge** (`actor`=parent, `target`=child). Delivered as an owner-apply doc. | [[cto]] | **Owner-applied** (`.claude/hooks/**`) |
| **[[work-079]]** | End-to-end **run** capture: a `Stop`/`SubagentStop` hook emitting `type:"run"` start/finish sharing a `runId`. Owner-apply doc. | [[cto]] | **Owner-applied** (`.claude/**`) |
| **[[work-080]]** | **Staffing** capture: emit `type:"staff"` + `reportsTo` when an employee manifest is created; hook the registry/employee-manifest path. | [[cto]] | **Owner-gated** (core capture surface) |
| **[[work-081]]** | Console **read-model**: extend `ActivityEvent` + `parseActivityLine` to carry `target`/`runId`/`phase`/`reportsTo`/`refUrl`; group runs by `runId`. | [[cto]] | Agent-buildable (periphery) |
| **[[work-082]]** | **Surfacing uplift**: per-moment rows + verbs, the parent→child edge rendered, working links (`refUrl`/thread), run start↔finish framing, read-path **dedup**. | [[chief-designer]] | Agent-buildable (periphery) |

## Non-goals (this cycle)
- **Inferring decisions or "why" from prose or prompts** — never; the graph comes from the
  hook, decisions stay linked to the [[ledger]] agents write ([[adr-013]] §5). Unchanged.
- **Capturing activity outside the in-session spawn tool** — a separate `claude` terminal, a
  cloud routine, or an SDK process stays out of scope; backfill is the safety net ([[work-077]]).
- **No push/notifications, no accounts, no second reader** — single-user, local-first
  ([[invariants]] §II).
- **No new store or service** — still append-only `activity/*.ndjson`, local + gitignored
  ([[adr-013]] §6); this changes the *shape* of the line, not where it lives.

## Success
The Owner opens Explore → Activity after a real work session and can, **without reading a
transcript**, point to (1) a process that ran end-to-end as one framed unit, (2) an agent
that kicked off others with the parent→child edge legible, and (3) an employee that was
spun up with its `reports_to` edge — each visibly distinct, each link live. The surface
still says "nothing captured yet" honestly on a quiet workspace and never fabricates a row.

---

Follows [[doc-standards]] (§4 registers, §9 presentation). **Living, supersede-not-destroy**
(§5): this PRD extends [[prd-transparent-delegation]]; as tickets land, stamp sections and
record supersedes in git + the [[ledger]]. No ledger entry is written for this proposal
itself — it is a proposal, pending Owner disposition.
