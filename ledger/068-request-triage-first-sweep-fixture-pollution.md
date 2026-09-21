---
name: ledger-068-request-triage-first-sweep-fixture-pollution
description: First observed request-triage sweep with a large result set (2026-09-21, hourly routine trig_01L1ZuWXmRE1quiLGP3mv9ni). Outcome — no triage decisions made, no tickets/write-backs issued against swept threads. All 200+ threads the sweep returned were identified as QA/test-fixture data (verbatim matches to the console's test suite) that leaked into the shared remote store, not genuine Owner requests. Filed work-097 (scope-creep PR #100) to root-cause the leak and queue cleanup; the cleanup itself (archive/delete) is Owner-gated and not performed here.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-21
---

# Ledger 068 — request-triage sweep finds fixture pollution, not real requests

**Date:** 2026-09-21 · **Trigger:** `request-triage` (`trig_01L1ZuWXmRE1quiLGP3mv9ni`, hourly) ·
**Outcome:** **No genuine new Owner requests triaged. No tickets or write-backs issued against
swept threads.** One bug ticket filed for the anomaly itself ([[work-097]], scope-creep PR #100,
staged — not merged).

## What happened

`npm run triage -- sweep` (per [[request-triage]] step 1, [[adr-025]]) returned 200+ threads
satisfying the sweep filter (`kind=request`, `initiator=owner`, non-archived, no org reply). None
were genuine Owner asks — every title and body matches, verbatim, a scenario in the console's own
test suite (`app/lib/triage.server.test.ts`, `app/lib/threads.server.test.ts`,
`app/lib/human-input.server.test.ts`): e.g. thread 47 ("Add a dark mode toggle" / "Please add dark
mode.") is `triage.server.test.ts`'s first test case, verified directly against the live thread
store. A cluster of six threads shares the fixture timestamp `1700000000000`.

`vitest.config.ts` correctly scopes test runs to `DATABASE_URL=":memory:"`, so this did not come
from an ordinary `npm test`/`bun test` run — most likely a verification/QA step for [[work-066]]
(or similar) exercised the test helpers (`createThread`, `writeBackOutcome`) directly against the
ambient remote `DATABASE_URL`/`DATABASE_AUTH_TOKEN` rather than through the vitest harness.

## What the loop did right

- **Did not fabricate 200 triage decisions.** Recognizing fixture data is not owner intent, the
  routine made zero decline/counter/accept/fold calls and posted zero write-back cards into the
  polluted threads — writing back into synthetic threads would have compounded the pollution.
- **Did not attempt cleanup itself.** Archiving/deleting the polluted rows is a delete action
  under [[invariants]] §7 / the STOP gates and requires the Owner at the moment of action; the
  runner has no archive/delete verb in `scripts/triage.ts` regardless.
- **Filed the finding as a ticket instead of staying silent** — [[work-097]] (scope-creep PR
  [#100](https://github.com/dimays/scope-creep/pull/100)), owned by the CTO, proposing root-cause
  + cleanup + a hardening check so a future leak degrades safely. Staged only; never merged by
  this run.

## Consequence if unaddressed

The hourly `request-triage` routine will keep re-sweeping and re-reasoning over these ~200 junk
threads every run until the store is cleaned up — wasting budget and risking a real Owner request
being buried in the noise. Flagged high priority in [[work-097]] for that reason.

See [[request-triage]], [[adr-024]], [[adr-025]], [[work-066]], [[work-097]].
