---
name: prd-console-operations
description: Console "Operations" — three projections that make the org's operating rhythm and its published outputs visible (and, where honestly possible, manageable) from inside the Console: the schedule/loop-management surface, generated release notes, and the CEO's roadmap presentations. Read-only projection + link-out over cloud routines that live in claude.ai (per ADR-016); never in-app control of those routines.
metadata:
  type: project
  status: active
  version: 0.2.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-07
---

# PRD — Console "Operations": Schedules, Release Notes & Roadmap

Owner-directed 2026-09-06 (chairman). Two asks, one theme. On schedules: *"these
schedules should be manageable/viewable on the app as well, please plan for that in the
product at some point."* On outputs: *"CEO roadmap presentations live in the console
somewhere, along with release notes (which we should also be generating and storing)."*

The common thread: the Console should be where the Owner sees the org's **operating
rhythm** (what runs, when, and how it's tuning itself) and its **published outputs** (what
the org shipped and where it's going) — without opening the repo or hunting across
claude.ai. This is the same **projection + link-out** posture the Console already takes
everywhere else ([[prd-console-explore]], [[prd-cos-threads]], [[adr-016]]): the app
*reflects* state it does not own, links out to the system of record, and never fabricates
activity or makes an automated Claude call.

> **Status: `active` — all three surfaces shipped (2026-09-06/07).** **Schedules**
> ([[work-052]], console #46), **Releases** ([[work-054]]) and **Roadmap** ([[work-056]])
> (console #45) are live read-only projections + link-out, exactly as specified. A fourth,
> adjacent surface — the org **Activity** feed ([[work-037]], console #49) — shipped
> alongside as the entity lens of transparent delegation. ADR-021's loop system is now
> ratified and the release-notes/roadmap artifacts exist ([[release-002]], [[roadmap-001]]);
> the remaining open thread is *automated* generation of those artifacts at each version-bump
> (still hand-seeded — see [[work-053]]). Nothing here touches loops/standards/adr/agents.

## The three surfaces at a glance

| # | Surface | User problem | What's projectable | What links out |
|---|---|---|---|---|
| 1 | **Schedules** | "What runs on a cadence, when's the next run, is it healthy, and how is it tuning itself?" | cadence + bounds, next/last run, recent outcomes, self-tuning cadence history — all from loop manifests + the [[ledger]] | enable/disable + "run now" for **cloud routines** → claude.ai (the app cannot drive them) |
| 2 | **Release notes** | "What did the org ship, per version, and where's the diff?" | per-version notes generated at release, stored as repo artifacts | the PRs/tickets each release landed |
| 3 | **Roadmap** | "Where are we going — show me the CEO's latest board deck and the history" | roadmap presentations stored as repo artifacts, projected like PRDs/ADRs | the PRDs/tickets/decisions each theme traces to |

---

## Surface 1 — Schedules / loop management

### The user problem
The org now runs work on cadences the Owner doesn't set by hand — most concretely the
**self-tuning [[staffing-review]] loop**, whose interval the Chief of Staff dials up/down
each run ([[ledger-043-staffing-cadence-self-tuning]]) and which is fired by an **automated
scheduled cloud routine** ([[ledger-044-staffing-loop-automated]]). Today the only way to
see "what's scheduled, when does it next run, is it healthy, how is the cadence moving" is
to read ledger markdown and remember a `trig_…` id buried in prose. As more loops become
cadence-driven, the Owner needs a single surface that answers those questions — and, where
it's genuinely possible, lets him manage the schedule.

### Goal & success signal
Give the Owner a first-class **Schedules** view. **Success:** from the Console the Owner can
answer *"what runs on a cadence, when does each next run, did the last runs do anything, and
how is the self-tuning cadence moving — and why?"* without opening the repo; and when he
wants to disable or hand-fire a scheduled routine, the Console takes him **one click** to the
place that can actually do it. We'll know it works by usage: the Schedules view gets visited
before the next staffing-review run, and the Owner catches a stuck/thrashing cadence here.

### Be honest about the architecture (verified)
There are **two different things** the word "schedule" covers, and they are managed
differently. The Console must not blur them:

**(a) Scheduled cloud routines — live in claude.ai, not in this repo.** The recurring runner
for staffing-review is a **scheduled cloud routine** (`trig_01D3wGKgqvTAwEV7Y5avk7tf`, cron
`0 14 * * 1`, model `claude-sonnet-5`), created and managed at
`https://claude.ai/code/routines/…` ([[ledger-044-staffing-loop-automated]]). It clones the
repo and opens PRs on a fixed weekly cron, then **self-gates** to the CoS-owned cadence:
each fire reads the latest `cadence-decision` block and runs the full review only when
`ran_at + next_cadence_days ≤ today`, else exits in seconds. So the *effective* cadence
lives in the ledger (7–42 days), while the cron stays fixed.

> **The hard limit (load-bearing).** Per [[adr-016]] the Console makes **zero automated
> Claude calls**, and driving a claude.ai routine programmatically via subscription auth is
> ToS-disallowed (the same finding that reframed [[prd-cos-threads]]). Therefore the Console
> **cannot itself enable/disable a cloud routine or "run it now."** It **projects** the
> routine's ledger-recorded activity and **links out** to claude.ai, where the Owner (or the
> operating session) performs those actions. We will **not** ship a button that pretends to
> control a cloud routine from the app. "Manage" = a deep link to the routine's claude.ai
> page; the honest floor is a generic "Manage in claude.ai" link plus enough on-screen
> context (cron, effective cadence, last/next) that the Owner acts confidently there.

**(b) Event-driven loops — documented rituals in `loops/`.** [[ticket-cycle]], [[decision]],
[[level-set]], [[heal]], [[new-app]], [[request-intake]] fire on **events/triggers inside a
session**, not on a wall clock. They are already projected by the **loops explorer**
([[work-039]], `/explore/loops`). They have no `trig_…` and no "next run"; some carry a
documented cadence in their manifest (e.g. level-set is cadence-triggered), but they are
*invoked in the harness*, not fired by cron. For these, "run now" means *start the ritual in
Claude* — a link-out to the harness with context, never an in-app trigger.

### What's genuinely projectable vs. what links out

**Projectable (read-only, from repo + ledger — no Claude call):**
- **Cadence & bounds** — from the loop manifest (`metadata.cadence`, `metadata.cadence_bounds`,
  `metadata.mode`). *Note:* these are not currently harvested into `registry/loops.json`
  (work-038 harvests only name/kind/status/description/owner_agent/path). Projecting them
  needs either a harvest extension or reading the manifest — see [[work-051]].
- **Last run / next run** — for a scheduled routine, derived from the ledger `cadence-decision`
  blocks: last run = the most recent `trigger: scheduled` entry's `ran_at`; **next (effective)
  run** = `ran_at + next_cadence_days`; **next cron check** = the next fire of the fixed cron.
  Show both, labelled honestly ("next cron check Mon 14:00; next *due* run 2026-09-20").
- **Recent outcomes** — the ledger entries a run produced and its terminal state
  (findings-ticketed vs. clean, and the ticket ids), linking to each.
- **Self-tuning cadence history** — the sequence of `cadence-decision` blocks across ledger
  entries rendered as a **lengthen / shorten / hold timeline** with each run's signals
  (empty-streak, ad-hoc-since-last) and the CoS's one-line `reason`. This is the highest-value,
  most Console-native piece: it makes the staff-driven cadence *legible* — the Owner sees the
  cadence breathing and why, exactly the transparency [[ledger-043-staffing-cadence-self-tuning]]
  set up.

**Links out (the app cannot do it honestly):**
- **Enable / disable / run-now a cloud routine** → `https://claude.ai/code/routines/{trig_id}`.
- **"Run" an event-driven loop** → the harness (Claude Code / Claude Desktop) with the loop's
  context, mirroring the [[prd-cos-threads]] "open in Claude" launcher pattern.

### v1 scope (smallest slice that teaches us)
Reuse the [[work-039]] loop explorer rather than build a parallel surface:
1. **Enrich the loop profile** (`/explore/loops/:name`) with a **"Schedule & cadence"**
   section: mode, cadence + bounds, last/next run, recent outcomes, and — where a
   `cadence-decision` history exists — the self-tuning timeline. Loops with no schedule say
   so plainly ("event-driven — fired in the harness, no cadence").
2. **A Schedules index** (`/explore/schedules`, plus a home panel) that lists the loops that
   *have* a schedule/cadence, each row showing cadence, last/next, and health at a glance —
   the "what runs when" answer in one screen.
3. **Manage/run link-outs** per the honesty rule above: cloud routines → claude.ai; event
   loops → the harness. Never an in-app control that claims to drive a cloud routine.

The **input** for scheduled-routine rows (which loop is backed by which `trig_…`, its cron,
its manage URL) is not in any registry today — it lives only as prose in
[[ledger-044-staffing-loop-automated]]. [[work-051]] creates that projectable record (the
"repo-side memory" ledger-044 asks for). Until it exists, the surface can still project the
cadence history from the ledger and event-driven loops from `loops/`.

---

## Surface 2 — Release notes

### The user problem
The org ships work continuously (gated PRs landing tickets), but there's no **per-release,
human-readable record** of "what changed and why" that the Owner can read in the Console. The
Console app already keeps a `CHANGELOG.md` and enforces version-sync ([[work-023]]) — so the
*mechanism* of versioned release notes exists for one app — but it's neither generated as a
first-class artifact by a loop nor surfaced in the Console, and the control plane has no
release-notes artifact at all. The Owner asked us to **generate, store, and show** them.

### Goal & success signal
**Success:** at each release/version-bump, a release-notes artifact is produced and stored in
the repo, and the Owner can read the current and past releases in the Console — "what shipped
in 0.16.0, which tickets/PRs it landed" — without reading git log. We'll know it works when
the Owner reaches for the Console's Releases view to answer "what changed recently."

### Artifact shape (proposed)
A release-notes entry is a **repo artifact**, one per version, stored where the release
happens:
- **Per-app:** the app's own `CHANGELOG.md` (the Console already has this) is the canonical
  per-app release note; each top entry = one version with date, highlights, and the tickets/PRs
  it landed. Keep it the source of truth (don't fork it).
- **Control-plane / org level:** a `releases/` set of artifacts (e.g. `releases/NNN-vX.Y.Z.md`)
  for org-wide releases and cross-app roll-ups, with a manifest (`name`, `description`,
  `metadata.type: reference`) so it lints and links like every other doc.
- **Fields (both):** version, date, a short "highlights" summary, the list of **landed
  tickets** (work-item ids) and **PRs** (URLs), and any ledger refs. These are the same joins
  the Console already makes — the artifact just names them per release.

### Where it's generated (dependency on ADR-021)
Release notes should be **generated at the moment of a version-bump**, not hand-written. The
natural producer is the loop/step that lands + versions work — a candidate is a **release
step in [[ticket-cycle]]** or a dedicated release step the CoS is defining in the loop-system
redesign (**ADR-021, in flight**). This PRD **specifies the artifact + the Console surface**;
it does **not** author the producing loop step — that is the CoS's call in ADR-021. Until the
generator exists, the Console projects whatever release artifacts already exist (the Console's
`CHANGELOG.md`), and we backfill.

### Console surface
A **Releases** view that projects release artifacts as readable, reverse-chronological entries
(newest first), each linking to its landed tickets/PRs. Reuse the Docs-browser rendering and
the existing cross-link/backlink machinery ([[work-039]]). v1 projects the **local** artifacts
(control-plane `releases/` + the Console's own `CHANGELOG.md`, both readable via
`SCOPE_CREEP_HOME` / the app's own repo, no network). Cross-repo periphery-app release notes
(reading each app's `CHANGELOG.md` from its own repo) is a later slice gated on the apps
registry resolving each app's repo — noted, not built in v1.

---

## Surface 3 — CEO roadmap presentations

### The user problem
The Owner (chairman) wants the **CEO's board presentations** — the roadmap decks from the
**Roadmap Planning Loop the CoS is designing in parallel** — to *"live in the console
somewhere."* Today the roadmap is scattered (the [[prd]] Roadmap section, ADRs, tickets); the
periodic board-facing *presentation* the CEO ([[ceo]]) gives has no artifact and no home in
the app.

### Goal & success signal
**Success:** each roadmap presentation is stored as a repo artifact and the Owner can open the
**latest deck plus the history** in the Console — "here's where the CEO says we're going, and
here's how that's changed" — as a first-class surface, not a doc he has to know to look for.
We'll know it works when the Owner opens the Console's Roadmap view to orient on direction.

### Artifact shape (proposed)
A roadmap presentation is a **repo artifact**, one per presentation, stored in the control
plane (proposed: `roadmap/NNN-YYYY-MM-DD-*.md`, mirroring the ledger's numbered-artifact
convention), each with a manifest so it lints/links like every doc:
- **Fields:** date, horizon (e.g. "next quarter"), the **themes** (the board-deck sections),
  and per theme a short narrative + the **artifacts it traces to** — PRDs, tickets, decisions,
  ledger entries. Markdown is the substrate (projected like a PRD/ADR); the "deck" is its
  section structure, not a binary slide file. If a richer visual deck is ever wanted, it's an
  additive later slice — the markdown artifact is the durable record.
- **Supersede-not-destroy** ([[doc-standards]]): a new presentation supersedes the prior one;
  history stays in the repo and the Console shows the trail.

### Where it's produced (dependency on ADR-021)
Roadmap presentations are produced by the **Roadmap Planning Loop** the CoS is designing
(**ADR-021, in flight**). This PRD specifies the **artifact shape + the Console surface**; the
**producing loop is the CoS's**. The dependency is explicit: the Console surface is built to
project the artifact shape below, and the loop that emits it lands via the CoS's design.

### Console surface
A **Roadmap** view that projects the latest presentation prominently with a history list
beneath, each theme's trace-links resolving to their PRDs/tickets/decisions via the existing
cross-link machinery ([[work-039]]). Read-only projection, exactly like the Docs browser.

---

## Cross-surface product decisions
- **Projection, never fabrication.** Every surface reflects artifacts/ledger the org already
  produced. If nothing exists yet (no cadence history, no release, no presentation), the
  surface says so honestly ("nothing recorded yet") — it never invents a run, a release, or a
  deck ([[invariants]] §III.8; the same honesty [[adr-016]] / [[prd-cos-threads]] require).
- **Link-out over false control.** Where the action genuinely can't happen in the app (drive a
  cloud routine, run a harness ritual), the Console links to where it can. We never ship a
  control that lies about what it does.
- **Reuse, don't fork.** Schedules enrich the existing loop explorer; Releases and Roadmap
  reuse the Docs-browser projection + cross-link/backlink machinery ([[work-039]]). Minimal,
  token-driven, built to grow ([[prd-console-explore]]).

## Metrics
Instrument which of the three views are visited and which link-outs are clicked (manage-in-
claude.ai, open-PR, open-ticket). These — not opinion — tell us whether each surface earns its
place and which becomes richer next ([[chief-product-officer]] metrics mandate).

## Feedback hooks
Carry the [[prd-console-explore]] pattern: a light, non-nagging prompt at natural moments — on
the cadence timeline, "Is this cadence about right?"; on a release, "Anything surprising
here?" — appended to the [[ledger]], feeding the roadmap. Seed of the feedback Extension.

## Dependencies & notes
- **ADR-021 (CoS, in flight)** — the loop-system redesign. Load-bearing for **which loop/step
  produces release notes and which loop produces roadmap presentations.** This PRD specs the
  artifacts + surfaces and is written to slot onto whatever ADR-021 lands; it does not author
  those loop steps. (Referenced as plain text, not a wiki-link, because the ADR is not yet in
  the repo.)
- **The Roadmap Planning Loop (CoS, in flight)** — produces Surface 3's artifacts; same
  posture as above.
- **[[work-051]] scheduled-routines record** — the projectable "repo-side memory" of cloud
  routines ([[ledger-044-staffing-loop-automated]]) that Surface 1's routine rows need.
- **Loop-manifest cadence fields aren't harvested** into `registry/loops.json` today
  ([[work-038]]); Surface 1 either extends the harvest or reads manifests — [[work-051]].
- **[[adr-016]] hard rule** — zero automated Claude calls — binds all three surfaces: they
  project and link out; they never drive claude.ai.
- Design stays minimal and token-driven ([[prd-console-explore]]); the Chief Designer owns the
  surface design, the CTO the projection plumbing, the CKM the harvested record.

## Out of scope (v1)
- **In-app control of cloud routines** (enable/disable/run-now inside the app) — ToS + the
  [[adr-016]] zero-Claude-call rule; link out instead, forever.
- **Authoring release notes or roadmap decks from the Console** — they're generated by loops
  and read by the Console; write-back is not this PRD.
- **Cross-repo periphery-app release notes** — v1 is local artifacts; multi-repo harvest waits
  on the apps registry resolving each app's repo.
- **A binary slide deck format** for roadmap presentations — markdown artifact first; visual
  decks are an additive later slice.
- **Auth/roles/tenancy — ever** ([[invariants]] §II). Single-user by construction.
