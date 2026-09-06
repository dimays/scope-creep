---
name: ledger-039-threads-runtime-reframe
description: A gate-catch and direction change (2026-09-06). The Owner asked to bake the app's agent cost into Claude Max; the CRO verified from first-party sources that powering a self-built app via subscription OAuth is ToS-disallowed, and flagged that even testing it risked the Owner's account. The Owner reframed Threads to a projection + "open in Claude" launcher (no automated Claude calls); the CRO verified that path is clean and buildable. Ratified as ADR-016.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Ledger 039 — Threads runtime reframe (a gate-catch)

**Date:** 2026-09-06 · **Recorded by:** the operating session, ratified by the Owner.

## What happened
The Owner observed that the local prod server reported no `ANTHROPIC_API_KEY` (a `.env`-load
gap — the key is present) and, more importantly, raised the cost model: the in-app agent
runtime ([[work-040]]) bills as metered API usage, **separate from the Owner's Claude Max
subscription**. The Owner asked to bake the cost into Max and have the app trigger real local
workflows.

## The gate-catch (why this entry exists)
The operating session initially proposed moving the runtime onto the Claude Agent SDK with
the Owner's **subscription OAuth** — presented as "the right shape." The Owner chose
**verify-first** (per the just-ratified [[decision-rights]] / spike-gate discipline). The
[[chief-reality-officer]] then verified against **first-party sources** that this is
**ToS-disallowed**, not merely a gray area:
- Claude Agent SDK docs: third parties may not offer claude.ai login / subscription rate
  limits for their products — *"Use the API key authentication methods."*
- Consumer Terms §3(7): automated/script access to the Services is prohibited except via an
  API key. Bites even for a single-user, local, personal app.

Critically, the CRO also flagged that the **QA runnable test itself** would exercise the
prohibited path against the Owner's real Max account (account-suspension exposure). The
operating session **halted the QA spike mid-setup** on that finding — confirmed it had not
yet run any live query, so the account was never touched. **The verify-first discipline and
the CRO/QA split worked exactly as designed: a load-bearing optimistic claim was caught and
killed before any build or risky test.**

## The resolution (Owner-directed, CRO-verified, Owner-ratified)
Reframe Threads from an in-app chat client to a **projection + "open in Claude" launcher +
link-out layer** — the app makes **zero** automated Claude calls; the real CoS conversation
stays in Claude Desktop / Claude Code (permitted harness, on Max). The CRO verified this is
ToS-clean, that Anthropic ships a real `claude://` deep-link scheme (thread-precise for
claude.ai chats), and that iframe-embedding claude.ai is a dead end. Ratified as
[[adr-016]]; [[prd-cos-threads]] reframed (proposed); build phase is [[work-044]].

## Lessons (for the level-set loop, [[work-033]] / [[resource-budget]])
- "The right shape" from an agent — including the operating session — is a claim to verify,
  not a decision. First-party sources beat confident reasoning.
- A runnable spike can itself be the risk; the CRO gates *whether* to run, not just *what*.
- The permitted cost path for a self-built app is an **API key** (metered). Baking into Max
  requires Anthropic's explicit prior approval — an Owner-level outreach, not an agent call.
