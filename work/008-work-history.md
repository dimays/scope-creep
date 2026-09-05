---
id: work-008
title: Work History (condensed shipped-features log)
type: feature
status: active
priority: medium
owner: chief-product-officer
spec: prd-work-intake
branch: work-008-work-history
created: 2026-09-04
updated: 2026-09-04
---
A glanceable "what got built and in what order" section on the Work tab, derived from
done work items + the ledger, each linking to its Work ticket and (where known) its
GitHub PR. Add an optional `pr:` field to the work schema.

**Acceptance:** a History view on the Work tab, newest-first, with ticket + PR links;
the Owner can reconstruct the build story without the repo. See [[prd-work-intake]] §1.
