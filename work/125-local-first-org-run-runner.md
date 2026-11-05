---
id: work-125
title: Local-first org-run runner — headless Claude Code on the Owner's Mac (roadmap-002 WS1)
type: feature
status: proposed
priority: high
owner: cto
spec: roadmap-002
created: 2026-09-24
updated: 2026-09-24
---

The producer the org never had. Build one host-agnostic `org-run <loop>` entrypoint and run it
**locally** under launchd, using headless Claude Code on the Owner's existing login. It costs
$0 incremental ([[principles]] 9–10; [[adr-028]] §7 substrate table).

## Acceptance
- `org-run <loop>` drives the build loop (work-sweep → dev-cycle) against a real ticket and opens a PR.
- It authors as `scope-creep-routine[bot]`, using a short-lived installation token minted from the App key in the macOS Keychain.
- It never authors as dimays and never puts a credential in any cloud.
- launchd schedule: missed runs fire on wake. It runs at concurrency 1 with `--max-turns` and per-run timeouts.
- It uses Claude Code sandboxing and a dedicated checkout directory.
- Every run writes a structured run record: `outcome: worked | no-op | halted` plus a reason.
- A `halted` run surfaces to the Owner queue. It never reports a quiet "success".
- The stale claude.ai work-sweep and staffing-review routines are paused and replaced. The claude.ai
  routines keep only propose-only overnight jobs.

## Notes
Supersedes the round-2 Actions + Max-token plan. It is a probe for M1 ([[work-127]]), not a gate on it.
A separate macOS user is optional hardening, which the CTO decides after M1.
