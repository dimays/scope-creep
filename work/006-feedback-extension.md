---
id: work-006
title: In-app feedback mechanism (Extension)
type: feature
status: done
priority: medium
owner: chief-product-officer
spec: prd-console-explore
branch: work-006-feedback-ext
pr: https://github.com/dimays/scope-creep-console/pull/2
created: 2026-09-04
updated: 2026-09-04
---
The right question at the right moment, in-app — seeded by the Explore feedback
hooks and generalized into a portable Extension. Answers append to the [[ledger]]
and feed the roadmap.

**Acceptance:** a reusable feedback prompt component; responses recorded; non-nagging
cadence owned by the CPO.

**Done (2026-09-04):** shipped `scope-creep-ext-feedback` (public, v0.1.0) — a
framework-agnostic **Shadow-DOM graft** (`mountFeedback`) themed by host tokens,
host-agnostic `onSubmit`, once-per-`contextKey`. Grafted onto the Console's Explore
(0.5.0, gated PR #2); a `feedback` table + `/feedback` action persist responses.
Verified end-to-end. Proves the portable-graft + style-isolation pattern ahead of the
flagship [[work-001]].
