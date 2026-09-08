---
id: work-086
title: work-sweep routine — scheduled sweep of the work board, drive ready tickets to done
type: feature
status: proposed
priority: high
owner: chief-of-staff
spec: prd-autonomous-execution-loop
created: 2026-09-08
updated: 2026-09-08
---
Stand up the [[work-sweep]] loop as a scheduled runner — the one net-new piece of
[[prd-autonomous-execution-loop]] and the thing that makes "run the roadmap autonomously"
real. On a cadence, with nobody at the keyboard, it reads the work board, pulls ready tickets
in priority order, and drives them through [[dev-cycle]]/[[ticket-cycle]] continuously,
stopping only at an Owner **blocker** or a defined **milestone**. The execution-side mirror of
[[work-066]] (which did this for request threads).

Build:
- The runner: wake → read the board → compute the ready set (WIP cap ≤2 per [[ticket-cycle]])
  → pick the top ready ticket → run STOP + [[adr-022]] escalation checklists → drive through
  **verify → review → land** ([[qa-tester]] → [[code-reviewer]] → [[git-manager]]) → loop.
- **Continuous within a run:** ticket after ticket to terminal; routine periphery work merges
  under [[adr-022]] on independent review, an escalation trigger holds for the Owner.
- **Stop only at blocker or milestone** ([[prd-autonomous-execution-loop]] stop rule; the
  milestone rule + cadence self-tune are [[work-087]]). A blocker flips `blocked` + resume
  ledger entry; a milestone stops the sweep and does not auto-start the next body of work.
- **Write the outcome back** via the wired writers ([[work-064]]), setting `working` while
  executing and `needs-you` at a blocker/milestone. Record consequential outcomes in the
  [[ledger]].
- **Cloud registration is an Owner/CoS step post-merge** and gated on the prerequisites —
  especially [[work-088]] (GitHub write access; the routine has read-only today and `403`s on
  push). This ticket ships the loop's behavior; the claude.ai Code Routine (`trigger_id` +
  `cron` in `registry/routines.json`) is registered once it lands ([[adr-016]]).

Reuse the Request Loop substrate — the shared thread store ([[adr-024]]) and write-back
writers ([[work-064]]) — do not rebuild it. Depends on [[work-088]] (write access) to
activate and [[work-087]] (milestone + cadence governance).

**Gate class — escalation.** Creating a new core loop is an Owner-gated core-upgrade
([[adr-021]]); this ticket's landing holds for the Owner and is not self-merged.

**Acceptance:** a ready ticket with no human at the keyboard is picked up within the cadence
window and driven to `done` (ticket → PR → merge on independent review) with the outcome
posted to its thread; the sweep runs multiple tickets in one run without pausing between them;
it stops and parks at `needs-you` on a blocker (a STOP/escalation gate) and on a milestone,
and nowhere else; nothing crosses a STOP gate autonomously. See
[[prd-autonomous-execution-loop]], [[work-sweep]], [[dev-cycle]], [[ticket-cycle]], [[adr-022]].
