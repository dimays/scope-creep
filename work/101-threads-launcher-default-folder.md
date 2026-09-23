---
id: work-101
title: Threads launcher opens "No folder" instead of scope-creep (default-folder defect)
type: bug
status: done
priority: high
owner: cto
spec: prd-cos-threads
pr: https://github.com/dimays/scope-creep-console/pull/72
created: 2026-09-21
updated: 2026-09-23
---
**Owner report (2026-09-21):** "open the thread in Claude" opens in **"No folder"** instead of
**`scope-creep`**, which the Owner prefers as the default.

## Suspected root cause (verify empirically — [[work-100]] qa pass)
The deep link is built in `app/lib/claude-sessions.ts`:
`buildDeepLink` emits `claude://code/new?q=…&folder=<encoded cwd>` where `cwd = controlPlaneHome()`
= `process.env.SCOPE_CREEP_HOME ?? join(process.cwd(), "..", "scope-creep")`. Two candidate
causes, to be distinguished by capturing the **actual generated URL** and observing what Claude
Desktop does with it:
1. **`folder` value wrong/empty** — in the deployed/dev Console `SCOPE_CREEP_HOME` may be unset
   or the `process.cwd()`-relative fallback resolves to a non-existent path, so Claude can't
   honor it and drops to "No folder."
2. **`folder` param not honored by the current `claude://code/new` scheme** — the param name or
   URL shape may differ from what today's Claude Desktop expects (the scheme was last verified
   2026-09-06; re-verify against current behavior). If so, the fix is the correct param/shape.

## Fix
The launcher must open the seeded session in the **`scope-creep` control-plane repo** by default,
as an absolute path Claude Desktop honors — no "No folder." Keep `SCOPE_CREEP_HOME` as the
override; ensure the default resolves to the real absolute control-plane path in every run mode
(dev + prod). ADR-016 invariant intact (URL launch only; zero Claude calls).

## Acceptance
Running the console and clicking "Open in Claude" (or inspecting the generated deep-link URL)
targets the `scope-creep` folder; Claude Desktop opens Claude Code **in that folder**, not "No
folder." Re-verified empirically by [[qa-tester]]. Owner acceptance check defined for the actual
OS-level open on the Owner's machine if it can't be proven in-repo. See [[work-100]], [[adr-016]].

> **[2026-09-23] board reconcile:** `active → done` — landed via [scope-creep-console#72](https://github.com/dimays/scope-creep-console/pull/72) (merged 2026-09-21). See [[ledger-074-board-reconciliation]].
