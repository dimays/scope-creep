---
id: work-019
title: "Dashboard: list Extensions + make Apps/Extensions entries clickable"
type: bug
status: done
priority: medium
owner: chief-designer
spec: prd-console-explore
branch: work-019-dashboard-links
pr: https://github.com/dimays/scope-creep-console/pull/11
created: 2026-09-05
updated: 2026-09-05
---
From Owner request #2 (via Work Requests → the request-intake loop). Two parts:
- **Bug:** the dashboard Extensions panel is hardcoded to "None installed yet" and
  ignores `registry.extensions` — the badge shows the count (2) but nothing lists.
- **Feature:** make Apps/Extensions entries clickable. They live in their own repos
  (unlike in-repo agents), so they link out to their `repo` (README = the doc);
  richer in-Console profiles are a possible follow-up.

**Acceptance:** the Extensions panel lists registered extensions; Apps + Extensions
entries are clickable, linking to their repo. See request #2.

**Done (2026-09-05):** shipped in Console 0.12.0 (gated PR #11). Extensions panel
renders `registry.extensions`; Apps/Extensions entries link out to their repo (with
an ↗). Verified on the dashboard. Request #2 closed.
