---
id: work-036
title: Delegation event capture (structured activity log + control-plane hook)
type: feature
status: proposed
priority: high
owner: cto
spec: prd-transparent-delegation
created: 2026-09-06
updated: 2026-09-06
---
The foundation under transparent delegation ([[prd-transparent-delegation]], [[adr-013]]).
Capture the C-suite's delegation/spawn **graph** as structured events so the Console can
project them — decisions stay sourced from the [[ledger]], never inferred.

- New append-only `activity/YYYY-MM.ndjson` record-set (mirrors `human-input/*.ndjson`).
  Event: `{ ts, id, actor, type: spawn|delegate|staff|confer, summary, threadId?, refUrl?, sessionId }`.
- Capture via a control-plane **`PreToolUse: Task` (and/or `SubagentStop`)** hook in
  `.claude/` — **not** `UserPromptSubmit` (which fires on Owner prompts, captures no spawns).
- **GATED:** touches `.claude/` + a core record-set → Owner-gated via [[core-upgrade]], and
  **blocked on the proof-of-hook spike** in [[adr-013]] (wire it, run one real delegation,
  confirm a line landed) before any sprint. Local + gitignored → empty on a fresh clone.

**Acceptance:** a real CoS→executive delegation appends a well-formed line to
`activity/*.ndjson`; capture is mechanical (a hook), not goodwill; no decision or rationale
is ever inferred. See [[adr-013]].
