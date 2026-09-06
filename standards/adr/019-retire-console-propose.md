---
name: adr-019
description: Remove the Console's Propose section (the in-app self-editing surface, work-017) and the in-app agent-chat runtime that backs it. Propose is a strictly-weaker, metered, API-keyed reimplementation of what Claude Code already does natively, it violates ADR-016's zero-automated-Claude-calls rule, and its chat-kind conversation is the source of the recurring "Console chat" thread the Owner wants gone. The honest successor is the ADR-016 "open in Claude" launcher (work-044). Owner-directed 2026-09-06.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-06
---

# ADR-019: Retire the Console's Propose section

- **Status:** accepted (direction). The code removal is an execution follow-up for a
  focused Designer/CTO pass — see the exact removal list below. This ADR does **not**
  edit the Console (a Designer is polishing it concurrently; avoid collision).
- **Date:** 2026-09-06
- **Deciders:** **Owner-directed.** [[chief-product-officer]] recommends and records; the
  Owner asked the CPO to reconsider whether Propose is still helpful. Execution (route/nav
  deletion, data cleanup) is the build phase, ratified by [[chief-of-staff]] and landed via
  the normal gated PR flow.
- **Owner-gated:** yes — the Owner posed the question; this records the recommendation.
- **Builds on:** [[adr-016]] (Threads as projection + launcher; the app makes zero
  automated Claude calls). **Retires:** the in-app self-edit vision of
  [[prd-chatbot-extension]] ([[work-013]]/[[work-014]]/[[work-015]]/[[work-016]]/[[work-017]]).

## Context

The Owner: *"the entire Propose section seems redundant now. Ask the CPO to reconsider
whether it's helpful or not."*

**What "Propose" actually is.** In `scope-creep-console`, the Propose tab (`/propose` →
`app/routes/propose.tsx`, the [[work-017]] flagship) is the legacy in-app self-editing
flow: the Owner describes a change in natural language → the Console **server** runs an
Agent-SDK tool loop that drafts real `{path, content}` edits → the edits are previewed in
an isolated worktree ([[adr-009]]) → **Approve** opens a gated PR ([[work-016]]). It is
backed by the in-app agent runtime ([[work-014]], [[adr-008]]) and its resource routes
(`chat/send`, `chat/propose`, `chat/preview`, `chat/land`, `chat/decline`).

**Three facts make it redundant now:**

1. **It contradicts [[adr-016]]'s load-bearing rule.** ADR-016 reframed the Console to a
   **projection + "open in Claude" launcher** whose hard invariant is *the app makes zero
   automated Claude calls* — the real work happens in the first-party Claude harness
   (Claude Code / Desktop, on the Owner's Max plan), and the Console projects and links to
   it. Propose is the single largest remaining violation of that principle: it drives an
   in-app agent to author code. ADR-016 already **demoted the substrate** Propose sits on
   (the `agent.server.ts` Messages-API path and [[work-040]]'s in-app runtime → "optional,
   at-most opt-in, API-keyed"). Propose is now an orphaned surface standing on a demoted
   runtime; keeping it means the Console holds two contradictory theories of itself.

2. **It is a strictly-weaker duplicate of Claude Code — the actual redundancy the Owner
   named.** Propose only functions when `ANTHROPIC_API_KEY` is set (verified in
   `propose.tsx`'s loader and `chat-propose`); it is therefore **metered, pay-per-use,
   billed separately from Max** — precisely the double-billing ADR-016 moved away from. And
   what it buys for that money is a capped, single-shot, one-proposal reimplementation of
   what the Owner already does, for free-under-Max and at full power, in Claude Code:
   describe a change → agent drafts a diff → gated PR. The Console reimplementing that
   badly, for extra cost, is the redundancy.

3. **It is the source of the recurring "Console chat" thread the Owner separately asked to
   eliminate.** Both `chat/send` and `chat/propose` call
   `getOrCreateConversation("chat", "Console chat")`, which seeds a `kind:"chat"`
   conversation (with the work-014 greeting). The CoS-Threads data layer
   (`threads.server.ts`, [[adr-012]]) lists **every** non-archived `conversations` row as a
   thread — so that seed re-appears in Threads every time Propose (or the old chat) is used.
   **Propose and the unwanted "Console chat" are the same legacy surface.**

There is a subtlety worth stating so it isn't re-litigated: Propose uses an **API key**,
not subscription OAuth, so it is *not* the ToS violation ADR-016 forbade. It is
**ToS-clean but strategically wrong** — it reintroduces the metered cost and the
app-drives-Claude architecture that ADR-016 deliberately retired.

## Decision

**Remove the Propose section and the in-app agent-chat runtime that backs it.**

The honest successor already has a home: when the Owner wants to propose a change *from*
the Console, the [[adr-016]] pattern is an **"open in Claude" launcher** — a
`claude-cli://open?repo=…&q=…` deep-link that opens a Claude Code session in the repo with
the change prefilled. That is Propose done right: zero in-app Claude calls, uses Max, and
hands the Owner the full-power tool instead of a capped copy. Building the launcher is
[[work-044]], not this ADR; this ADR removes the surface it replaces so the two don't
coexist.

This ADR is a **decision + removal spec only**. It does not touch the Console.

## The exact removal list (for the follow-up Designer/CTO pass)

All paths are in the **`scope-creep-console`** repo. Verified against the code on
2026-09-06.

### 1. Nav entry — `app/root.tsx`
Delete the Propose tab in `TopNav` (the `<NavLink to="/propose">Propose</NavLink>` block,
~lines 44–46). No other nav entry references Propose or chat.

### 2. Route registrations — `app/routes.ts`
Delete these six lines:
- `route("chat/send", "routes/chat-send.tsx")`
- `route("chat/propose", "routes/chat-propose.tsx")`
- `route("chat/preview", "routes/chat-preview.tsx")`
- `route("chat/land", "routes/chat-land.tsx")`
- `route("chat/decline", "routes/chat-decline.tsx")`
- `route("propose", "routes/propose.tsx")`

**Keep** `route("chat", "routes/chat.tsx")` — `chat.tsx` is a **bare redirect to
`/threads`** ([[adr-012]] legacy redirect) with no dependency on the runtime; retaining it
keeps old `/chat` links from 404-ing. (Optional to remove; if removed, drop `chat.tsx` too.)

### 3. Route files — `app/routes/`
Delete: `propose.tsx`, `chat-send.tsx`, `chat-propose.tsx`, `chat-preview.tsx`,
`chat-land.tsx`, `chat-decline.tsx`.

### 4. The `getOrCreateConversation("chat", "Console chat")` seed
Both call sites (`chat-send.tsx:14`, `chat-propose.tsx:26`) are deleted with their routes,
so nothing re-seeds the `kind:"chat"` conversation. **Add a one-time data cleanup** to drop
or archive the *existing* "Console chat" row so it stops projecting into Threads. **Do not**
remove the `conversations` / `conversation_messages` tables or `threads.server.ts` — those
are the [[adr-012]] Threads model and stay; only the `chat`-kind seed row is the nuisance.

### 5. Orphaned server libs — `app/lib/` (delete only after the routes above are gone)
Once the chat routes are deleted, these have **no remaining importers** and should be
removed with their tests:
- `propose.server.ts` (+ `propose.test.ts`) — imported only by `chat-propose`.
- `conversation.server.ts` (+ `conversation.server.test.ts`) — imported only by
  `chat-send` / `chat-propose`.
- `agent.server.ts` (+ `agent.test.ts`, `agent.interruption.test.ts`) — imported only by
  `conversation.server` and `propose.server`, both being deleted.

**Do NOT delete `sandbox.server.ts`** — it is shared: `authoring.server.ts`,
`employee-scaffold.ts`, and the org authoring routes (`org-employee-preview`,
`org-employee-land`, `org-template-preview`, `org-template-land`) all import it. The
chat-* routes were only *some* of its consumers. (Cosmetic: its default PR body string
`"Proposed via the Console chat."` at ~line 109 can be reworded, not required.)

### 6. Tests
- `app/routes/route-entrypoints.test.ts` — remove the `describe("route: /propose …")` and
  `describe("route: /chat/propose …")` blocks and the `chatProposeAction` / `proposeLoader`
  imports.
- Delete `app/lib/propose.test.ts`, `app/lib/conversation.server.test.ts`,
  `app/lib/agent.test.ts`, `app/lib/agent.interruption.test.ts` with their libs.
- `app/lib/human-input.server.test.ts:34` — a fixture inserts a
  `{ kind:"chat", title:"Console chat" }` row; update the fixture so the test no longer
  depends on the removed surface.

### 7. Control-plane doc scope to retire (this repo — a CPO follow-up, not a Console edit)
Mark [[prd-chatbot-extension]] (the flagship in-app self-edit spec:
[[work-013]]/[[work-014]]/[[work-015]]/[[work-016]]/[[work-017]]) **superseded by
[[adr-016]] + [[adr-019]]**, per [[doc-standards]] §5 (supersede/annotate, never delete).
Its `status` was `proposed` and never reached `active`; the in-app agent-edit vision is
retired in favor of the launcher. This ADR **specifies** that retirement; the PRD
annotation is a small follow-up PR kept separate to avoid colliding with concurrent work.
No change is needed to [[prd-console-explore]] (it already lists agent chat as out of scope)
or [[prd-cos-threads]] (its `proposed` reframe already demotes the in-app runtime).

## Consequences

- **The Console becomes a coherent read/projection + launcher surface** — one honest
  theory of itself, faithful to [[adr-016]] and to the [[invariants]] (§III: retiring the
  in-app live-write capability that [[adr-009]] flagged as the first thing to cross the
  §III line shrinks the Console's blast radius).
- **The "Console chat" thread stops reappearing** — the Owner's separate ask is resolved by
  the same removal.
- **No metered double-billing** from the Console; code changes flow through Claude Code on
  Max.
- **Cost:** the Owner temporarily loses an in-Console "propose a change" button until the
  launcher ([[work-044]]) ships. Mitigation: the Owner already makes changes in Claude Code
  today; the launcher restores the one-click entry point without the in-app agent. Sequence
  the launcher promptly so there is no capability gap the Owner feels.
- **[[work-017]] / [[work-016]] are `done` tickets** — they are not reopened; they are
  **superseded**. The self-edit machinery they built (worktree isolation via
  `sandbox.server.ts`) is *reused* by the org authoring flows, so the engineering was not
  wasted; only the Propose *surface* and its in-app agent runtime retire.

## Alternatives considered

- **Keep.** Only justifiable if the Console needed to drive code changes itself. [[adr-016]]
  settled that it must not (zero automated Claude calls). Keeping Propose preserves the
  metered cost, the "Console chat" nuisance, and the §III live-write capability — for a
  strictly-weaker copy of Claude Code. Rejected.
- **Trim** (keep Propose, gate it more loudly behind the API key, add a "this costs money"
  banner). It already only runs with a key; a banner changes nothing structural. It leaves
  the duplicate-of-Claude-Code redundancy, the "Console chat" generator, and the live-write
  capability all intact. Buys nothing the Owner asked for. Rejected in favor of remove +
  launcher.
- **Remove Propose but keep the in-app chat runtime** (`chat/send`). Rejected: `chat/send`
  is *also* an automated Claude call and is a co-source of the "Console chat" seed; the real
  Owner↔CoS conversation belongs in the first-party harness per [[adr-016]]. Removing
  Propose while keeping the chat runtime would leave the same two problems half-solved.
