---
id: work-104
title: Threads design polish — resolve redundant flows, inconsistent spacing/style
type: chore
status: done
priority: medium
owner: chief-designer
spec: prd-cos-threads
pr: https://github.com/dimays/scope-creep-console/pull/72
created: 2026-09-21
updated: 2026-09-22
---
> **Done 2026-09-22 ([[board-hygiene]] status↔reality reconciliation).** The ResumePanel rebuild
> landed via [scope-creep-console#72](https://github.com/dimays/scope-creep-console/pull/72),
> merged to `main` 2026-09-21.

**Owner report (2026-09-21):** "the design is a little off — some weird redundant flows,
inconsistent spacing and style." Bring the Threads surface to the design system standard.

## Known redundancy hotspots (confirm in the qa pass)
`app/components/thread-launcher.tsx` `ResumePanel` stacks several overlapping affordances at once
— an auto-fire deep link, an "open the seeded session" link, a copyable CLI command, a "Resume in
Claude" block that itself branches into resume-command / "open the repo" / a second copyable
command. That is the "weird redundant flows" the Owner sees: multiple ways to do the same thing,
presented together. `thread.tsx` also renders several card variants (outcome / generated-request /
critical-update / needs-input / branch) whose spacing and badges should read as one system.

## Scope
- Collapse the launcher/resume flows to a single clear primary action per state (start vs. resume;
  see [[work-102]]) with secondary affordances demoted, not stacked.
- Uniform spacing/rhythm and status/motion tokens from the design system (`@scope-creep/design`);
  extract shared primitives where the console is re-implementing them inline.
- Consistent card styling across the thread timeline (badges, accents, padding).
- Keep it dark-mode-correct ([[work-045]]) and delightful.

## Coordination
Layer **on top of** the [[work-102]] behavior fix (same console branch) so the design reflects the
corrected start/resume split — don't polish flows that are about to change. [[chief-designer]]
owns; pairs with [[cto]] on the launcher markup.

## Acceptance
The Threads surface reads as one system: one clear action per state, uniform spacing/style,
design-system tokens/primitives, no redundant stacked flows. Reviewed against the design system
and re-verified in a running console by [[qa-tester]]. See [[work-100]], [[adr-016]].
