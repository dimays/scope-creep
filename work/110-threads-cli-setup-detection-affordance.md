---
id: work-110
title: Threads launcher — detect CLI-handler setup and present the right primary action
type: feature
status: backlog
priority: high
owner: cto
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
Queued from the Owner's **live, passing** acceptance run of the [[work-100]] Threads fix
(2026-09-21). The fix works, but the Owner had to first install the standalone Claude Code CLI
(`curl -fsSL https://claude.ai/install.sh | bash`, then run `claude` once to register the
`claude-cli:` handler) — the Claude **desktop app does NOT provide it**. So a desktop-app-only
user gets the copyable-command fallback and never one-click, with no in-product guidance about why
or how to fix it. Real Owner-experienced friction.

## Authoritative constraint (Claude Code official docs)
The deep-link launcher (`claude-cli://open?cwd=&q=`) and resume-by-id (`claude --resume <uuid>`)
are **CLI-only**. The desktop app supports no deep links and registers only the bare `claude:`
scheme — it cannot do folder-aware "open in Claude" or resume-by-id.

## Scope (do not over-build)
Build on the existing `verifyClaudeCliScheme` probe (already detects the `claude-cli:` handler):
- **Handler registered →** one-click auto-launch as the primary action (today's happy path).
- **Handler NOT registered →** a first-class "enable one-click" affordance: the exact install
  step (`curl -fsSL https://claude.ai/install.sh | bash`, then run `claude` once), plus the
  copyable command as the immediate path. Detect + branch cleanly; don't present one-click when it
  can't work.

## Acceptance
The launcher shows the correct primary action for the user's actual setup: one-click when the
handler is present; a clear, first-class install-or-copy experience when it isn't. Pairs with
[[work-111]]. See [[work-100]], [[adr-016]], [[prd-cos-threads]].
