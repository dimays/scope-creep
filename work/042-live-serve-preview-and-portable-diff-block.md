---
id: work-042
title: Interactive live-serve preview (Vite HMR iframe) + portable diff-block in the work-013 shell
type: feature
status: proposed
priority: high
owner: cto
spec: prd-chatbot-extension
created: 2026-09-06
updated: 2026-09-06
---
The carved-out remainder of [[work-017]] (parts 1–2 landed via
`scope-creep-console` PR #28 — agent-generated proposals + an in-Console diff
render, all isolated behind [[adr-009]], merge still the [[work-016]] gated step).
Two cohesive pieces were deliberately deferred so the flagship slice stayed green
and non-broad; they belong together because both are about *where* the preview is
rendered.

## Scope

1. **Interactive live-serve preview (work-017 part 3 — the heavy one).** Serve the
   ADR-009 sandbox worktree as a state-preserving live preview (Vite HMR) on a
   dedicated preview port, and surface it (iframe) in chat next to the diff, so the
   Owner sees the *running* proposed app, not just the diff. Must stay inside the
   isolation guarantees: the preview server runs against the throwaway worktree,
   never the live checkout, and is torn down on decline/approve. Open questions to
   resolve in an ADR: process/port lifecycle and cleanup, HMR against a detached
   worktree, and how the iframe is sandboxed. **No new hosted infra / spend** — this
   is a local dev-server process, Owner-gated if anything about it deploys.

2. **Port the diff block into the portable [[work-013]] shell.** The Console renders
   the diff today via its own `app/lib/diff.ts` + a `DiffView`. Reconcile that into
   `@scope-creep/ext-chatbot` as a real diff/attachment on `ChatMessage`, so *any*
   host app that grafts the shell gets the diff block (the ticket's original "the
   work-013 shell gains a diff/attachment block"). Then wire the Console's live chat
   surface (the `chat`-kind thread) onto it and retire the Console-local renderer.
   This requires an ext-chatbot version bump + re-pin in the Console
   (`package.json`), which is why it wasn't done in the first slice (a shell change
   nothing consumes is dead code).

## Acceptance
- The Owner describes a change in chat → agent proposes edits → **diff *and* a live
  interactive preview** appear in chat, all isolated; the diff block is rendered by
  the portable shell, not Console-local code. Merge stays the [[work-016]] gated PR.
- Isolation re-proven (CRO gate): the preview server provably cannot reach the live
  app or other apps; worktree + preview process are cleaned up on decline/approve.

## Notes
- Build on the shipped foundation, don't rebuild it: `sandbox.server.ts`
  (`previewProposal`/`landProposal`), `propose.server.ts` (the tool loop), and the
  `/chat/propose|preview|land|decline` routes already exist.
- Respect all gates: no deploy, no spend on new infra, no auto-merge, no routing
  around [[adr-009]].
