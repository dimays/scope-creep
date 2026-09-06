---
id: work-011
title: App state clarity & polish (loading / in-progress / interrupted)
type: feature
status: done
priority: high
owner: chief-designer
spec: prd-console-explore
created: 2026-09-04
updated: 2026-09-06
---
The Owner should always know the state: submitted vs. waiting on the backend, an
agent (or set of agents) in progress, or **blocked** (e.g. token-limit reached).
Covers both immediate action responses and longer request/work-item progress.

- **Bug:** in Requests, an Owner reply doesn't change status or signal whose turn it
  is — the reply is recorded but nothing shows it's awaiting operator triage.
- Loading/pending states on every submit (disable the button, show progress).
- **"Agent in progress"** indicators for work-item / request progress.
- An **interrupted / token-limit banner** with the reset ETA + greyed-out controls,
  that clears when processing resumes.

**Acceptance:** every submit gives immediate feedback; in-progress work is visible; an
interruption shows a clear banner with a resume ETA. Chief Designer owns; CTO for the
agent-status backend.

**Roadmap note (2026-09-05):** the **Requests whose-turn bug** (first bullet) is
superseded by the [[prd-cos-threads]] lifecycle/turn model ([[work-029]]) — drop it from
here when Threads MVP lands. The rest (app-wide loading / in-progress / interrupted
banner) is **broader than Requests and stays** with this ticket. See
[[ledger-028-cos-threads-roadmap]].
