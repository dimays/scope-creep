---
name: adr-003
description: The Console is the first Golden-Path app (core stays headless); local-first now, later deployed to a persistent host the Owner owns behind an edge perimeter.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# ADR-003: Console Architecture & Deployment

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** CTO (recommendation), Chief of Staff, Owner (rulings)
- **Owner-gated:** yes (Owner ruled on the model and the INVARIANTS clarification)

## Context
ADR-001 chose the stack for *manufactured apps* but not the control plane's own
end-user surface. Two surfaces exist: the **operator surface** (how the factory is
driven — the Claude Agent SDK / harness, headless) and the **end-user surface**
(the web app the Owner looks at to see the suite, invoke loops, chat with agents,
watch previews). The Owner wants the latter reachable eventually at a URL they own,
local-only for now.

A tension surfaced: a publicly-reachable Console is powerful (it can change code,
deploy, spend), yet [[invariants]] §II says "no auth, ever."

## Decision
1. **The Console is the first Golden-Path app** (`scope-creep-console`), in its own
   repo, honoring the [[app-contract]]. The **core stays headless** — charter,
   agents, loops, standards, driven by the Agent SDK. The Console is periphery
   holding a privileged Grant to operate the factory. Building it dogfoods the
   whole system.
2. **Deployment is staged:**
   - **Now:** local-first — `react-router dev` on `localhost`, no exposure.
   - **Later:** a **persistent host the Owner owns** (Fly.io machine + volume, our
     blessed target, or a small VPS) bound to a custom domain. Not serverless-edge —
     the backend needs the repos, Claude auth, and secrets on a durable filesystem.
3. **Exposure is controlled at the edge, not in-app.** The deployed Console sits
   behind Tailscale, Cloudflare Access, or a reverse-proxy credential. No accounts,
   no roles, no tenancy. See the Owner-approved clarification in [[invariants]] §II.

## Consequences
- The mutator stays small; the operator UI can be freely rewritten without touching
  the immutable core.
- The Console proves the `new-app` loop end-to-end on its own construction.
- The backend host is a single durable machine (state, secrets, repos) — a
  deliberate single point we accept for a single-user system; backups/repro come
  from the per-repo Dockerfile + committed lockfiles.

## Alternatives considered
- **Console built into the core** — rejected: couples the operator UI to the
  immutable core and violates the small-mutator principle.
- **In-app authentication for the public Console** — rejected: violates the §II
  product rule; an edge perimeter achieves the same protection without accounts.
- **Serverless/edge deploy** — rejected: the Console backend needs a durable
  filesystem, secrets, and Claude auth to run loops; not an edge workload.
