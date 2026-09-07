---
name: dev-cycle
description: The primary development loop — the outer cohort loop that staffs a round of work, drives each employee's per-ticket build through the ticket-cycle inner loop, then interposes a code-review cycle (code-reviewer) and a documentation review (CKM) into the land step before git-manager merges and the cohort is retired. Event-driven, not scheduled.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
  mode: partially-autonomous
---

# Loop: dev-cycle

The **primary development loop** — how the org actually builds a round of work with a
cohort of employees. It is the **outer** loop that staffs, coordinates, reviews, and
retires; the [[ticket-cycle]] is the **inner** loop each staffed employee runs on its own
ticket. This loop does **not** re-specify per-ticket mechanics (branch, atomic commits,
Definition of Done, the STOP checklist, resumability) — those live in [[ticket-cycle]] and
are cited, never duplicated. What this loop adds on top of them is the **cohort**: standup
staffing, a shared **code-review cycle**, a shared **documentation review**, and a clean
teardown when every employee is done. Ratified by [[adr-021]].

## dev-cycle ⟷ ticket-cycle (the reconciliation)
[[ticket-cycle]] is "how Scope Creep works turn to turn" for **one** stream of work — a
single agent carrying a single ticket from pick → execute → gate → land. The dev-cycle
**wraps** it for a **cohort** of employees working a themed round in parallel:

- The dev-cycle **staffs** the cohort (standup) and each employee runs [[ticket-cycle]]
  through its **Execute** step, producing a pushed PR.
- The dev-cycle then **interposes** its review stages **into** [[ticket-cycle]] step 5
  ("Gate & land"): a green `test` gate is now **necessary but not sufficient** to land —
  the PR must also clear the **code-review cycle** (§ Stage 4) and **doc review**
  (§ Stage 5) first. git-manager then executes the merge — on **independent org review**
  for routine work ([[adr-022]], active), or under Owner approval when an escalation
  trigger fires — exactly as [[ticket-cycle]] step 5 already routes.
- The dev-cycle **tears the cohort down** (retire employees per [[staffing]]) once all
  its tickets reach a terminal state.

So: **ticket-cycle is unchanged as the per-ticket engine; the dev-cycle is the
multi-employee round that drives many of them and gates their landing on review.** Neither
subsumes the other; they compose. A single ad-hoc ticket with no cohort still runs bare
[[ticket-cycle]] — the dev-cycle is for a *round* of staffed work.

## When this loop fires (event-driven — not scheduled)
The dev-cycle is **event/ticket-driven**, never cron. It fires when there is a **round of
work to staff**:
- an accepted batch out of [[request-intake]] (the Owner asked for a body of work);
- a **track chosen** in [[level-set]], [[staffing-review]], or [[roadmap]] that opens
  several tickets at once;
- the Owner (or CEO) kicks off a themed work round directly.

A lone ticket that needs no cohort does not require this loop. There is **no routine to
schedule** for it.

## Inputs (typed)
- `round` (string) — the theme/brief for this cohort (e.g. "the four themes, 2026-09-06").
- `tickets` (list of work ids) — the eligible `work/*.md` items this round covers.
- `direction` (optional) — the [[ceo]]'s priority framing, if this round carries one.

## Steps

### 1. Standup (CoS · CEO direction · CRO)
Evaluate the state of play: in-flight work, the backlog, open [[request-intake]] threads,
the round's `tickets`, and recent discussions/ledger. Then **staff the cohort** per
[[staffing]]: summon employees from templates (or reuse warm ones), set `reports_to` +
`template`, and assign them via each ticket's `assignees` — a gated change (propose →
worktree → PR, [[adr-017]] §E), ratified by the [[chief-of-staff]] ([[adr-002]]). The
[[ceo]] sets the round's priority/center-of-gravity; the [[chief-reality-officer]]
**re-checks the assumptions and dev plans** before build starts — the single assumption
most likely to break the plan gets verified first ([[adr-007]]). Apply [[resource-budget]]
spawn discipline: stagger spawns, mix model tiers across the cohort, cap concurrent
Opus-tier seats. Output: a staffed cohort + the round's active tickets.

### 2. Development (employee agents)
Each staffed employee carries its ticket(s) through the [[ticket-cycle]] inner loop —
one-purpose branch, atomic commits, **Definition of Done** = acceptance met + green
App-Contract `test` + honest tests ([[engineering-policy]] §6) + PR links the `spec`. The
dev-cycle does not restate these; it holds the cohort's shared context and unblocks
cross-ticket dependencies.

### 3. PR composition & push (employee / git-manager)
Compose **focused** PRs — one PR, one purpose ([[engineering-policy]] §3), intent + risk +
how-verified stated, spec linked. Push. **Not merged yet** — landing waits on Stages 4–6.
Stacked PRs are based correctly (parent-first) by the [[git-manager]].

### 4. Code review (the [[code-reviewer]] cycle)
The new **[[code-reviewer]]** standing function orchestrates a **review → QA →
pressure-test → debug** cycle on the pushed diff, delegating the pieces rather than doing
them all itself:
- reads the diff against the **CTO-set standards** ([[engineering-policy]],
  [[tech-sops]], [[app-contract]], [[golden-path]]) — correctness, honest tests,
  one-purpose scope, reuse/simplification, debt flagged not smuggled, security-in-passing;
- routes **"prove it green/works"** to the [[qa-tester]] (empirical run + artifact);
- routes **fixes/debugging** back to the authoring employee (or a fresh one);
- **iterates until standards are met and gates are green**, bounded by a review budget so
  it terminates; on budget exhaustion it escalates to the [[cto]] / [[chief-of-staff]]
  rather than lowering the bar.

When the diff meets standards and is green, the [[code-reviewer]] applies the **escalation
checklist** ([[adr-022]] §2) before hand-off — **(a)** financial burden/spend, **(b)**
security risk, **(c)** substantial tradeoff / C-suite concern, **(d)** a change to the safety
rails or the core. All-clear → routine → hand to [[git-manager]] to land on independent
review. Any trigger → **HOLD for the Owner** (route to Stage 6's Owner-gated path). The
Code Reviewer never merges, waives a red gate, or ships (see its agent file).

### 5. Documentation review ([[chief-knowledge-manager]] or its employees)
Before land, the [[chief-knowledge-manager]] (or a summoned [[technical-writer]] /
[[knowledge-engineer]]) confirms the doc surface is honest: manifests + `last_verified`
current, cross-links resolve, the registry regenerates clean, the changelog/ADR updated
where the change warrants, and `docs:lint` is green ([[doc-standards]]). A doc that can
drift silently is a bug — this stage is the guard.

### 6. Land (the [[git-manager]])
Once Stages 4–5 pass and CI is green + mergeable, the [[git-manager]] executes the merge —
**parent-first for stacks; children retargeted; merged branches cleaned up** — and the ticket
flips to `done` with a [[ledger]] completion entry (per [[ticket-cycle]] step 5). **Which gate
applies is set by the escalation checklist ([[adr-022]]):**
- **Routine PR (checklist all-clear):** lands on **independent org review** — green CI + the
  [[code-reviewer]] cycle + [[qa-tester]] proof, author ≠ merger. **No Owner approval
  required** ([[adr-022]] §1). This is the new default for periphery / non-core work.
- **Escalated PR (any trigger fired):** **held for the Owner** and merged only on the Owner's
  explicit approval ([[adr-014]] rule) — financial burden, security, substantial C-suite
  tradeoff, or a safety-rail/core change. Core-touching PRs always take this path (§I.4).

[[adr-022]] is **active** (2026-09-06): routine PRs land on independent org review with **no
Owner approval**; only escalation triggers hold for the Owner. `deploy` / spend / `delete` /
publish are **out of scope** for this loop and stay Owner-gated at the moment of action
([[invariants]] §III.7), regardless of how code landed.

### 7. Close & cleanup (CoS)
When **all** cohort tickets reach a terminal state (`done | superseded | dropped | blocked`):
- **retire** each cohort employee — `status: retired` + a one-line reason, never `rm`'d
  ([[staffing]], [[invariants]] §III.10);
- hand any residual/`blocked` items back to the backlog for a future round;
- append a [[ledger]] entry: the round, the cohort + templates, tickets landed, the
  code-review verdicts, the doc-review result, and the retirements.

## Termination
Machine-checkable ([[invariants]] §IV.12): the loop halts at Stage 7 once **every** ticket
in `tickets` is in a terminal state **and** every cohort employee is `retired` **and** the
ledger entry is recorded. It never runs a cohort open-endedly — an employee whose ticket
`blocked`s is retired-or-reassigned at teardown, not left lingering (the drift
[[staffing-review]] exists to catch).

## Outputs (typed)
- `landed` (list of PR urls) · `tickets_done` (list of work ids) · `retirements` (list of
  employee slugs) · `ledger_entry` (id).

## Notes
- **`metadata.mode` = partially-autonomous:** standup / development / review / doc-review /
  close run unattended. Under [[adr-022]] a **routine** PR also **lands unattended** on
  independent review; the hard human gate is Stage 5's **escalation checklist** — a triggered
  PR (financial / security / substantial-tradeoff / safety-rail-or-core) **holds for the
  Owner** — plus any INVARIANTS §III action a ticket surfaces (which routes to
  [[ticket-cycle]]'s STOP checklist, not around it). [[adr-022]] is **active**, so Stage 6
  self-merges routine work on independent review and reserves Owner approval for escalations.
- This loop **builds**; it does not decide load-bearing questions on its own authority. A
  judgment fork inside a ticket routes to [[decision]]; a new-app round routes to
  [[new-app]]; a failing gate routes to [[heal]]. The dev-cycle composes them, it does not
  re-implement them.
