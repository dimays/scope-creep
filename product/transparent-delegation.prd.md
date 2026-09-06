---
name: prd-transparent-delegation
description: Surface the org's delegation at a high level in the Console — who broke off, spun up a subagent, staffed a ticket, conferred — projected from a structured activity log, with decisions linked to the ledger the agents write. The Owner's "transparent delegation" ask; first stress-tested by the 2026-09-06 direction round itself.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# PRD — Transparent Delegation

Owner-directed 2026-09-06. Drafted by the CPO from a convened C-suite round (CTO, Chief
Designer, CKM, CRO), ratified **proposed** by the CoS. Grounded in [[adr-013]] (the capture
+ projection decision) and [[ledger-033-realtime-delegation-round]] (which records the very
round that produced this doc — its first real data).

## The user problem
When the C-suite breaks off to decide, spins up subagents, staffs tickets, or confers, the
Owner can't see it. He wants to watch the org work — "I want to know about it, at a
high-level" — without reading transcripts. Today the [[ledger]] records consequential
actions as **prose**, so there is no scannable, structured view of *who did what*.

## What it is (and is not)
- **A projection, never an author.** The Console *reads* a structured activity log and the
  ledger; it never writes activity and so cannot invent it ([[adr-013]] §6). The thread and
  the agent page reflect what was logged — nothing more.
- **Graph, from the hook; decisions, from the ledger.** A control-plane hook captures the
  **delegation/spawn graph** (that the CoS spun up the CTO, staffed a ticket). *Decisions
  and their rationale* are prose an agent deliberately writes — the surface **links** to
  those ledger entries, it does not infer them ([[adr-013]] §5). This honesty is the
  feature: a delegation feed that quietly invented "why" would be the lying-`/healthz`
  failure the org exists to catch.
- **Honest when empty.** The activity log is local + gitignored → empty on a fresh clone.
  The surface says "no activity captured yet," never renders an authoritative-looking but
  empty feed.

## The activity event (see [[adr-013]] §4)
`{ ts, id, actor, type: spawn | delegate | staff | confer, summary, threadId?, refUrl?, sessionId }`
— five verbs matching the Owner's words. `threadId` attaches an event to a thread; absent
it, the event feeds the global org-activity view.

## Two lenses on one source
- **Entity lens — the agent's page** (the existing agent profiles in Explore): each executive's page shows
  what it has done (recent spawns/delegations/confers) and what it connects to (its owned
  tickets, loops, docs, ledger entries). The primary home for exploration ([[work-037]]).
- **Episodic lens — inline in a thread** ([[work-031]], refit): when a thread triggers org
  work, the spin-ups/delegations render inline as read-only `agent-activity` cards, each
  deep-linking to its artifact.

The delegation view lives under **Explore** (with the timeline + agent profiles), not the
Work board — delegation is *events*, not *tickets* (CPO + Chief Designer concur).

## Success signal
The Owner opens an executive's page (or a thread) and sees, at a glance and truthfully,
that the CoS convened the room, delegated to the CTO/CPO/Designer/CKM, and the CRO
verified — the 2026-09-06 round rendered as the first real entries, closing the stress test
on itself.

## Relationships
- **[[adr-013]]** — the capture (hook + `activity/*.ndjson`) and projection decision, the
  three Owner-gated changes, and the spike gate this PRD's [[work-036]] is bound by.
- **[[work-031]]** — the episodic (in-thread) lens; refit to read the activity log + ledger
  links rather than parse prose.
- **[[prd-console-explore]]** — the entity lens extends Explore; cross-linking (agent ↔
  docs/loops/events/tickets) is co-owned with CKM ([[work-039]]).
- **[[decision-rights]]** — this round is itself a live dogfood of the convene-the-room rule.

## Out of scope (not today)
- Capturing activity outside the in-session `Task` tool (a separate `claude` terminal, an
  SDK process) — the hook is blind to those; a later runtime appends the same shape.
- Inferring decisions/rationale from prose or prompts — never.
- Notifications/push beyond the in-app views (single-user, local-first; INVARIANTS §II).
