---
name: adr-013
description: Real-time thread replies (stream the live CoS turn over the response body; short-poll for out-of-band updates; batched-with-indicator as the guaranteed floor) and transparent delegation via a structured activity log the Console projects — capturing the delegation/spawn GRAPH from a control-plane hook, while decisions stay sourced from the ledger agents deliberately write, never inferred. Names the three Owner-gated changes in the package and gates the capture core-upgrade on a proof-of-hook spike. Extends ADR-012 (Phase 3/5).
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-06
---

# ADR-013: Real-time thread replies + transparent-delegation activity

- **Status:** accepted (real-time transport); **the activity-capture write path is
  proposed, gated on a proof-of-hook spike + Owner approval** — see decision 7.
- **Date:** 2026-09-06
- **Deciders:** convened C-suite dry run (Owner-invited; the decision spans ≥3 domains, so
  [[decision-rights]] calls for the full room). **CTO** lead on real-time; **CoS** lead on
  the activity-capture write path (it touches `.claude/` + a core record-set). **CPO** +
  **Chief Designer** consulted (joint owners of the streaming-vs-batched call); **CKM** on
  the activity schema/registry; **CRO** verified; **CoS** ratifies. Owner-gated where
  flagged. Recorded live in [[ledger-033-realtime-delegation-round]].
- **Extends:** [[adr-012]] — fills in Phase 3 ([[work-031]], inline agent activity) and the
  Phase 5 live-reply runtime it deferred. No reshape of the conversation primitive; both
  ride the `conversation_messages.type` discriminator ADR-012 already reserved.

## Context
The Owner directed that agent replies "appear in real-time as much as possible… the user
shouldn't have to refresh… a cute or elegant little indicator while the agent(s) work…
Then the response should appear," and that **transparent delegation** — C-suite decisions,
subagent spin-ups, staffing — be surfaced at a high level. [[work-029]] shipped Threads
with async triage and no live agent surface.

Two facts (both CRO-verified against the repos) constrain the design:
1. **Two different real-time needs.** (a) The **live turn** — Owner types, the CoS replies
   — is request-scoped and same-process. (b) **Out-of-band org activity** — an operator
   session or future in-app runtime writing into a thread over time — is *cross-process*.
2. **No structured activity exists to project.** The [[ledger]] is curated **prose**
   markdown, not a typed event stream. The only machine-projectable cross-repo feed today
   is `human-input/*.ndjson`, which the Console already tails. Projecting typed delegation
   events out of prose would mean **inventing** them — forbidden (INVARIANTS §III.8;
   [[work-031]]'s own "never invents activity" clause).

## Decision
1. **Stream the live turn over the response body** (the one reply the Owner waits on). The
   Owner's message POSTs to a resource route returning a streaming `Response`
   (`ReadableStream`) that re-emits Anthropic `content_block_delta` text. Request-scoped,
   same-process — **no websocket, no long-lived SSE-GET channel, no broker**. On stream
   end, persist the full reply and flip the thread's lifecycle/turn. *(Shipped: work-040.)*
2. **Short-poll (~2–3s) for out-of-band activity and the `needs-you` queue.** Because a
   *different process* writes those, the Console reflects them by revalidating the open
   thread + badge on an interval (RR `useRevalidator`). Cross-process-correct by
   construction; degrades to "nothing new"; zero new infrastructure.
3. **Streaming vs. batched (joint CTO/CPO/Chief Designer call): stream the live turn, poll
   the rest, and treat batched-with-indicator as the guaranteed floor.** With no
   `ANTHROPIC_API_KEY` or on any error, the turn degrades to a single chunk behind the
   working indicator — batched, automatically. The three concur.
4. **Add a minimal structured *activity log*; the prose ledger complements it — never
   parse the ledger.** A new append-only `activity/YYYY-MM.ndjson` record-set mirrors the
   proven `human-input/*.ndjson` pattern. Event shape:
   `{ ts, id, actor, type: spawn|delegate|staff|confer, summary, threadId?, refUrl?, sessionId }`.
5. **A hook captures the delegation/spawn GRAPH; DECISIONS stay sourced from the ledger —
   never inferred** (CRO correction). Capture is a control-plane **`PreToolUse` matcher on
   `Task` (and/or `SubagentStop`)** hook — **not** `UserPromptSubmit`, which fires on the
   Owner's prompt and would capture no spawns. A hook can record *that* the CoS spun up /
   delegated to an executive; it **cannot** record *that an ADR was ratified* or *why* — an
   agent writes those as prose. So the surface renders the spawn/delegation graph from the
   activity log **and links decisions to the ledger entries agents deliberately write**. It
   never infers a decision or a rationale from prompt text.
6. **The Console only projects — it never authors activity, so it cannot invent it.** A
   `readActivity()` tails `${SCOPE_CREEP_HOME}/activity/*.ndjson` exactly like
   `readOperatorSessions()` (best-effort, skips malformed lines, never throws), projecting
   `threadId`-matched events as read-only `agent-activity` cards (the reserved ADR-012
   discriminator — additive) and a global org-activity feed. The activity log is local +
   gitignored, so it is **empty on a fresh clone**; the surface must say "no activity
   captured yet" honestly, never render an authoritative-looking but empty feed.
7. **This package contains THREE Owner-gated changes, not one** (CRO correction of an
   earlier undercount). Each goes through its own gate, none bundled:
   (a) the **activity-capture write path** — new `activity/` record-set + the `.claude`
   hook — via [[core-upgrade]] (touches `.claude/` + a core record-set: Owner-gated
   always); **gated additionally on a proof-of-hook spike** (below);
   (b) **promoting the two hardcoded status colors + a motion-token set into
   `@scope-creep/design`** — a shared-package palette/API change (Owner-gated per
   [[decision-rights]]);
   (c) the loops **`mode` field + a `docs-lint` `owner_agent` rule** — a core-standard /
   record-set change (Owner-gated). *(Exposure work, [[work-038]].)*
8. **No gate is routed around.** Streaming changes only *how* a reply is transported; every
   thread outcome stays a human-gated proposal ([[adr-012]] §5). The activity log is
   descriptive telemetry — never authority to act.

## The spike gate (before any capture sprint)
The activity-capture core-upgrade is **not authorized until a throwaway spike proves the
hook fires**: wire the `PreToolUse: Task` (and/or `SubagentStop`) hook, run **one real
CoS→executive delegation**, and confirm a line actually landed in `activity/*.ndjson`. If
it does not fire, the premise is dead — an hour spent, not a sprint. This is the same
skepticism the level-set applied to the lying `/healthz` ([[ledger-027-level-set-round]]).

## Consequences
- **Periphery does the real-time work.** Streaming, poll/`needs-you`, and the activity
  *read* are Console app changes — ordinary tickets, no core-upgrade. Verified: those files
  live in `scope-creep-console`, not the control-plane core.
- **The activity log is local, gitignored, in-session, and decision-blind by nature.** It
  captures the in-session tool/spawn graph only — not a separate `claude` terminal or SDK
  process, and not decisions. The surface must be honest about this scope, or it recreates
  the "confident but empty/partial" failure the org exists to prevent.
- **[[work-031]] is refit:** its source changes from "the ledger" (prose, unprojectable) to
  "the activity log (graph) + ledger links (decisions)."
- **`@scope-creep/ext-chatbot`** gains an optional streaming (`onToken`/async-iterator)
  contract if the live turn is ever mounted through the shell; work-040 streams natively in
  the thread and does not depend on it.

## Alternatives considered
- **Websocket / SSE-GET channel for both paths** — rejected: bidirectional or long-lived
  server→client transport is unjustified for a single-user local app; the live turn is one
  POST and out-of-band writes are cross-process (an SSE feed would poll underneath anyway).
- **Mirror `UserPromptSubmit` for capture** — rejected: it fires on Owner prompts, not
  spawns; it would capture nothing (CRO).
- **Overload / NLP-parse the prose ledger for activity** — rejected: violates "never
  invent activity" and couples projection to prose formatting.
- **Bundle the three gated changes as "one core-upgrade"** — rejected (CRO): it slips two
  Owner-gated changes past explicit approval; each gets its own gate.
