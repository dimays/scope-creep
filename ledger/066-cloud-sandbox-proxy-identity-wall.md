---
name: ledger-066-cloud-sandbox-proxy-identity-wall
description: Definitive root-cause for the work-sweep cloud routine's write failures — the claude.ai cloud sandbox (CCR) egress proxy overrides the outbound Authorization header on api.github.com traffic and injects its OWN GitHub App identity, which resolves to `dimays` and is read-only. Proven 2026-09-21 by a read-only diagnostic run in which a valid PAT, an invalid garbage token, and NO auth header all returned the same `dimays` identity (HTTP 200). This invalidates ledger-062 findings #1 and #2 (which blamed GH_REVIEW_PAT and GH_APP_INSTALLATION_ID) and the runbook's distinct-identity REST write contract — a custom identity (scope-creep-review PAT, or the bot installation token) CANNOT authenticate through the sandbox, so author≠merger autonomous MERGE is not achievable in-sandbox as designed. Also records a self-caused security incident (the diagnostic leaked GH_APP_PRIVATE_KEY_B64 into its transcript → Owner must rotate the App private key) and the redesign queued as work-096.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-21
---

# Ledger 066 — the cloud-sandbox proxy identity wall (definitive root-cause)

**Date:** 2026-09-21 · **Supersedes the diagnosis in** [[ledger-062-work-sweep-first-run]]
(findings #1, #2) **and the write/review contract in** `docs/runbook-work-sweep-cloud-routine.md`.

## The claim we disproved
[[ledger-062-work-sweep-first-run]] read the first run's failures as **misconfiguration**: that
`GH_REVIEW_PAT` held a `dimays` token (finding #1) and `GH_APP_INSTALLATION_ID` held the wrong id
(finding #2). Acting on #1, the Owner re-verified the cloud `GH_REVIEW_PAT` **character-for-character**
against the local `~/.config/scope-creep/review-pat` and confirmed it is the classic PAT created
**as `scope-creep-review`** — the Owner's only `dimays` PAT is unused and scoped to an unrelated
project. The Owner was **right**: the token was never wrong.

## The definitive diagnostic
A **read-only** diagnostic routine (`trig_01RYGHaTTomCip4Rs3Vp7R9n`, run
`cse_01Kp16mmeBRKEsnXSLdToRRD`) made three `GET https://api.github.com/user` calls from inside the
sandbox:

| Request | Auth header sent | `.login` returned | Status |
| --- | --- | --- | --- |
| real PAT | `Bearer <scope-creep-review PAT>` | **`dimays`** | 200 |
| garbage | `Bearer not-a-real-token` | **`dimays`** | 200 |
| none | *(no Authorization header)* | **`dimays`** | 200 |

`rate_limit.core.limit = 15000` (a GitHub-App installation ceiling, not a user/PAT ceiling).
Sandbox env: `CCR_UPSTREAM_PROXY_ENABLED=1`, `HTTPS_PROXY=http://127.0.0.1:35225`.

**An invalid token and no token authenticate identically to a valid one.** That is only possible
if the sandbox's egress proxy **strips/overrides the outbound `Authorization` header** and
re-authenticates every `api.github.com` request as **its own GitHub App identity** (which resolves
to `dimays`, read-only). Whatever bearer token the routine sends is ignored.

## Why this is the whole wall (not a config knob)
- **No custom identity survives the proxy.** Neither the `@scope-creep-review` PAT (reviewer) nor a
  freshly-minted `scope-creep-routine[bot]` installation token can present itself to GitHub from the
  sandbox — the proxy overwrites both. So the **author≠merger** split the design depends on
  ([[adr-023]], [[adr-022]]) **cannot exist inside one sandbox session**: every call is the same
  proxy identity.
- **The proxy identity is read-only.** `git push` already `403`s (*"Claude doesn't have GitHub
  access"*), and REST writes as that identity would fail the same way. So there is currently **no
  working GitHub write path from the sandbox at all** — not `git push`, not REST-as-bot.
- **This invalidates the runbook's core.** `docs/runbook-work-sweep-cloud-routine.md` documents
  "author over REST as the bot, review+merge as `@scope-creep-review`." That contract **does not
  function** under the proxy. A banner now points readers here; do not follow it until [[work-096]]
  redesigns the write path.

## Security incident (self-caused, Owner action required)
The diagnostic prompt's redaction regex `s/(TOKEN|PAT|KEY|SECRET)=.*/\1=<redacted>/` **failed to
match `GH_APP_PRIVATE_KEY_B64`** (the `_B64` suffix sits between `KEY` and `=`), so the **full
GitHub App private key printed into the run transcript** on claude.ai. **The Owner must rotate the
`scope-creep-routine` App private key** (generate a new key, delete the old, replace
`GH_APP_PRIVATE_KEY_B64` in the `scope-creep-local` cloud env). Until rotated, treat the key as
exposed. Rotating makes the leaked copy useless. The diagnostic routine has been disabled.

## Implication — the design that IS reachable
Fully-autonomous **merge** from the cloud is not achievable under this proxy. The reachable posture
is **propose-only**: grant the sandbox's own GitHub App identity **write** on the repos so the
routine can open PRs (as that identity), and keep **review + merge local/human** as
`@scope-creep-review`, where identities resolve correctly and the `scope-creep-review` code-owner
gate ([[adr-023]]) still holds. That is a genuine redesign, not a patch — queued as [[work-096]]
for a CTO + [[chief-reality-officer]] pass. It also re-vindicates the propose-only posture the org
first weighed for the loop.

## Disposition
- [[work-096]] — redesign the cloud write path around the proxy (propose-only vs. alternate
  execution). **Blocker** for any unattended routine run.
- [[ledger-062-work-sweep-first-run]] — findings #1/#2 corrected by this ledger (token &
  installation-id were **not** the cause; the proxy is).
- The `work-sweep` routine stays **paused** in `registry/routines.json`; it must not run unattended
  until [[work-096]] lands. See [[prd-autonomous-execution-loop]], [[adr-025]].
