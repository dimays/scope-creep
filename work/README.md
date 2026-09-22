---
name: work-readme
description: The work-item system of record — schema and lifecycle. Backend-first per ADR-005; surfaced in the Console.
metadata:
  type: reference
  status: active
  version: 1.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-21
---

# Work items

The project-management system of record ([[adr-005]]). Where the [[ledger]] records
what *happened*, `work/` records what's *intended and in-flight*. Backend-first:
each item is a versioned markdown file; the Console surfaces them as a board.

## File & schema
One file per item: `work/NNN-slug.md`, flat frontmatter, markdown body for
description / acceptance / notes.

```
---
id: work-001            # stable id, matches NNN
title: Build the chatbot extension
type: feature           # feature | bug | debt | chore
status: proposed        # proposed | active | review | blocked | done | superseded | dropped
priority: high          # high | medium | low
owner: chief-designer   # an agent slug — the accountable executive
assignees: ada, vera    # optional: employee-agent slugs staffed to this item ([[adr-017]])
spec: prd-console-explore   # REQUIRED: a product/ PRD or ADR name (a [[link]] target)
branch:                 # optional: the working branch while active/blocked (resume aid)
pr:                     # optional: the GitHub PR URL that landed the ticket (Work History)
created: 2026-09-04
updated: 2026-09-04
---
Body: the problem, the **Acceptance:** signal (the Definition of Done), notes.
```

## Lifecycle
Governed by [[ticket-cycle]] ([[adr-006]]). The happy path is
`proposed → active → review → done`, with `blocked` as a side state and
`superseded`/`dropped` as terminal alternatives to `done`.

> **The board is a four-column kanban.** The lifecycle statuses map one-to-one onto
> the columns the Owner reads — the surface stays uniform because the columns *are*
> the states, not a second vocabulary layered over them.

| Board column | Status | Meaning |
|---|---|---|
| **To-do** | `proposed` | An accepted idea in the inbox; traces to a `spec`, not yet started. |
| **In-progress** | `active` | Being built on a one-purpose branch (WIP cap ≤2 per [[ticket-cycle]]). |
| **In-review** | `review` | Code-complete; a PR is open awaiting review/merge. |
| **Done** | `done` | Landed on `main`. |

**Side & terminal states (off the four columns).** `blocked` is a side state a
ticket can enter from `active` or `review` when a STOP/escalation gate fires
([[ticket-cycle]] STOP checklist, [[adr-022]]); `superseded`/`dropped` are terminal
retirements that stand in for `done`.

### The `review` state — the verify → review → land finish line
`review` makes the [[adr-022]] finish line (**verify → review → land**) an explicit,
countable board state instead of an invisible gap between "coding" and "merged".

- **Entry (`active → review`):** a ticket enters `review` the moment its work is
  **code-complete and a PR is open awaiting review/merge** — the Definition of Done
  is met (acceptance + green App-Contract `test`) and it is now in the hands of the
  reviewer ([[qa-tester]] → [[code-reviewer]] → [[git-manager]]), not the author.
  Set `pr:` when entering `review`.
- **Exit — three doors:**
  - `review → done` on **merge** (the land step). This is the only path to `done`.
  - `review → active` if review **sends it back** for rework (the PR is not merged).
  - `review → blocked` if an **escalation/STOP gate fires** during review (e.g. an
    [[adr-022]] hold that is genuinely the Owner's call).

**Mechanics.** Transitions are edits to `status` + `updated`, committed. **Never
`rm` a work file** — retire it via a terminal status + a reason in the body + a
[[ledger]] note ([[invariants]] §III). `spec` is required and every ticket must
trace to an existing spec — new scope is human-gated. Validated in CI by
`bun run work:check`. Adding `review` is backward-compatible: no existing ticket
uses it, so no migration is needed.

## Staffing (owner vs assignees)
`owner` is the **accountable executive** (a C-suite / functional agent). `assignees`
is the optional roster of **employee agents** that executive has spun up and
staffed to the item ([[adr-017]]). The org view in the Console derives who-is-staffed
-to-what from this field, so `assignees` slugs must resolve to real agents under
`agents/` or `agents/employees/` (validated by `work:check`).

## Notes
- Work items are **not** scanned by the Console's Explore/Docs (their `status`
  vocabulary differs from the doc manifest's). They live on the **Work** board.
- Creating/editing from the Console (write-back) is a later iteration; today items
  are authored as files by agents or the Owner.
