---
id: work-093
title: Harden the work-sweep cloud routine — prompt + env + REST git path (first-run findings)
type: chore
status: blocked
priority: high
owner: cto
spec: prd-autonomous-execution-loop
created: 2026-09-21
updated: 2026-09-21
---
> **Code landed via PR #91, but end-to-end acceptance is BLOCKED and superseded (2026-09-21).** The
> prompt/env/REST-path/installation-id-derivation changes merged and are correct code. But the
> acceptance criterion — *"author a PR as `scope-creep-routine[bot]`, review + merge as
> `@scope-creep-review`"* — is **not achievable in the cloud sandbox**: the egress proxy overrides
> the `Authorization` header and forces its own read-only identity for all `api.github.com` traffic
> ([[ledger-066-cloud-sandbox-proxy-identity-wall]]). The two "Owner-side env fixes" below
> (`GH_REVIEW_PAT`, installation id) were **misdiagnoses** — the token was always correct; the proxy
> is the cause. Superseded by the [[work-096]] write-path redesign; do not act on the credential
> instructions below.
The first `work-sweep` run ([[ledger-062-work-sweep-first-run]]) proved the loop **safe** (it built
nothing, routed around no gate, diagnosed precisely, parked at `needs-you`) but surfaced concrete
reliability gaps. Fix them before the routine is trusted unattended.

**Owner-side env fix (the one hard blocker; done in the claude.ai `scope-creep-local` env):**
- **`GH_REVIEW_PAT`** authenticates as `dimays`, not `@scope-creep-review` (confirmed by the run's
  `curl .../user`), while the Owner's local `~/.config/scope-creep/review-pat` correctly resolves to
  `scope-creep-review`. The cloud var must hold a token **owned by `scope-creep-review`** — repaste
  the value from that local file, or regenerate a classic PAT while logged in **as** `scope-creep-review`.

**Installation-ID — NOT an Owner fix (corrected):** `GH_APP_INSTALLATION_ID` holds the App
**client_id**. Per GitHub's JWT doc the client_id is a **valid JWT issuer** (recommended, even), so
app-auth works — but the installation access-token endpoint
(`POST /app/installations/{installation_id}/access_tokens`) needs the **installation ID**, a
distinct number. Rather than hardcode it, the runner should **derive** it from the JWT
(`GET /repos/dimays/scope-creep/installation` → `.id`, and likewise for the console repo). So drop
the reliance on a hardcoded `GH_APP_INSTALLATION_ID` — this is a code fix below, not an env change.

**Agent-buildable (this ticket):**
- **Derive the installation ID** at runtime from the JWT (`GET /repos/{owner}/{repo}/installation`),
  per repo — no hardcoded installation-ID env var. The JWT issuer may be the App ID or Client ID.
- **Correct the routine prompt** (registered on claude.ai; mirror the fixes into a repo copy /
  runbook so it's versioned): the CLI signature is `sweep [--floor …]` (no `<base> <head>`); install
  deps with **`bun install`** (the console ships `bun.lock`, so `npm ci` fails); set
  `SCOPE_CREEP_HOME=<scope-creep checkout>`.
- **Git write path:** the sandbox proxies `git push` through the read-only Claude GitHub App (403),
  but `api.github.com` REST is reachable. So the routine must author branches/commits/PRs via the
  **bot installation token against the REST API** (create refs/contents/pulls), not `git push` —
  document this as the cloud contract (mirrors how the Owner's local session authors PRs via the
  contents API).
- **Pre-provision `gh`** (or a setup script) in the routine env so it isn't downloaded every run.
- **Document the cloud-env credential contract** in `docs/owner-apply-github-write-access.md`:
  which var holds which identity, and how the bot (author) vs `@scope-creep-review` (reviewer/merger)
  split maps to the REST calls.

**Acceptance:** a `work-sweep` run in the fixed env mints the bot token, authors a PR **as
`scope-creep-routine[bot]`**, reviews + merges routine work **as `@scope-creep-review`**, and holds
escalation-class work for the Owner — end to end, no manual intervention. See
[[prd-autonomous-execution-loop]], [[work-088]], [[adr-025]], [[work-092]].
