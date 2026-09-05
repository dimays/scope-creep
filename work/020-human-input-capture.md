---
id: work-020
title: Human-Input Log — v1b (terminal capture hook)
type: feature
status: done
priority: high
owner: cto
spec: prd-human-input-log
branch: work-020-input-capture
pr: https://github.com/dimays/scope-creep/pull/1
created: 2026-09-05
updated: 2026-09-05
---
**v1b** of the Human-Input Log ([[prd-human-input-log]], [[adr-010]]) — captures the
richest surface (the terminal / first-class Claude session). **Owner-gated core change.**

- A **`UserPromptSubmit` hook** in `.claude/settings.json` that appends one NDJSON line
  per Owner prompt to a new **`human-input/YYYY-MM.ndjson`** record set (with a redaction
  guard so a pasted secret never lands in git).
- The Console's Human-Input Log ([[work-012]]) unions `human-input/` in (via
  `SCOPE_CREEP_HOME`) so terminal inputs appear.
- A **one-time backfill** (`scripts/backfill-human-input.py`) reconstructs the Owner's
  *earlier* terminal inputs — back to the first ideation — from the Claude Code session
  transcript, so the log isn't blank before the hook was installed. Conservative
  (drops tool-results / task-notifications / interrupts / compaction summaries, unwraps
  slash-command args, redacts secrets), idempotent (de-dupes by ts+text), and tags each
  row `backfill: true`. The backfilled rows live in the same gitignored `human-input/`.
- **Consistency self-checks:** flag work/merges in a window with no preceding captured
  input (missed input / uninstalled hook) + dup ids.

**Owner-gated:** touches `.claude/` and adds a new core record set → ADR + `core-upgrade`
+ Owner approval; the loop may draft, never self-merge.

**Acceptance:** an Owner prompt in a hooked session becomes a `human-input/` line;
the Console log shows terminal inputs; Consistency flags gaps. See [[adr-010]].

**Done (2026-09-05):** Owner-gated PR dimays/scope-creep#1 — the `UserPromptSubmit`
hook (`.claude/hooks/log-human-input.{sh,py}`, redaction guard, `human-input/`
gitignored) + the one-time backfill (`scripts/backfill-human-input.py`). Companion
Console reader shipped in dimays/scope-creep-console#13 (`operator-session` events
unioned via `SCOPE_CREEP_HOME`). Backfill run recovered **31** genuine inputs back
to the first ideation (`2026-09-04T21:22:46Z`); verified rendering on `/work/inputs`.
A stdin-vs-heredoc bug and a UTC-parsing bug were caught in verification and fixed.

**Carved out → [[work-022]]:** the **Consistency self-checks** bullet above (flag
work/merges with no preceding captured input; dup ids) was *not* built here — it's
a distinct read-side check, split to work-022 for the level-setting round rather
than claimed as shipped.
