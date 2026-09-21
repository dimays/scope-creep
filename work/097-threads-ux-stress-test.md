---
id: work-097
title: Threads UX stress-test — polish the projection + launcher to design-system standard
type: epic
status: active
priority: high
owner: chief-of-staff
spec: prd-cos-threads
created: 2026-09-21
updated: 2026-09-21
---
The umbrella ticket for the Owner's 2026-09-21 Threads feedback (thread `scope-creep-thread:9`):
the Threads experience is "pretty buggy" and needs the org to "really stress-test the user
experience there and make it polished." Captured here so the report is durable in the work
board regardless of fix outcome — the Owner explicitly worried the feedback "isn't reflected
in the to-do work yet."

**Frame (load-bearing):** [[adr-016]] — Threads is a ToS-clean **projection** of local Claude
Code sessions + an **"open in Claude" launcher**. The app makes **ZERO** automated Claude
calls. Every defect below is a launcher / deep-link / projection-correlation / design defect —
**not** a missing Claude integration. Fixing any of them by adding a Claude API call is
prohibited (evaporates the ToS exemption).

## The Owner's four observed defects → child tickets
- [[work-098]] — **Wrong default folder.** "Open the thread in Claude" lands in **"No folder"**
  instead of `scope-creep` (the Owner's preferred default).
- [[work-099]] — **Launcher→existing-conversation link never works.** Opening a launched thread
  still **prompts to start a NEW conversation**; the Owner "still hasn't seen it successfully
  link to a conversation" — the resume-existing path has never worked end-to-end.
- [[work-100]] — **Reopen-ongoing-thread flow unverified.** The Owner wants confidence that
  reopening a conversation on an ongoing thread works; blocked from testing by work-099.
- [[work-101]] — **Design polish.** "Redundant flows, inconsistent spacing and style" — bring
  the surface to the [[design-system]] standard.

## Where the work lands
Threads lives in the **console repo** (`scope-creep-console`, sibling checkout — [[adr-025]]),
not this control plane. Fixes land there as periphery UX work via [[adr-022]] verify→review→land.
Running the app honors the node-22-on-PATH and prod-`.env` gotchas (see the console README /
org memory).

## Acceptance
All four child tickets resolved and **empirically re-verified by running the console**
([[qa-tester]]), landed on the console repo, with a clearly-defined Owner acceptance check for
anything that genuinely requires the Owner's own machine (the deep link firing into their
Claude Desktop and resuming). The Owner experiences the polished, working Threads as the
milestone. See [[adr-016]], [[prd-cos-threads]].
