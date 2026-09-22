---
id: work-097
title: PM maturity — add the in-review lifecycle state and the board-hygiene cadence
type: feature
status: done
priority: high
owner: chief-product-officer
spec: adr-005
branch: cpo/pm-maturity-in-review-board-hygiene
pr: https://github.com/dimays/scope-creep/pull/96
created: 2026-09-21
updated: 2026-09-22
---
> **Done 2026-09-22 ([[board-hygiene]] status↔reality reconciliation).** PR #96 merged to
> `main` 2026-09-21, completing the `active → review → done` traversal this ticket dogfoods.

> **Artifacts staged in this PR (`cpo/pm-maturity-in-review-board-hygiene`); flips to `done`
> on Owner merge — do NOT mark done here.** This is the lifecycle+hygiene upgrade itself, and it
> **dogfoods the very state it introduces**: it is code-complete with a PR open awaiting
> review/merge — exactly the `review` entry condition — so it sits at `review` rather than
> `active`. Fittingly the **first ticket to traverse the new finish line**, it moves
> `active → review → done` as this escalation-class PR is reviewed and merged.

**User problem.** The board is a four-column kanban in the Owner's head (to-do → in-progress →
in-review → done) but only three of those columns exist as states — there is **no explicit
in-review state**, so the [[adr-022]] *verify → review → land* finish line is an invisible gap
between "coding" and "merged", and nothing keeps the board honest on a cadence (the [[work-092]]
reconciliation was a one-off). The result: stale `status` labels that break [[work-sweep]]'s
ready-set and WIP-cap accounting, and no routine that prunes the backlog.

**Success signal.** The four Owner-facing columns map one-to-one onto lifecycle states
(`proposed`/`active`/`review`/`done`), a ticket with an open PR reads as **in-review** on the
board, and a dedicated propose-only routine exists to keep the board reconciled — all uniform
with the existing lexicon and loops.

**Staged in this PR:**
- **[[work-readme]]** — `review` added to the schema + lifecycle; the to-do→in-progress→
  in-review→done column mapping and the exact `review` entry/exit rule (enter when code-complete
  with a PR open; exit `→ done` on merge, `→ active` on rework, `→ blocked` on an escalation).
  Manifest bumped to `1.1.0`, `last_verified: 2026-09-21`.
- **`scripts/work-check.ts`** — `review` added to `ENUMS.status` (backward-compatible; no ticket
  used it, so all existing tickets still pass `bun run work:check`).
- **[[board-hygiene]]** — the new propose-only loop manifest (the board janitor / write-path
  canary); creation is itself tracked by [[work-098]].
- **[[work-sweep]]** — surgical edit so its "drive" step moves tickets `active → review → done`.
- Console render of the new column is [[work-099]] (different repo, periphery).

**Acceptance:** `bun run work:check` and `bun run registry:check` are green; the `review` state
is documented with a crisp entry/exit rule; the four-column mapping is uniform with the existing
status vocabulary. **Escalation-class** (touches `loops/` + the core work-item schema) — this PR
**holds for the Owner** and is not self-merged ([[adr-022]], [[invariants]] §III). See
[[adr-005]], [[work-readme]], [[board-hygiene]], [[work-sweep]].
