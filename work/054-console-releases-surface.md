---
id: work-054
title: Console Releases surface — project release notes newest-first with links to PRs/tickets
type: feature
status: done
priority: low
owner: chief-designer
spec: prd-console-operations
created: 2026-09-06
updated: 2026-09-06
---
Build the Console view for **Surface 2** of [[prd-console-operations]]: a **Releases** page
that projects release-notes artifacts read-only.

- Reverse-chronological (newest first) list of releases; each entry renders version, date,
  highlights, and **links out** to the landed tickets/PRs. Reuse the Docs-browser rendering +
  the cross-link/backlink machinery from [[work-039]] (no new authoring).
- v1 projects **local** artifacts only: the control-plane `releases/` set + the Console's own
  `CHANGELOG.md` (readable via `SCOPE_CREEP_HOME` / the app's own repo — no network, no Claude
  call). Cross-repo periphery-app release notes are a later slice (gated on the apps registry
  resolving each app's repo) — out of scope here.
- **Empty is empty**: no releases recorded yet → say so; never invent one.
- Feedback hook ([[prd-console-explore]] pattern): on a release, a light "Anything surprising
  here?" prompt appended to the [[ledger]].

**Depends on:** [[work-053]] (artifact shape + storage + a seeded `releases/` entry to project).

**Acceptance:** the Owner can read current + past releases in the Console and click through to
the PRs/tickets each landed; an empty state renders honestly. See [[prd-console-operations]].
