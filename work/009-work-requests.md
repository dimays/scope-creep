---
id: work-009
title: Work Requests — request-intake loop (inbox v1)
type: feature
status: done
priority: high
owner: chief-product-officer
spec: prd-work-intake
branch: work-009-work-requests
pr: https://github.com/dimays/scope-creep-console/pull/4
created: 2026-09-04
updated: 2026-09-04
---
A place on the Work tab to submit a request and discuss it; the system may decline /
suggest alternatives / modify / route to an executive / ticket it / fold into the
roadmap. Its own **request-intake loop** feeding [[ticket-cycle]]; see/continue past
threads.

**v1 (inbox, buildable now):** submit box + request threads; a submission is recorded
and triaged asynchronously in the operator session, with the outcome (tickets /
decline / counter-proposal) written back to the thread. No in-app agent runtime.

**v2 (live chat):** the thread becomes a real-time agent conversation — shares the
**conversation primitive** with the flagship chatbot ([[work-001]]); folds into that
workstream.

**Acceptance (v1):** submit a request → it's recorded as a thread → triage outcome
recorded and visible; past threads listed. New scope stays human-gated.
See [[prd-work-intake]] §2.

**Done (2026-09-04):** shipped in Console 0.7.0 (gated PR #4) — Requests section
(Board/History/Requests); submit → conversation thread with a status;
`requests`/`request_messages` tables; the [[request-intake]] loop. Demonstrated
live: submitted a request and triaged it (routed + CRO-checked + decision +
status). v2 (live in-app chat) folds into [[work-001]].
