---
id: work-078
title: Spawn capture — record the parent→child edge, not just the child
type: feature
status: proposed
priority: high
owner: cto
spec: prd-org-activity-moments
created: 2026-09-07
updated: 2026-09-07
---
Moment 2 of [[prd-org-activity-moments]] — *"an agent kicks off other agents."* Today the
capture hook logs only the **child**: `actor = tool_input.subagent_type`, `type` hardcoded
`"spawn"`, **no parent field** (`.claude/hooks/log-activity.py:24-48`). So the parent→child
**edge** the Owner wants to see — *who* kicked off *whom* — is not in the data, and the
agent page's `activityForActor` filter reads backwards (it lists times an agent *was
spawned*, not what it did).

## What to change (capture side)
Emit the edge into the going-forward record (target shape in [[prd-org-activity-moments]]):
- `actor` = the **acting/delegating** agent (the parent).
- `target` = the **child** spun up (today's `subagent_type`).
- Keep `type:"spawn"` (or `"delegate"`); keep existing `summary`/`threadId`/`sessionId`.

## The CTO deep-dive (the real open question — do not hand-wave)
`log-activity.py:11-14` already admits the parent "isn't cleanly knowable from a `PreToolUse`
hook." Resolve it before writing the patch. Candidate signals to evaluate: the hook payload's
own session/agent identity, a `CLAUDE_*` env var identifying the running agent, the invoking
agent slug embedded by the harness, or correlating via `SubagentStop`. Pick the one that is
mechanically reliable across both the `Task` (CLI) and `Agent` (desktop) tools; if none is
reliable, degrade honestly (write `actor` as `"unknown"` rather than mislabel) — never infer.

## Gate class — Owner-applied
Touches `.claude/hooks/**`, on the locked gate-enforcement surface (`guard-writes.sh` +
`permissions.deny`), so it is **Owner-applied, not agent-merged** — same class as [[work-077]].
Deliverable is an **owner-apply doc** under `docs/` (patch + rationale, like
`docs/owner-apply-activity-write-path.md`), plus the [[work-081]] read-model change on the
agent-buildable side. No ADR reversal — [[adr-013]] §4 already reserved a richer event; this
fills the parent field it lacked. A [[ledger]] note records the core-hook change (INVARIANTS §8).

## Prerequisite
**[[work-077]] must land first** (matcher `Task|Agent` + write-path converge) — without it the
hook never fires in this harness, so there is nothing to enrich.

**Acceptance:** after the owner-apply patch, a real delegation from one agent to another
appends a line carrying **both** `actor` (parent) and `target` (child); the Console (via
[[work-081]]/[[work-082]]) renders "parent spun up child" with both linked; when the parent
can't be resolved the line says `unknown`, never a fabricated or mislabeled parent.
