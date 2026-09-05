---
id: work-008
title: Work History (condensed shipped-features log)
type: feature
status: done
priority: medium
owner: chief-product-officer
spec: prd-work-intake
branch: work-008-work-history
pr: https://github.com/dimays/scope-creep-console/pull/3
created: 2026-09-04
updated: 2026-09-04
---
A glanceable "what got built and in what order" section on the Work tab, derived from
done work items + the ledger, each linking to its Work ticket and (where known) its
GitHub PR. Add an optional `pr:` field to the work schema.

**Acceptance:** a History view on the Work tab, newest-first, with ticket + PR links;
the Owner can reconstruct the build story without the repo. See [[prd-work-intake]] §1.

**Done (2026-09-04):** shipped in Console 0.6.0 (gated PR #3) — Board/History sub-nav;
History lists done work newest-first with ticket + PR links, from a new `pr:` field.
