---
name: adr-016
description: The in-app Threads experience is reframed from an agent chat client to a projection + "open in Claude" launcher + link-out layer, because powering a self-built app via the Owner's Claude Max/subscription OAuth is ToS-disallowed (first-party sourced). The real Chief-of-Staff conversation stays in Claude Desktop / Claude Code (the permitted harness, on Max); the Console projects a transcript/summary from local session/ledger data and never makes an automated Claude call. Owner-directed and Owner-ratified 2026-09-06.
metadata:
  type: reference
  status: accepted
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# ADR-016: Threads as projection + launcher (not an in-app chat client)

- **Status:** accepted (direction). The build-phase design (transcript projection, the
  launcher, the link-out taxonomy) is deferred to [[work-044]] and a focused CTO/Designer
  pass; two live-checks remain (below).
- **Date:** 2026-09-06
- **Deciders:** **Owner-directed and Owner-ratified.** [[chief-reality-officer]] verified the
  load-bearing ToS/technical facts against first-party sources; [[chief-product-officer]]
  drafted the reframed [[prd-cos-threads]]; [[chief-of-staff]] ratifies and records. The
  detailed runtime/UX design (CTO, [[chief-designer]]) is the build phase, not this ADR.
  Recorded in [[ledger-039-threads-runtime-reframe]].
- **Supersedes in part:** [[adr-013]]'s in-app live-turn runtime (see Consequences).

## Context
[[work-040]] shipped an in-app runtime where the Console **server** calls Claude's Messages
API with an `ANTHROPIC_API_KEY` — metered, pay-per-use, billed separately from the Owner's
Claude Max subscription. The Owner asked to instead bake the cost into Max and have the app
trigger real local workflows.

The CRO verified, from **first-party Anthropic sources**, that the obvious way to do that —
authenticating the app via the Owner's Max/subscription OAuth (Claude Code auth) — is **not
permitted**:
- The Claude Agent SDK docs: *"Unless previously approved, Anthropic does not allow third
  party developers to offer claude.ai login or rate limits for their products, including
  agents built on the Claude Agent SDK. Use the API key authentication methods."*
- Consumer Terms §3(7) prohibit automated/script access to the Services **except** via an
  Anthropic API key. This bites even though Scope Creep is single-user, personal, and local
  — the prohibition is on the automated non-API-key **access path**, not on scale.

So the only permitted ways for a self-built app to drive Claude are (a) an API key (metered,
the thing the Owner wants to avoid) or (b) don't have the app drive Claude at all.

## Decision
**Reframe Threads to option (b): a projection + launcher, making zero automated Claude calls.**

1. The **real Chief-of-Staff conversation stays in Claude Desktop / Claude Code** — the
   permitted first-party harness, which legitimately runs on the Owner's Max plan.
2. The Console's Threads becomes an **exploration & visual-management layer** over that work:
   - a **transcript + summary projected from local session/ledger data** (never a Claude call);
   - an **"open in Claude" deep-link launcher**;
   - **link-out cards** to related PRs, docs, tickets, PRDs, and ledger entries.
3. This is the pattern the Console **already** uses (it projects the ledger, [[prd-human-input-log]],
   agents, and loops) — Threads is made honest about where the intelligence actually lives.

### Verified facts this rests on (CRO, first-party sourced)
- **Launcher is real.** `claude://claude.ai/chat/{uuid}` opens a specific claude.ai/Desktop
  chat (thread-precise); `claude-cli://open?repo=…&q=…` opens a **new** Claude Code session
  in a repo with a prefilled prompt (resuming a specific Claude Code session is the CLI
  `claude --resume`, not a URL).
- **The projection path is ToS-clean** — reading local data and emitting links makes no
  access to the Services, so §3(7) does not apply.
- **iframe-embedding claude.ai is a dead end** — `X-Frame-Options: SAMEORIGIN` + a Cloudflare
  challenge block third-party framing.

### The hard rule (load-bearing invariant of this design)
**The app makes zero automated Claude calls.** If a machine-generated summary is ever added,
that summarizer must run on an **Anthropic API key** (Commercial Terms), never subscription
auth, and be kept out of the Owner↔CoS exchange. Otherwise the ToS exemption evaporates.

## Consequences
- **Demoted, not deleted:** [[work-040]]'s in-app streaming stops being the primary loop (its
  transport may at most animate local projections); `agent.server.ts`'s Messages-API path
  becomes optional — at most an opt-in, API-keyed local summarizer.
- **Preserved as projected read-models:** the thread/lifecycle + whose-turn model, the
  needs-you queue (CTA becomes "open in Claude"), branching, and generated-request cards.
- **Wins:** simpler app; no double-billing; ToS-clean by construction; honest architecture.
- **Two live-checks before the build claims thread-precision** (docs can't settle them):
  (1) whether the CoS conversation is a claude.ai chat (→ thread-precise deep-link) or a
  Claude Code session (→ new-session + prefilled context); (2) whether `claude://` fires from
  the deployed Console in the Owner's browser (OS scheme registration). A generic-open floor
  works either way — see [[work-044]].

See [[prd-cos-threads]] (reframed), [[ledger-039-threads-runtime-reframe]], and the CRO
findings recorded there.
