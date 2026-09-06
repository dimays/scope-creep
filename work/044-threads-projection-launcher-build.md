---
id: work-044
title: Threads projection + launcher build (ADR-016)
type: feature
status: proposed
priority: high
owner: cto
assignees: linus, vera
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

---

**Epic decomposition (2026-09-06)** — this ticket is now the umbrella; the work is filed as:
[[work-046]] launcher (submit→seeded conversation; resume button), [[work-047]] transcript
projection from local Claude data, [[work-048]] link-out cards. [[work-045]] (dark-only) runs
alongside. Whole path targets the Owner's feature-flow spec (below).

**✅ SURFACE DECISION — RESOLVED (Owner, 2026-09-06): Claude Code** (auto-transcript). The conversation runs as a Claude Code session in the control-plane repo; the app projects its local JSONL transcript. Launcher/projection shipped in console #32 ([[work-046]]/[[work-047]]). Original framing below.

**⛔ (resolved) surface (Owner's call):** the auto-captured transcript the Owner
wants only works ToS-clean from **Claude Code** sessions (local JSONL under `~/.claude/projects/`,
readable with no Claude call) — **not** from **Claude Desktop / claude.ai** chats (server-side
transcript, unreadable locally without a Claude call). Confirmed 2026-09-06:
`claude://claude.ai/new?q=` fires and seeds a message (Claude Desktop path works for *launching*),
and local Claude Code JSONL transcripts exist. So: **Claude Desktop** = polished chat + thread-
precise resume, but **no auto-transcript** (manual/summary only); **Claude Code** = full
auto-projected transcript + CLI resume, but the terminal is the surface. Pick one before
[[work-046]]/[[work-047]] finalize.

**Feature-flow acceptance (Owner-requested, to dogfood once built):** type a prompt in the UI →
Submit opens a thread in Claude with that message as the first message of a new conversation →
the in-app input is then disabled/hidden and replaced by a "Resume in Claude" button that
reopens the existing thread → responses/follow-ups appear in the in-app thread transcript.
