---
name: prd-chatbot-extension
description: The flagship chatbot Extension — chat that edits a Golden-Path app in a live preview and merges the change through the gated flow.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-05
---

# PRD — Chatbot Extension (flagship)

> Reconstructed from the scheduled overnight run's plan ([[ledger-016-work-001-split]]).
> **Proposed** — awaiting Owner acceptance (especially the security decision in
> [[adr-009]]).

## Why this exists
`work-001` had been tracing to [[prd-console-explore]], whose v1 explicitly puts
"agent chat" **out of scope**. This is the flagship's real spec.

## The user problem
The Owner wants to change an app by **talking to it**: describe a change in chat, see
it rendered **live in a preview**, and — on approval — have it **merged through the
gated flow**. It is the most powerful expression of Scope Creep: the software edits
itself, at the Owner's word, safely.

## Shape (v1)
A portable Extension (like [[glossary|ext-feedback]]) that grafts a chat panel onto
any Golden-Path app, backed by an in-app agent runtime. Split into four tickets,
mapping to `work-001`'s three acceptance clauses:

1. **[[work-013]] — Portable shell (installable).** A Shadow-DOM chat panel grafted
   onto a host app, themed by host tokens. Models on `scope-creep-ext-feedback`.
2. **[[work-014]] — Conversation primitive + agent runtime.** The backend: a
   conversation model (threads/messages/roles) + an agent-turn endpoint the Console
   calls via the Agent SDK. **Shared with Work Requests v2** ([[adr-008]]).
3. **[[work-015]] — Sandboxed live preview.** A proposed edit renders in an isolated,
   state-preserving preview without disturbing the running app ([[adr-009]]).
4. **[[work-016]] — Propose → gated PR → merge.** Approve/decline in chat; approval
   opens a gated PR and merges on green. Never auto-merge.

## The overlap, resolved
The chatbot and Work Requests share the **conversation primitive** ([[adr-008]]):
Requests is the *scoped* application (produces backlog changes), the chatbot the
*powerful* one (produces code changes + live preview). Build the primitive once
(work-014); Work Requests v2 adopts it.

## Security (load-bearing — Owner-gated)
This is the first capability that grants an **agent live write access to app code
in-session**. That crosses an INVARIANTS §III line and must be Owner-approved before
`work-015`/`work-016` are built. The mitigations are in [[adr-009]]: the agent only
*proposes*; changes land only through the existing gated PR + CI + ruleset flow;
`guard-gates.sh` still blocks deploy/spend/delete/publish; never auto-merge.

## Success signal
The Owner describes a small change in the Console's chat, watches it render live,
approves it, and it merges via a green gated PR — with zero direct code editing.

## Out of scope (v1)
Multi-file/large refactors, cross-app changes, autonomous merges. One proposal, one
preview, one gated PR.
