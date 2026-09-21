---
id: work-093
title: Harden the work-sweep cloud routine — prompt + env + REST git path (first-run findings)
type: chore
status: proposed
priority: high
owner: cto
spec: prd-autonomous-execution-loop
created: 2026-09-21
updated: 2026-09-21
---
The first `work-sweep` run ([[ledger-062-work-sweep-first-run]]) proved the loop **safe** (it built
nothing, routed around no gate, diagnosed precisely, parked at `needs-you`) but surfaced concrete
reliability gaps. Fix them before the routine is trusted unattended.

**Owner-side env fixes (the hard blockers — not agent-buildable; done in the claude.ai `scope-creep-local` env):**
- **`GH_REVIEW_PAT`** currently authenticates as `dimays`, not `@scope-creep-review` — repaste the
  correct scope-creep-review classic PAT (the value in the Owner's local `~/.config/scope-creep/review-pat`).
- **`GH_APP_INSTALLATION_ID`** currently holds the App **client_id**, not the numeric installation
  ID — replace with the numeric ID from the App's `/installations/<N>` URL. (The JWT/app auth
  works; only the installation-token mint fails.)

**Agent-buildable (this ticket):**
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
