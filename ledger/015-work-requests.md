---
name: ledger-015-work-requests
description: work-009 done — Work Requests v1 (request-intake inbox) shipped and demonstrated live.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# Ledger 015 — Work Requests v1 (work-009 done)

**Date:** 2026-09-04 · **Recorded by:** Chief of Staff

## Delivered ([[prd-work-intake]] §2, [[request-intake]] loop)
Console 0.7.0 (gated PR #4): a **Requests** section on the Work tab. Submit a request
→ it becomes a conversation thread with a status; `requests` + `request_messages`
tables persist it; triage responses are written back (operator-side in v1).

## Demonstrated live
Submitted "Dark/light theme toggle in the Console" through the UI, then triaged it as
the CoS: routed to the Chief Designer, CRO-verified the tokens carry a dark block,
recommended queuing it after the flagship, and set status `needs-info` awaiting the
Owner. The intake loop ran end to end.

## Open thread for the Owner
Request #1 (theme toggle) is `needs-info` — awaiting the Owner's call: prioritize now,
or queue after [[work-001]]?

## Next in sequence
`work-001` — the flagship chatbot extension (Work Requests v2 / live chat folds in).
