---
id: work-096
title: Redesign the cloud write path around the sandbox proxy identity wall (propose-only vs. alternate execution)
type: spike
status: proposed
priority: high
owner: cto
spec: prd-autonomous-execution-loop
created: 2026-09-21
updated: 2026-09-21
---
> **Blocker for any unattended `work-sweep` run.** The routine stays **paused**
> (`registry/routines.json`) until this lands.

The definitive root-cause is [[ledger-066-cloud-sandbox-proxy-identity-wall]]: the claude.ai cloud
sandbox's egress proxy **overrides the outbound `Authorization` header** on `api.github.com` and
re-authenticates every request as **its own GitHub App identity** (resolves to `dimays`, read-only).
Proven by a diagnostic in which a valid PAT, an invalid token, and no auth header all returned the
same `dimays` identity. Consequences:

- **No custom identity survives the sandbox** — neither the `@scope-creep-review` reviewer PAT nor a
  minted `scope-creep-routine[bot]` token can present itself to GitHub. The **author≠merger** split
  ([[adr-022]], [[adr-023]]) cannot exist within one sandbox session.
- **No working GitHub write path from the sandbox today** — `git push` `403`s, and REST-as-bot fails
  the same way once the proxy overwrites the token.
- The [[work-093]] hardening (REST authoring, runtime installation-id derivation) is **correct code
  that the sandbox will not let run as a distinct identity**. Its end-to-end acceptance is void here.

**This ticket is a spike, not a build** — the write path must be re-architected before more code.
Convene the [[cto]] and [[chief-reality-officer]]. Evaluate at least:

1. **Propose-only cloud routine (leading candidate).** Grant the sandbox's own GitHub App identity
   **write** on `scope-creep` + `scope-creep-console`; the routine opens PRs **as that identity**;
   **review + merge stay local/human as `@scope-creep-review`**, where identities resolve and the
   code-owner gate holds. Check: does the proxy identity, with write, actually let REST `POST
   /pulls` succeed? Does branch protection still hold the PR for `scope-creep-review` (the proxy
   identity is **not** a code owner, so it should)? What is the blast radius of granting that App
   write (it can open PRs and push branches, but **cannot merge** without the code-owner review)?
2. **Alternate execution surface** — run the writing step somewhere the proxy does not rewrite auth
   (e.g. a self-hosted runner / GitHub Action the routine triggers), keeping claude.ai for intake +
   reasoning only. Cost, complexity, and whether it defeats the "no local session" goal.
3. **Async-through-the-app** — the Owner's stated direction: interactions move into the Console, and
   scheduled routines pick up queued work. Does that reduce the cloud routine's write need to
   *proposing* (which #1 already covers), letting merge stay human for now?

**Acceptance:** an ADR (or ADR update to [[adr-025]]) that picks a write-path architecture proven to
work under the sandbox proxy — with an actual sandbox test of the chosen path (a PR opened end-to-end
by the routine, review/merge boundary intact) — plus a corrected
`docs/runbook-work-sweep-cloud-routine.md` and the un-pausing criteria for the routine. Until then the
routine does not run unattended. See [[ledger-066-cloud-sandbox-proxy-identity-wall]],
[[prd-autonomous-execution-loop]], [[work-093]], [[work-088]], [[adr-023]].
