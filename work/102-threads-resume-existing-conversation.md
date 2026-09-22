---
id: work-102
title: Launcher→existing-conversation link never works — resume opens a NEW conversation
type: bug
status: done
priority: high
owner: cto
spec: prd-cos-threads
pr: https://github.com/dimays/scope-creep-console/pull/72
created: 2026-09-21
updated: 2026-09-22
---
> **Done 2026-09-22 ([[board-hygiene]] status↔reality reconciliation).** PR
> [scope-creep-console#72](https://github.com/dimays/scope-creep-console/pull/72) (resume slot
> shows only the correlated `claude --resume <uuid>`; auto-launch no longer re-fires once
> correlated) merged to `main` 2026-09-21.

**Owner report (2026-09-21):** opening a launched thread does **not** show the existing Claude
conversation — it still **prompts to start a NEW conversation**. The Owner "still hasn't seen it
successfully link to a conversation." This is the headline defect: the resume-existing path has
**never** worked end-to-end.

## Root-cause hypothesis (confirm in [[work-100]] qa/CTO pass)
Two distinct things are conflated in the Owner's symptom; both need resolving:

1. **The "Resume in Claude" control can spawn a NEW session.** In
   `app/components/thread-launcher.tsx` (`ResumePanel`), when a thread is launched but **not yet
   correlated** to a local session (`resumeCommand === null`), the scheme-registered branch
   offers `openRepoLink` = `claude://code/new?folder=…` — i.e. **a brand-new session**, not a
   resume. So "reopen the thread" literally opens a new conversation. A precise resume only ever
   appears as a copyable `claude --resume <uuid>` CLI command, and only **after** correlation.

2. **Correlation may never complete**, so the transcript stays empty and no precise resume is
   ever offered. Correlation (`claude-sessions.server.ts` `findSessionForThread`) matches a local
   JSONL whose first Owner message contains the `[scope-creep-thread:<id>]` marker. That marker
   only lands in the JSONL once the Owner **actually sends** the seeded prompt (the deep link
   pre-fills the composer but does not auto-send). If the folder defect ([[work-101]]) or an
   unsent seed means no correlated JSONL exists, the projection is `pending` forever → "waiting
   for the session to start" and a resume that opens `code/new`.

## The real question (verify against CURRENT Claude Desktop)
Is there a **deep-link scheme that resumes an existing Claude Code session by id** (e.g.
`claude://code/session/<uuid>` or equivalent) that fires from the browser? As of the 2026-09-06
ADR-016 write-up, resuming was **CLI-only** (`claude --resume`), which is why the UI degrades to a
copyable command. If a resume-by-id URL now exists, wiring it in (still zero Claude calls — just an
OS URL launch) is the clean fix. If not, the honest fix is: (a) never present `code/new` as
"resume"; (b) make the CLI `claude --resume <uuid>` the primary resume affordance once correlated;
(c) make correlation robust and visible so the Owner sees the thread link up.

## Fix (ADR-016-safe)
- Separate **"start"** from **"resume"** in the UI — a resume control must never open `code/new`.
- Wire a working resume-existing path (deep-link-by-id if it exists today; else the correlated
  `--resume` command as the clear primary, with the projected transcript as the in-app view of
  the past conversation).
- Make correlation reliable + observable (tie it to the corrected folder from [[work-101]]; show
  a clear "linked ✓ / waiting to link" state).
- **No Claude API call** may be introduced to "show" the conversation ([[adr-016]] hard rule).

## Acceptance
After launching a thread and sending the seed in Claude, reopening the thread shows the linked
conversation (projected transcript in-app) and a resume control that **reopens the existing
conversation**, never a new one. Empirically reproduced-then-fixed by [[qa-tester]]; Owner
acceptance check defined for the OS-level resume on the Owner's machine. See [[work-100]],
[[work-101]], [[work-103]], [[adr-016]].
