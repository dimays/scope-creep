---
id: work-066
title: request-triage routine — sweep new requests, ticket them, write outcomes back
type: feature
status: proposed
priority: high
owner: chief-of-staff
spec: prd-request-loop
created: 2026-09-07
updated: 2026-09-07
---
Stand up the [[request-triage]] loop as a scheduled runner — the one net-new piece of
[[prd-request-loop]] and the thing that makes "submit and forget" real. Hourly, it sweeps
new Owner request threads, runs [[request-intake]] per thread, authors tickets, and writes
each outcome back into the thread.

Build:
- The runner: sweep new `kind = request` threads → triage → decide.
- **Auto-merge simple accepts** end-to-end under [[adr-022]] (Owner disposition Q3: from day
  one). A clean accept tracing to an existing spec goes ticket → PR → merge without a
  checkpoint; STOP-gate or new-scope outcomes are proposed and parked at `needs-you`.
- Write the outcome back via the wired writers ([[work-064]]), setting `working` while
  executing and `needs-you` only when the call is the Owner's.
- **Cloud registration is an Owner/CoS step post-merge** — this ticket ships the loop's
  behavior; the claude.ai Code Routine (its `trigger_id` + `cron` in
  `registry/routines.json`) is registered once it lands ([[adr-016]]).

Depends on [[work-064]] (write-back) and [[work-065]] (shared store). Cadence self-tuning is
[[work-067]].

**Acceptance:** a request submitted with no human at the keyboard is triaged within the
cadence window; a simple accept ships end-to-end (ticket → PR → merge) with the outcome
posted to the thread; a genuine judgment call parks at `needs-you` with a needs-input
message; nothing crosses a STOP gate autonomously. See [[prd-request-loop]],
[[request-triage]], [[request-intake]], [[adr-022]].
