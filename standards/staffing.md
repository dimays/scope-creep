---
name: staffing
description: How work gets staffed for consistent quality — the template→employee lifecycle (ephemeral employees, stable templates), when to summon vs reuse an employee, and the per-template/per-employee model presets tied to the resource-budget tiers. Owned by the Chief of Staff; kept healthy by the staffing loop.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Staffing standard

Owned by the [[chief-of-staff]] as a **standard** (the CoS drives *who & how* the org
staffs work; [[adr-018]]). Where [[decision-rights]] says *who is in the room for a
decision*, this says *how a body of work gets an agent on it* — consistently, at the right
quality, on the right model. It operationalizes the taxonomy fixed in [[adr-020]] and the
template/employee model of [[adr-017]], and pins model selection to [[resource-budget]] and
[[work-018]]. The [[staffing-review]] loop keeps it healthy on a cadence.

## 1. The four tiers (from [[adr-020]])
- **Executives** — the CEO + six C-suite ([[chief-of-staff]], [[cto]],
  [[chief-product-officer]], [[chief-designer]], [[chief-knowledge-manager]],
  [[chief-reality-officer]]). Permanent leadership; hold *direction* and domains.
- **Standing function agents** ([[qa-tester]], [[git-manager]]) — permanent, cross-org
  *functions* (`kind: function`); hold *execution*, not a domain. Not employees, not
  executives; they are not summoned per-ticket.
- **Employees** (`kind: employee`) — **ephemeral/transitory**. Instantiated from a
  template by an executive, staffed to specific tickets, and **dissolved** (retired) when
  the work is done. The default lifespan is "as long as the ticket(s)," not forever.
- **Templates** (`kind: template`) — the **stable-but-mutable catalog** of role
  archetypes each executive summons from. Templates are the *class*; employees are the
  *instance*. Templates persist and improve; employees come and go.

## 2. The template → employee lifecycle (employees are ephemeral)
1. **Summon.** An executive picks a template, names the employee, sets `reports_to`
   (itself) and `template`, and staffs it to one or more `work/` tickets via `assignees`
   ([[adr-017]] §C). This is a **gated change**: proposed → isolated worktree → PR, never a
   hand-edited registry, never an auto-merge ([[adr-017]] §E, [[adr-009]]).
2. **Work.** The employee inherits its template's operating manual and model preset (§4),
   carries its staffed tickets through the [[ticket-cycle]], and proposes behind the gates.
3. **Dissolve.** When the tickets land and no further work is queued, the employee is
   **retired** — `metadata.status: retired` plus a one-line reason, **never `rm`'d**
   ([[invariants]] §III.10, [[adr-017]] §A). Retirement is the norm, not an exception:
   an employee that lingers idle is drift the [[staffing-review]] loop flags.
   - `metadata.status ∈ active | idle | retired`. `idle` is a short holding state
     (summoned, awaiting staffing, or between tickets); a durably idle employee is a
     candidate for retirement or re-staffing.

The **template** is what persists across all this. When a role recurs, you don't keep the
old employee alive — you **summon a fresh employee from the same template**. Consistency
comes from the template, not from a long-lived worker.

## 3. Summon vs reuse (the decision)
- **Reuse** a currently-active employee when new work is the *same role, same reporting
  line, same in-flight context* and the employee is not overloaded — cheaper than a
  spin-up, and keeps context warm.
- **Summon** a fresh employee when the work is a **new role** (different template), a
  **different executive's** domain, or a **new initiative** where a clean context is
  worth more than warm context. Prefer summon-fresh over resurrecting a retired employee.
- **Create/modify a template** only when **no existing template fits** the role — a gated
  change ([[adr-017]] §E), because it reshapes the standing catalog every future summon
  draws on. Improving a template is encouraged (it is mutable); forking a near-duplicate is
  not (it fragments the shelf).
- **Don't summon an employee for standing-function work.** "Prove it" routes to
  [[qa-tester]]; "land it" routes to [[git-manager]]. Those are permanent functions, not
  per-ticket employees.

## 4. Model presets (per template, overridable per employee)
Every template declares a **`default_model`** — the tier an instance *starts* on. Read the
tier from [[resource-budget]] §1 and the catalog `reference/models.json` (the single source
of truth wired by [[work-018]]); **never hardcode a model ID** that isn't in the catalog.

| Tier | Catalog default | Template presets on this tier |
|---|---|---|
| **Routine / fast** | `defaults.routine` (Haiku) | [[program-coordinator]] — high-volume, low-risk coordination/bookkeeping |
| **Balanced / chat** | `defaults.chat` (Sonnet) | the engineering, design, research, writing, analysis, and verification templates ([[backend-engineer]], [[frontend-engineer]], [[platform-engineer]], [[integration-engineer]], [[design-systems-engineer]], [[product-designer]], [[technical-writer]], [[knowledge-engineer]], [[researcher]], [[product-analyst]], [[qa-verifier]], [[auditor]]) |
| **Expensive / agentic** | `defaults.agentic` (Opus) | **no template defaults here** — reserved for escalation (below) |

Rules, straight from [[resource-budget]]:
- **Default down, escalate up.** A template's `default_model` is the *cheapest tier that
  can plausibly do the role's typical work*. That is why the catalog is Haiku + Sonnet and
  **no template defaults to Opus** — reaching for the flagship by habit is the anti-pattern
  the budget standard was written to stop.
- **Escalate per employee, not per template.** When a *specific* ticket demonstrably needs
  the agentic tier — hard multi-step reasoning, core-touching code, a failed check that
  needs deeper analysis — override that **employee's** `default_model` on its instance
  manifest (a gated diff), leaving the template's default intact for every other instance.
  Engineering roles ([[backend-engineer]], [[platform-engineer]]) are the usual escalation
  candidates; a routine role rarely is.
- **Mix models across a fan-out** ([[resource-budget]] §2). When an executive staffs a
  batch for one effort, not every seat needs the same tier — reserve the expensive tier for
  the seats doing the hardest work and let the rest run cheaper.
- **A model-preset change is not a spend increase.** Choosing a tier within the existing
  catalog needs no gate; **adding a new paid model/provider or raising a quota is
  Owner-gated** ([[resource-budget]] §4, [[invariants]] §III.7).

## 5. Consistent quality
- **One role, one template.** Quality is encoded in the template's operating manual and
  preset; keeping the shelf small and sharp beats a sprawl of near-duplicates.
- **Every employee traces to a template and a ticket.** No orphan workers: `reports_to`
  and `template` are required on every employee, and `work:check` fails if an `assignee`
  doesn't resolve. Existence (the agent file) and assignment (the ticket) are the two
  facts; the join is derived, never denormalized ([[adr-017]]).
- **The standing functions guard the finish line.** [[qa-tester]] proves green/works and
  [[git-manager]] lands it — the quality gate on *every* employee's output, regardless of
  which executive summoned it.

## 6. This is an ongoing project
Staffing is not a one-time setup. The [[staffing-review]] loop runs on a cadence to keep the
tiers coherent, retire stale employees, prune/mend the template catalog, and true up model
presets against [[resource-budget]]. This standard is the *what*; that loop is the *how
often*.
