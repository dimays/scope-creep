---
name: prd-cos-threads
description: CoS-Threads — a single chat interface with the Chief of Staff, organized into discrete threads the Owner can open, follow up, branch, and close. The primary human-input loop; subsumes the separate Chat and Requests surfaces.
metadata:
  type: project
  status: accepted
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# PRD — CoS-Threads (the primary human-input loop)

Owner-directed 2026-09-05 (feedback relayed via the CoS), drafted by the CPO, ratified
as **proposed** by the Chief of Staff. **Accepted by the Owner 2026-09-06**; the
reconciling [[adr-012]] was authored first (per the Owner's chosen sequencing) and the
five gating decisions in [[ledger-028-cos-threads-roadmap]] are resolved in
[[ledger-032-cos-threads-accepted]]. Phase 1 ([[work-029]]) is now **active**.

## Owner decisions (accepted 2026-09-06)
1. **Information architecture:** the unified **Threads** surface lives **top-level,
   replacing the Chat tab** (Requests folds in) — not nested under Work. (Escalation #1.)
2. **Process:** author the reconciling **[[adr-012]]** *before* the migration; build
   behind a gated PR. (Escalation #4.)
3. **Outcome boundary, CoS-initiated threads, and sequencing** (escalations #2/#3/#5)
   resolved as the CPO/CoS recommended — see [[ledger-032-cos-threads-accepted]].

## The user problem
Today the Console splits the Owner's two-way contact with the org across **two
windows**: a top-level **Chat** tab ([[work-014]], `root.tsx` nav) and a **Requests**
section under Work ([[work-009]], `work-nav`). The Owner doesn't want two windows. He
wants **one chat interface with his Chief of Staff**, organized into discrete
**threads** he can **open, follow up on, branch, and close** — where a single thread
can carry several intermediate triggers and outcomes (a generated feature request, a
created ticket, a decision, a CRO check), where the **CoS can start a thread** when it
needs his input or to follow up, and where he can watch his **C-suite spin up, delegate
to employee agents, and confer** — inline, in that thread. This is the primary
human-input loop the Owner wants to have.

## The thread model
A **thread** is one unit of Owner↔org conversation with a lifecycle and an inline
timeline of everything that happened inside it.

- **Lifecycle:** `open → (needs-you | working) → closed`, with **followup** (add to an
  existing thread) and **branch** (split a child thread from a point in a parent,
  linked both ways). Terminal is `closed`; a closed thread can be reopened by a
  followup. This generalizes the [[request-intake]] statuses
  (`accepted | declined | needs-info | done`) into one lifecycle that also fits chat.
- **Who opens it:** either party. The Owner opens a thread to ask/tell/discuss. **The
  CoS opens a thread** when it needs the Owner's input, or **follows up** on an existing
  one — a new capability today's Owner-only-initiated surfaces don't have.
- **Intermediate triggers & outcomes (inline items in the thread):** an Owner message; a
  CoS reply; a **generated feature request**; an **action/outcome** from the
  [[request-intake]] loop (a ticket created/modified, a decline-with-reason, a
  counter-proposal, a fold-into-PRD); a **decision**; a **CRO reality check**. Each
  renders as a typed card in the thread's timeline, deep-linking to its artifact (the
  Work ticket, the PRD, the ledger entry).
- **Visible agent activity:** when a thread causes the C-suite to act, the thread shows
  it inline — an executive **spinning up**, a **delegation to an employee agent**, a
  **CoS↔executive confer**. These are read-only activity events, not new records: they
  are projected from the [[ledger]] (INVARIANTS §III.8 already requires every
  consequential agent action to be recorded) and, later, from the in-app agent runtime.
  The thread never invents activity; it reflects what the ledger/runtime already logged.

## Whose turn it is (fixes a known bug)
Every thread makes its state explicit: `needs-you` (parked on the Owner), `working`
(the org is acting), or `closed`. This is the native fix for the [[work-011]] Requests
bug — "an Owner reply doesn't change status or signal whose turn it is." In the thread
model, turn/status is a first-class field, not an afterthought.

## How it subsumes Chat + Requests
Chat and Requests are the *same shape* — an ordered conversation between the Owner and
the org — split only by history. CoS-Threads unifies them onto the **one conversation
primitive** ([[work-014]], [[adr-008]]): a thread is a `conversation`; its items are
`conversation_messages` plus typed attachments. Concretely:

- **Chat** becomes a thread with no intake outcome — just Owner/CoS turns.
- **A Request** becomes a thread whose timeline includes [[request-intake]] outcomes.
- The deferred [[adr-008]] migration finally happens: the bespoke
  `requests`/`request_messages` tables generalize into `conversations` /
  `conversation_messages`. One model, one surface, one nav entry — instead of a
  top-level Chat plus a Requests section.

## Relationships (reconcile, don't duplicate)
- **Human-Input Log ([[prd-human-input-log]], [[adr-010]], [[adr-011]]).** CoS-Threads is
  the **interactive, read-write front** of the same human-input loop the Log renders
  **read-only and retrospectively**. Two views of one loop: the Log stays the *generated
  projection that owns no data*, and Threads is the *live surface* it reads from. Threads
  writes only to the conversation primitive; the Log keeps unioning that primitive.
  Unifying Requests into `conversation_messages` also **simplifies the Log's union** (one
  owner-message source instead of two) — shrinking the drift-prone `human-input.server.ts`
  surface flagged in [[work-026]]. A CoS-initiated thread is a new org→Owner event and is
  *not* a human input; it does not pollute the Log (the Log tags Owner inputs only).
- **Conversation primitive ([[work-014]]).** Threads is built directly on it. It needs
  three additive extensions: a **thread lifecycle/turn** field; **typed attachments**
  (generated-request, intake-outcome, agent-activity, CRO-check) beyond plain text; and a
  **parent/branch link**. Live in-app agent replies (vs. today's async operator triage)
  ride the same runtime the flagship [[work-017]] builds, behind its Grants.
- **request-intake loop ([[request-intake]]).** Unchanged in substance — submit → triage
  (CoS routes; CRO sanity-checks; CPO decides) → outcome → respond. Threads is its new
  home; new scope stays **human-gated** (INVARIANTS §I.4). Every outcome is a *proposal*,
  never an autonomous act.

## Phased rollout (matures over time — not all today)
- **Phase 1 — MVP: unify.** ([[work-029]]) Collapse Chat + Requests into one **Threads**
  surface on the conversation primitive. Migrate `requests`→`conversations`. A thread has
  an explicit lifecycle/turn (retiring the [[work-011]] Requests bug) and renders intake
  outcomes inline. Triage stays **async in the operator session** (no new runtime —
  exactly today's [[work-009]] mechanism). This is the "refactor Chat/Requests the moment
  we start."
- **Phase 2 — CoS-initiated threads.** ([[work-030]]) The CoS can open a thread / post a
  followup when it needs the Owner; the Owner gets a **"needs-you" queue**.
- **Phase 3 — visible agent activity.** ([[work-031]]) Project C-suite spin-ups,
  delegations, and CoS↔executive confers into the thread timeline from the [[ledger]].
- **Phase 4 — branching + generated-request cards.** ([[work-032]]) Branch/child threads
  with linked followups; generated feature requests as first-class cards linking to their
  created tickets/PRDs.
- **Phase 5 — live in-app conversation.** Replies come from the in-app agent runtime in
  real time (not async operator triage), riding the [[work-017]] runtime + Grants. **Not
  ticketed today** — folds into the flagship when it lands.

## Out of scope (not today)
- A dedicated real-time multi-agent chat runtime (Phase 5 rides the flagship).
- Notifications/push beyond an in-app "needs-you" queue (needs a separate decision; the
  single-user, no-auth, local-first posture in [[adr-003]]/INVARIANTS §II constrains it).
- Thread search, tagging, and intent-mix analytics.
- **Auth/roles/tenancy — ever** (INVARIANTS §II). Threads is single-user by construction.

## Success signal
The Owner runs his entire two-way relationship with the org from **one** threads
interface: opens a thread, watches the C-suite act inside it, gets a CoS-initiated
follow-up, branches a tangent, and closes it — and never thinks about "Chat vs.
Requests" again.
