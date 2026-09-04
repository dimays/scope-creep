---
name: ledger-001-console-architecture
description: Console architecture decided; INVARIANTS §II clarified (Owner-approved).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 001 — Console architecture

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Decisions
1. **Console = the first Golden-Path app** (`scope-creep-console`, own repo); the
   core stays headless. Recorded as [[adr-003]].
2. **Deployment staged:** local-first now (`localhost`), later a persistent host the
   Owner owns (Fly machine + volume or VPS) on a custom domain.
3. **Exposure controlled at the edge** (Tailscale / Cloudflare Access / proxy
   credential), never in-app auth.

## Gate decisions
- **Owner amended INVARIANTS §II** (v1.0.0 → v1.1.0): added the clarification that
  edge access control on a powerful public endpoint is distinct from the prohibited
  in-app auth. Only the Owner may amend INVARIANTS; approval given 2026-09-04.

## Follow-ups
- `scope-creep-console` repo is deferred until after core-agent wiring.
