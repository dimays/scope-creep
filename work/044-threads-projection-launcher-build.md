---
id: work-044
title: Threads projection + launcher build (ADR-016)
type: feature
status: proposed
priority: high
owner: cto
spec: prd-cos-threads
created: 2026-09-06
updated: 2026-09-06
---
The build phase of the [[adr-016]] reframe: turn the in-app Threads surface into a
**projection + "open in Claude" launcher + link-out** layer that makes **zero automated
Claude calls**. Grounded in the reframed [[prd-cos-threads]] and [[ledger-039-threads-runtime-reframe]].

Scope (resolve the ADR/PRD open questions):
- **Transcript/summary projection** from local session/ledger data (operator/CoS session
  capture, `human-input/*.ndjson`, [[ledger]], `activity/*.ndjson`) — merged without
  inventing turns; "empty is empty."
- **"Open in Claude" launcher** — `claude://claude.ai/chat/{uuid}` (thread-precise) or
  `claude-cli://open?repo=…&q=…` (new session + prefilled context), with a **generic-open
  floor** (button + on-screen context) that works regardless of deep-link fidelity.
- **Link-out card taxonomy** — PRs, docs, tickets, PRDs, ledger entries → stable URLs/paths.
- **Demote** [[work-040]]'s in-app streaming (no longer the primary loop) and
  `agent.server.ts`'s Messages-API path (optional; any summarizer runs on an **API key**,
  never subscription — the [[adr-016]] hard rule).

**First step — the two live-checks** [[adr-016]] flags (a one-time manual check on the
Owner's machine, cheap, before promising thread-precision): (1) is the CoS conversation a
claude.ai chat (→ thread-precise) or a Claude Code session (→ new-session+context)?
(2) does `claude://` fire from the deployed Console in the Owner's browser?

**Acceptance:** the Threads surface projects a real transcript/summary from local data with
no Claude call, offers a working "open in Claude" launcher (thread-precise where confirmed,
generic-open otherwise), and renders link-out cards to real artifacts. See [[adr-016]].
