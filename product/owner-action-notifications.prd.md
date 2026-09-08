---
name: prd-owner-action-notifications
description: Owner-action items — the org's asks that only the Owner can do (activation steps, pending owner-apply docs, escalation PRs awaiting owner-approved, ledger/routine PRs to merge) — surface as a first-class, actionable notification type in the Console's notification center, distinct from informational thread notifications. Extends the request-loop notification surface (work-063); does not supersede it.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-07
---

# PRD — Owner-action notifications

> **Status:** `proposed` — Owner-requested 2026-09-07. Adds a **second class** of
> notification to the Console's just-shipped notification center ([[work-063]]): the
> org's **asks *of the Owner*** — the things **only the Owner can do**. **Extends
> [[prd-request-loop]] Pillar III; does not supersede it.** New scope is Owner-gated
> ([[invariants]] §I); the STOP gates are untouched.

## The user problem

**The org routinely produces work that only the Owner can finish — and today those asks have no home.** They surface *ad hoc* in a launched chat, buried in an artifact, or in a runbook doc the Owner has to remember to open. So the Owner has to go looking, and an ask can sit unactioned with nothing telling them it's theirs. The notification center ([[work-063]]) fixed exactly this problem for **threads** — but it only carries thread-level items. The Owner-only asks live **outside any single thread**.

Four kinds of Owner-only ask exist today, all unsurfaced:

1. **Activation steps** — provision the Turso instance, register the `request-triage` routine ([[prd-request-loop]] activation; the checklist lives in `docs/owner-apply-request-loop.md`). Spend + a claude.ai registry action, gated to the Owner by design ([[invariants]] §II–III).
2. **Pending owner-apply docs** — a `docs/owner-apply-*.md` describing a change to `.claude/**` (or other agent-gated surface) that an agent **cannot** make and the Owner must apply by hand (e.g. the activity-write-path convergence, `docs/owner-apply-activity-write-path.md`, and its `work-077`/`078`/`079`/`080` chain). "Pending" until the Owner applies it.
3. **Escalation PRs awaiting the `owner-approved` marker** — a PR held for the Owner because an [[adr-022]] escalation trigger fired (cost, security, core/gate change). It sits open until the Owner approves.
4. **Routine records / ledger PRs to merge** — `ledger-*` proposal PRs and routine-record follow-ups that wait on the Owner.

> **The crux:** these are **tasks the Owner performs in the world** (spend, apply a file, mark a PR approved, click merge), not messages to read. A thread notification is resolved by **reading**; an Owner-action notification is resolved by **doing**. The completion signal is external to any thread — which is why they need their own type, not a thread row.

## The experience

Each move is in the Owner's terms and maps to a problem above. Human-facing register ([[doc-standards]] §4).

- **One plate for "only you can do this."** The Owner opens the app and the notification center shows, above or beside the thread items, a distinct **Action needed** section: the activation steps, the pending owner-apply docs, the escalation PRs, the PRs to merge — each an item they can act on, newest/most-urgent first.
- **Every action says what, why, and how.** A row states **the action** ("Provision the console's Turso instance"), **why** it's theirs (the driving PRD/ADR/invariant, e.g. "§III spend — activates [[adr-024]]"), and **a link or the instructions** to do it (deep-link to the `owner-apply` doc or the PR; or the inline checklist).
- **Mark it done, or set it aside.** When the Owner has done the action in the world, they can **mark it done** (or it clears itself once the underlying state changes — the doc is applied, the PR merges); and they can **dismiss / snooze** an item that isn't for now, so the plate reflects reality instead of nagging.
- **It never fabricates an ask.** If there is no genuine Owner-action item, the section is honestly empty — the same honest-empty discipline as the activity feed and the thread notifications.

## What an Owner-action notification must show

> The one row schema the surface renders and the source layer must populate. This is the load-bearing contract of the feature.

| Field | What it carries | Example |
|---|---|---|
| **Action** | The imperative — what the Owner must do | "Register the `request-triage` cloud routine" |
| **Why** | The driving decision + the reason it's Owner-only | "Activates [[work-066]]; claude.ai registry action ([[adr-016]]), Owner-only" |
| **Link / instructions** | A deep link to the doc/PR, or the inline steps | → `docs/owner-apply-request-loop.md`, step 2 |
| **Kind** | Which of the four classes (drives grouping/urgency) | `activation` \| `owner-apply` \| `escalation-pr` \| `merge-pr` |
| **Source ref** | The addressable thing it derives from (for done-detection) | the owner-apply file path; the PR number + label state |
| **Done / dismiss** | The completion affordance (see below) | mark done · dismiss · (auto-clears on state change) |

## Distinct from informational thread notifications

> **This is a new *type*, not a new *row* on the existing feed.** Keep the two legible as different things.

| | Thread notification ([[work-063]]) | **Owner-action notification (this PRD)** |
|---|---|---|
| **What it is** | The org replied / parked a **thread** on the Owner | An org **ask of the Owner** that lives outside any thread |
| **Resolved by** | **Reading** — opening the thread clears unread | **Doing** — spend, apply a file, approve/merge a PR |
| **Source** | Threads + notable messages (`needs-input` / `critical-update`) | Filesystem (`owner-apply-*`) + git/GitHub PR state + activation checklist |
| **Completion signal** | `lastReadAt ≥ lastOrgAt` (in-app, deterministic) | **External** to the app — the doc applied, the PR merged, the routine registered |
| **Affordance** | Link to thread | Link/instructions **+ mark-done/dismiss** |

The two share the **surface** ([[work-063]]'s notification center + nav badge) and should read as one place-to-look, but as **two sections** with different affordances. The existing `buildNotifications` pure builder ([[work-063]]) is the pattern to mirror, not to overload — Owner-action items get their **own** read-model and builder (see Scope).

## The hard question this PRD frames but does not answer

> **Where do Owner-action items come from as *data*?** This is a genuine architecture question with real tradeoffs — ticketed as a [[cto]] deep-dive ([[work-083]]), **not** solved here.

The candidate sources, and why none is free:

| Candidate source | Gives us | The catch |
|---|---|---|
| **`owner-apply-*.md` convention** | Activation steps + pending owner-apply docs | **No "pending vs applied" signal exists today** — a filename scan can't tell an applied doc from a waiting one. Needs a convention (see [[work-084]]). |
| **GitHub PR state** | Escalation PRs missing `owner-approved`; open `ledger-*` PRs | The Console reads **local files** today, not live GitHub. A PR read is a **new network read surface** (auth, rate, offline degradation). ADR-016 forbids automated **Claude** calls — a **read-only** GitHub read is *allowed*, but it's still a new dependency the CTO must shape. |
| **Owner-gated ticket / STOP states** | Work blocked on the Owner | Derivable from `work/` frontmatter + the guard-gates, but risks double-counting items already surfaced as PRs. |
| **Activation checklist (runbook/PRD)** | The provision/register steps | Prose in an `owner-apply` doc; needs a machine-readable shape to be a row, not free text. |

> **CPO recommendation to the deep-dive (a starting position, not a mandate):** a **hybrid, convention-first** model. (1) Make **owner-apply docs the primary source** via a lightweight **`status: pending | applied` frontmatter convention** ([[work-084]]) scanned deterministically from the filesystem the Console already reads read-only ([[doc-standards]] §1/§3 — convention over search); this is the cheapest, most invariant-aligned slice and covers kinds 1–2. (2) Treat **PR-derived items** (kinds 3–4) as a **read-only GitHub read**, clearly demarcated, respecting [[adr-016]]'s zero-Claude-call posture (a git/GitHub *state* read is fine; a Claude *call* to summarize is not) — the CTO owns whether that's `gh`/API-direct or a local projection, and its honest-degradation behavior. (3) Union the sources into **one pure `buildOwnerActions` read-model**, mirroring `buildNotifications`, so ordering/dedup/done-state are unit-testable in one place. **The CTO disposes; this is the frame.**

## Scope (this cycle)

The smallest slice that makes Owner-action items real and actionable, built on the existing surface. One row per ticket.

| Ticket | Intent | Owner | Gate class |
|---|---|---|---|
| [[work-083]] | **Source model & read-model deep-dive** (the hard question) — recommend where Owner-action items come from; decide the PR-read surface respecting [[adr-016]]; spec the pure `buildOwnerActions` union builder | [[cto]] | Escalation — proposed ADR / decision that may add a `standards/` convention ([[adr-022]] trigger d) |
| [[work-084]] | **Owner-apply `pending \| applied` convention + backfill** — frontmatter on `docs/owner-apply-*.md` + a documented convention so "pending" is deterministic, not git archaeology | [[chief-knowledge-manager]] | Escalation — touches core `docs/` + a `standards/` convention |
| [[work-085]] | **Notification-center extension: Owner-action items as a first-class, actionable type** — render the row schema (action/why/link) with mark-done/dismiss, as a distinct section on [[work-063]]'s surface | [[chief-designer]] | Agent-buildable — Console + `@scope-creep/design` periphery |

**Dependencies.** All three depend on the shipped surface ([[work-063]]) and must **not** duplicate it — [[work-085]] extends the notification center, it does not rebuild it. [[work-085]] depends on [[work-083]] (the read-model shape) and [[work-084]] (the owner-apply source). [[work-083]] and [[work-084]] can proceed in parallel; [[work-083]] frames the convention [[work-084]] implements, so a light sync between them is expected.

## Non-goals (this cycle)

- **No new STOP-gate surface, and no acting for the Owner.** The app **surfaces** the ask and links to it; it never spends, applies a file to `.claude/**`, applies `owner-approved`, or merges — those stay the Owner's ([[invariants]] §II–III, [[adr-022]]). A "mark done" is a **display** state, never an action in the world.
- **No automated Claude call.** Item text is projected from existing docs/PR state, never summarized by a Claude call from the app ([[adr-016]]).
- **No multi-user, roles, or tenancy** — the singleton posture is absolute ([[invariants]] §II). "The Owner's plate" is one human's plate.
- **No write-back to git/GitHub from the Console** — the PR-derived sources are **read-only**; the Console never mutates PR labels or files.
- **No new scope without an Owner-gated ticket** — the four kinds above are the boundary this cycle.

## Success

The Owner opens the Console and sees, in one place, every ask only they can finish — each stating what to do, why it's theirs, and where to do it — acts on it or sets it aside, and the item clears when the underlying state changes. **Observable signal:** an activation step, a pending owner-apply doc, an escalation PR, and a ledger PR each appear as an actionable row with a working link the moment they exist, and disappear once resolved — with the section honestly empty when nothing is on the Owner's plate.

---

Follows [[doc-standards]] (esp. §4 registers and §9 presentation). Living, supersede-not-destroy ([[doc-standards]] §5): sections are stamped and evolve in git + the [[ledger]] as the deep-dive resolves and tickets land.
