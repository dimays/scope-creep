---
id: work-112
title: ADR-016 clarification — deep-link launcher + resume-by-id are CLI-only (Owner-gated core)
type: chore
status: backlog
priority: medium
owner: chief-of-staff
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
Queued from the [[work-100]] Threads fix + the Owner's live acceptance run (2026-09-21). Record an
[[adr-016]] clarification capturing the empirically-confirmed deep-link reality. **[[adr-016]] is
Owner-gated core** ([[invariants]] §I.4) — this ticket is to land the clarification **with Owner
approval**, not to self-edit the standard.

## Proposed clarification text (for Owner approval)
> **ADR-016 clarification (2026-09-21, confirmed by the [[work-100]] fix + a live Owner run).**
> The "open in Claude" launcher deep link (`claude-cli://open?cwd=<abs>&q=<enc>`) and resuming a
> specific past session (`claude --resume <uuid>`) are **CLI-only** — provided by the standalone
> Claude Code CLI, not the Claude desktop app (which registers only the bare `claude:` scheme and
> supports no folder-aware deep links or resume-by-id). The earlier-assumed
> `claude://code/new?…&folder=…` was **fabricated** (no such handler/param — the cause of the
> Owner's "No folder"). Therefore: the launcher **seeds a NEW** Claude Code session; the Console
> **projects the transcript** from local session JSONL and offers the copyable `claude --resume`
> command once correlated; **there is no resume-by-id deep link**, and a resume affordance **must
> never fall back to opening a new session**. The seed prompt carries the
> `[scope-creep-thread:<id>]` marker at its tail, subject to the `q`-param's ~5,000-char cap. The
> **zero-automated-Claude-call** invariant is unchanged.

## Acceptance
The clarification is recorded in [[adr-016]] with Owner approval (core-upgrade path), keeping the
ratified decision intact and adding only the confirmed deep-link facts. See [[work-100]].
