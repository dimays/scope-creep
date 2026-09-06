---
name: prd-cos-threads
description: CoS-Threads — the Owner's single window onto the conversation with the Chief of Staff, organized into discrete threads. Proposed revision 2026-09-06 reframes it from an in-app agent chat client into a projection + "open in Claude" launcher + link-out over work that actually happens in the first-party Claude harness.
metadata:
  type: project
  status: proposed
  version: 1.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# PRD — CoS-Threads (the primary human-input loop)

Owner-directed 2026-09-05 (feedback relayed via the CoS), drafted by the CPO, ratified
as **proposed** by the Chief of Staff. **Accepted by the Owner 2026-09-06**; the
reconciling [[adr-012]] was authored first (per the Owner's chosen sequencing) and the
five gating decisions in [[ledger-028-cos-threads-roadmap]] are resolved in
[[ledger-032-cos-threads-accepted]]. Phase 1 ([[work-029]]) shipped.

> **PROPOSED revision — 2026-09-06 (this document's `status` is `proposed`).** An
> Owner-accepted product reframe (below) changes what Threads *is*: from an in-app agent
> **chat client** into a **projection + launcher + link-out** over a conversation that
> actually happens in the first-party Claude harness. This is a load-bearing change; the
> Owner accepts the direction, and the **Chief of Staff will formalize it via a new ADR +
> the decision loop** before it is `active`. Until then the reframe sections are `proposed`
> and the already-shipped unification (Phase 1) stays `active`. Supersede-not-destroy
> ([[doc-standards]] §5): nothing here is deleted; demoted scope is marked, not removed.

## The reframe: projection + launcher + link-out `proposed`

**Why now (the constraint).** The in-app Threads runtime as originally sequenced has the
Console **server** call Claude to produce the CoS reply — the live-turn stream in
[[adr-013]] / [[work-040]] re-emits Anthropic deltas from a server route, and the deeper
Phase-5 conversation was to ride the [[work-017]] runtime. The **Chief Reality Officer's
session finding (2026-09-06, verified against first-party Anthropic sources — the Agent
SDK docs + the Consumer Terms)** is that powering a **self-built app** via the Owner's
Max/subscription **OAuth** is **ToS-disallowed**: a self-built app must authenticate with
an **API key**, not subscription auth. So the honest choices are (a) meter every in-app
reply on `ANTHROPIC_API_KEY` — double-billing against a Max plan the Owner already pays
for — or (b) stop making the app the place the conversation happens.

**The Owner's chosen resolution (which the Owner states is "totally acceptable" and
actually prefers).** Keep the **real conversation with the Chief of Staff in Claude
Desktop / Claude Code** — the permitted first-party harness, on Max — and **reduce the
in-app Threads experience to a projection + launcher**:

- a **transcript + summary** of the CoS conversation, **projected from local
  session/ledger data** — the app makes **zero automated Claude calls**;
- an **"open in Claude" launcher** — a button that opens Claude Desktop / Claude Code,
  ideally to the relevant thread;
- **cards that link out** to the related artifacts — PRs, docs, tickets, PRDs, ledger
  entries.

This makes Threads the **exploration & visual-management layer** over work that actually
happens in Claude — exactly what the Console already is elsewhere. It already **projects**
the ledger, the Human-Input Log, agents, and loops without owning that data (per
[[prd-console-explore]], [[prd-human-input-log]], [[adr-013]]). Threads now joins that
pattern instead of being the one surface that authors intelligence.

### The user problem (still holds, now sharper) `proposed`
The Owner still wants **one window** onto his relationship with the org — not two (a Chat
tab plus a Requests section), and not a hunt across PRs, docs, tickets, and the ledger to
reconstruct "what did the CoS and I decide, and where did it go?" What he does **not** need
is for that window to *be* the chat runtime: he is happy to talk to the CoS in the harness
he already trusts and pays for. The product problem is therefore **orientation and
continuity** — "show me the conversation and let me jump into it / into its outputs" — not
**hosting a second-class chat client** beside the real one.

**Success signal (reframed):** the Owner opens Threads to see the current state of his
conversation with the CoS (transcript + summary + what it produced), clicks **"open in
Claude"** to continue it in the real harness, and follows the **link-out cards** to the PR
/ doc / ticket / ledger entry each turn produced — and the app never once calls Claude on
his behalf or bills him twice.

## What this DEPRECATES or demotes `proposed`

Marked, not deleted (supersede-not-destroy). These become non-primary under the reframe:

- **In-app streaming API runtime — [[work-040]] — DEMOTED from "the loop" to, at most, a
  local nicety.** The live-turn stream ([[adr-013]] decisions 1 & 3) had the Console
  *server call Claude* to produce the CoS reply. Under the reframe **that is no longer the
  primary conversation loop** — the conversation lives in Claude Desktop / Claude Code. The
  transport itself (streaming a `ReadableStream`, the `WorkingIndicator`, the
  `prefers-reduced-motion` contract) is **not wasted**: it can still animate a
  **locally-produced** projection (e.g. progressively rendering an already-captured
  transcript, or a local summarization pass — see below), but it must **not** carry a
  metered, subscription-billed live agent turn. The "real-time reply from the app calling
  Claude" framing is **deprecated**.
- **The Messages-API path (`agent.server.ts`) — DEMOTED to optional, at-most
  lightweight-local-summarization — no longer "the conversation."** If it exists at all
  under the reframe, it is a bounded, optional helper (e.g. summarizing a captured
  transcript) explicitly gated on an **API key the Owner opts into**, and clearly **not**
  the Owner↔CoS exchange. The default, first-class path makes **zero** Claude calls. The
  ADR decides whether even this optional path is worth carrying (see open questions).
- **Phase 5 "live in-app conversation" — REFRAMED, not delivered as originally written.**
  The original Phase 5 ("replies come from the in-app agent runtime in real time") and its
  dependence on the [[work-017]] flagship runtime for a *multi-agent conversation inside
  the app* is **deprecated as a Threads goal**. The flagship runtime remains valid for the
  chatbot **extension** (editing an app in a live preview), which is a different, ToS-clean
  use of an API key against a build tool — it just stops being how Threads talks to the CoS.

## What still holds (preserved) `active` / `proposed`

The **thread model and its lifecycle are preserved** — they describe how the *projected*
conversation is organized, which is exactly as useful for a projection as for a live client:

- **Thread model & lifecycle** (`active`, shipped in Phase 1): a **thread** is one unit of
  Owner↔org conversation with a lifecycle — `open → (needs-you | working) → closed`, with
  **followup** and **branch** (child thread linked both ways). Terminal is `closed`; a
  closed thread can be reopened by a followup. This generalizes the [[request-intake]]
  statuses into one lifecycle. Under the reframe, lifecycle/turn is **derived from the
  projected session/ledger state** rather than written by an in-app chat runtime.
- **Whose-turn-it-is** (`active`): every thread makes its state explicit — `needs-you`,
  `working`, `closed` — the native fix for the [[work-011]] Requests bug. In the projection
  model, `needs-you` is *derived* (the CoS's last captured turn asked the Owner for
  something / a thread is parked) rather than set by an in-app reply handler.
- **The needs-you queue** (`proposed`, was Phase 2 / [[work-030]]): still wanted — a place
  the Owner sees threads parked on him. It is now **fed by projection** (the operator/CoS
  session or ledger marks a thread as awaiting the Owner) and its call to action is
  **"open in Claude"**, not "reply here."
- **Branching** (`proposed`, was Phase 4 / [[work-032]]): still wanted as a way to organize
  the projected conversation and its link-outs; a branch is a projected relationship, not a
  new chat runtime.
- **Generated-request cards & typed timeline items** (`proposed`): still wanted, now
  **strictly as PROJECTED read models** — a generated feature request, an intake outcome, a
  decision, a CRO check each render as a typed card **linking out** to its artifact (the
  Work ticket, the PRD, the ledger entry, the PR). This was already the intended shape
  (INVARIANTS §III.8: the thread *never invents activity*; it reflects what the
  ledger/runtime already logged). The reframe makes it the **whole** model, not a
  complement to a live client.

## The three surfaces of reframed Threads `proposed`

1. **Transcript + summary (projection).** Render the Owner↔CoS conversation from **local
   data only** — the captured operator/CoS session plus the ledger — as a read model.
   Zero automated Claude calls. The summary is produced **without the app calling Claude**
   (see open questions for *how*: the operator/CoS session writes it, or an opt-in local
   pass). If no summary exists yet, the surface says so honestly (the same "no activity
   captured yet" honesty [[adr-013]] decision 6 already requires) — it never fabricates one.
2. **"Open in Claude" launcher.** A button that opens Claude Desktop / Claude Code so the
   Owner continues the real conversation in the permitted harness. **Deep-link fidelity
   (jump to the specific thread) vs. a generic open is being VERIFIED by the CRO in
   parallel** and is a **to-be-confirmed detail, not a blocker.** Write the product to work
   **either way**: the guaranteed floor is a generic "open Claude" affordance plus enough
   on-screen context (thread title/summary/last state) that the Owner can resume manually;
   if the CRO confirms a reliable deep-link, the launcher upgrades to jump straight to the
   thread. Ship the floor; treat the deep link as an enhancement.
3. **Link-out cards.** Each typed timeline item links to its artifact — PR, doc, ticket,
   PRD, ledger entry. This is the Console's existing projection pattern applied to a
   thread's outputs. The exact **card taxonomy** (which artifact types get first-class
   cards, and how each resolves to a URL/path) is an open question for the ADR.

## Dependencies & synergies `proposed`

- **Reuses existing session-capture / Human-Input-Log / operator-session mechanics.** The
  transcript/summary projection reads the **same local data** the Console already tails —
  the operator-session read path (`readOperatorSessions()`), the human-input capture
  ([[prd-human-input-log]], [[adr-010]], [[adr-011]]) and the `${SCOPE_CREEP_HOME}` local
  read paths [[adr-013]] uses for activity. **The app reads local data; it never calls
  Claude.** This is a *simplification*: unifying Requests into the conversation primitive
  ([[work-014]]) already shrank the drift-prone union in `human-input.server.ts`
  ([[work-026]]); dropping the in-app agent runtime removes a whole class of server-side
  Claude-calling code from the Console.
- **Relationship to the Human-Input Log is unchanged in spirit** — Threads stays the
  interactive *front* over the same human-input loop the Log renders retrospectively; both
  are **projections that own no data**. The reframe makes Threads *more* like the Log, not
  less: both now purely project local state.
- **The `activity/*.ndjson` graph ([[adr-013]] decisions 4–6) still feeds the timeline** as
  read-only `agent-activity` cards — that path was already projection-only and ToS-clean
  (a hook writes it locally; the Console only tails it). No change.
- **The deep-link fidelity detail** is the one open external dependency; it is being
  confirmed by the CRO and the PRD is written to not block on it (see surface #2).

## Product wins `proposed`

- **A simpler app.** No server-side Claude-calling runtime to build, secure, meter, or
  keep in sync with the harness. Threads becomes projection + launcher + links — the
  pattern the Console already does well.
- **Honest about where the intelligence lives.** The real conversation is in the
  first-party harness the Owner already trusts; the app is the *management layer* over it,
  and says so. This kills the "confident but empty/partial" failure mode
  ([[ledger-033-realtime-delegation-round]], [[adr-013]] decision 6) at the root: the app
  can't misrepresent an agent turn it never produced.
- **No double-billing.** The Owner's Max plan powers the conversation in the harness; the
  app spends **nothing** on API calls in its first-class path. Resolves the ToS conflict
  the CRO surfaced without giving up anything the Owner wanted.
- **ToS-clean by construction.** The app never uses subscription OAuth to power itself, and
  never needs to, because it never calls Claude in its default path.

## Open questions for the ADR `proposed`

The Chief of Staff formalizes the reframe via a new ADR + the decision loop. Hand-off:

1. **What exactly gets projected, and from where?** Precisely which local sources compose
   the transcript (operator/CoS session capture, the human-input ndjson, the ledger,
   `activity/*.ndjson`) and how they merge into one thread timeline without inventing turns.
2. **How is a summary generated without the app calling Claude?** Candidate: the
   **operator/CoS session writes the summary** as it works (a captured artifact the app
   projects), so the intelligence stays in the harness. Alternative: an **opt-in,
   API-keyed local summarization** pass explicitly separated from the Owner↔CoS exchange
   (the demoted `agent.server.ts` role). The ADR picks one and states the trigger.
3. **The exact link-out card taxonomy.** Which artifact types get first-class cards (PR,
   doc, ticket, PRD, ledger entry, generated-request, CRO check, agent-activity) and how
   each resolves to a stable URL/path from local data.
4. **Deep-link fidelity (pending CRO).** If the CRO confirms a reliable
   open-Claude-to-a-specific-thread mechanism, adopt it; otherwise ship the generic-open
   floor. The ADR records the confirmed answer; the product does not block on it.
5. **Fate of the demoted transport ([[work-040]]) and `agent.server.ts`.** Keep the
   streaming transport only to animate local projections? Retire the Messages-API path
   entirely, or keep it as the opt-in local-summarization helper in Q2? The ADR decides.

## How it subsumes Chat + Requests `active`
Chat and Requests are the *same shape* — an ordered conversation between the Owner and the
org — split only by history. Threads unifies them onto the **one conversation primitive**
([[work-014]], [[adr-008]]): a thread is a `conversation`; its items are
`conversation_messages` plus typed attachments. This is **shipped** (Phase 1, [[work-029]])
and unaffected by the reframe — the reframe changes *how a thread's turns are produced and
continued* (projection + launcher, not an in-app runtime), not the unified data model.

## Phased rollout (revised) `proposed`
- **Phase 1 — MVP: unify.** ([[work-029]], `active`/shipped) Chat + Requests collapsed into
  one **Threads** surface on the conversation primitive, with explicit lifecycle/turn and
  intake outcomes inline. Unchanged by the reframe.
- **Phase 2 — needs-you queue, fed by projection.** ([[work-030]]) The Owner gets a
  needs-you queue derived from projected session/ledger state; its CTA is **"open in
  Claude."**
- **Phase 3 — visible agent activity (projection).** ([[work-031]]) Project the
  delegation/spawn graph from `activity/*.ndjson` and link decisions to the ledger
  ([[adr-013]]) — already projection-only; unaffected.
- **Phase 4 — branching + generated-request cards (projection).** ([[work-032]]) Branch/
  child threads and generated-request cards as **projected read models** linking out to
  their tickets/PRDs.
- **Phase 5 — REFRAMED: transcript + summary projection + "open in Claude" launcher +
  link-out cards.** Replaces the deprecated "live in-app conversation" Phase 5. The real
  conversation stays in the first-party harness; the app projects and launches. The demoted
  transport ([[work-040]]) and Messages-API path ([[adr-013]]) are re-scoped here per the
  open questions. New work tickets are cut by the CoS after the ADR.

## Out of scope (not today)
- **An in-app agent chat runtime that calls Claude to power the Owner↔CoS conversation** —
  now explicitly out of scope (ToS + double-billing; the CRO finding). The conversation
  lives in Claude Desktop / Claude Code.
- Notifications/push beyond an in-app "needs-you" queue (needs a separate decision; the
  single-user, no-auth, local-first posture in [[adr-003]] / INVARIANTS §II constrains it).
- Thread search, tagging, and intent-mix analytics.
- **Auth/roles/tenancy — ever** (INVARIANTS §II). Threads is single-user by construction.

## Success signal (revised)
The Owner runs his relationship with the org from **one** Threads surface: he opens it to
**see** the current conversation with the CoS (transcript + summary) and everything it has
produced (link-out cards), clicks **"open in Claude"** to continue it in the harness he
already trusts, watches the projected C-suite activity, branches a tangent, and closes a
thread — and the app never calls Claude on his behalf, never bills him twice, and never
pretends to host a conversation it doesn't.
