---
name: roadmap-001
description: The founding roadmap — the CEO's first board presentation to the Owner (2026-09-07). Opens with a State-of-the-Org statement, reviews the genesis arc (v0.1.0 → v0.2.0: the Threads reframe, the employee/CEO org, the self-tuning loop system, and autonomous merge with escalation), and sets five forward themes for the next horizon, each traced to real artifacts. Disposition pending the Owner.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: ceo
  last_verified: 2026-09-07
---

# Roadmap Presentation 001 — 2026-09-07

- **Date:** 2026-09-07
- **Horizon:** the next build cycle (~the coming weeks) — the forward window this round plans against.
- **Presented by:** [[ceo]] to the board (the Owner), per [[roadmap]] step 5.
- **Supersedes:** — (the first round).

## CEO statement — State of the Org

Chairman,

Three days ago Scope Creep was a well-built machine that did what it was told. Today it
is an **organization** — one that staffs itself, reviews its own work, schedules its own
cadences, and, as of this release, **merges its own routine code without waiting on your
keystroke** — while every hard line you drew still runs straight to you.

That last sentence is the whole story, so let me be precise about what it does and does
not mean, because the difference is the reason you can trust it. The org can now land
*routine periphery work* on **independent review** — a real author-≠-merger separation, a
code review to the CTO's standards, a QA proof that the thing actually runs, and a Git
Manager who executes and records it. What the org **cannot** do — mechanically, not on its
honor — is spend a dollar, deploy, delete, publish, or **touch its own gates** without
you. We tried to make the machine edit its own INVARIANTS this week under your explicit
authorization, and it **could not**: the rails we built stopped it at multiple layers, and
the sovereign amended the law by their own hand. An org whose safety rails hold *even when
the owner says "go ahead"* is an org you can actually step back from. That is the product.

We did this the honest way. When a billing shortcut turned out to violate Anthropic's
terms, we killed it mid-spike and reframed the whole Threads feature around a ToS-clean
projection + launcher ([[adr-016]]). When the autonomous-merge design looked safe on
paper, our own Chief Reality Officer found the catastrophic gap — an org that can merge a
change to its own gates has no gates — and we built five mechanical rails before flipping
it on ([[adr-022]], [[ledger-049-rails-060-061-activation-gate]]). Nothing here rests on goodwill.
Everything load-bearing has a runnable proof.

We are still small, and I will not pretend otherwise: the escalation marker is forgeable
under our shared GitHub identity until we provision a restricted one ([[adr-023]]); the
Console still under-shows what the org is doing to itself; and our first fully-autonomous
dev-cycle run has not happened yet. Those are the honest edges, and they are on the plan
below — not buried.

You asked us to start feeling like an org. We do. Here is where we are taking it.

— the CEO

## Since last round (genesis)

This is the first presentation, so "since last round" is **since genesis** — the three
input streams [[roadmap]] step 2 reviews, briefly:

- **Experiences tracked.** Your direction drove every turn: the Threads billing/ToS
  concern → the [[adr-016]] reframe; "make it feel like an org" → the CEO + employee
  model ([[adr-018]], [[adr-020]]); "I can't be hands-off if I'm approving PRs" → the
  autonomous-merge arc ([[adr-022]]); and the polish mandate ("details should go
  unnoticed unless they delight") → the Explore polish pass.
- **Releases landed.** [[release-001]] (v0.1.0, the org-establishment backfill) and, with
  this round, **[[release-002]] (v0.2.0 — Autonomous governance)**: the five activation
  rails, ADR-022 live, the honest-consistency + delight polish, and the version-sync fix.
- **How the roadmap held up.** There was no prior roadmap to hold up — this round
  establishes the baseline the next one measures against.

## Themes

Five themes for the next horizon. Each is owned by an executive, carries a short
narrative, and traces to real artifacts — a theme that traces to nothing is a guess, not a
plan ([[invariants]] §III.8).

### Theme 1: Finish the trust rails ([[cto]] · [[chief-reality-officer]])
Autonomous merge is live, but two edges remain before it is *fully* trustworthy. First,
the `owner-approved` escalation marker is a GitHub label that any agent can add under our
shared identity — so it stops the *accidental* escalation merge but not a *deliberate* one.
Provisioning a restricted agent identity that cannot self-approve closes this. Second, the
author-≠-merger guarantee has been *proven mechanically* but not yet *observed live*; the
first autonomous dev-cycle run must record distinct author/reviewer/merger slugs in the
ledger. This theme finishes what v0.2.0 started.

**Traces to:** [[adr-023]], [[adr-022]], [[work-061]],
[[ledger-049-rails-060-061-activation-gate]].

### Theme 2: A Console that shows the org to itself ([[chief-designer]] · [[chief-product-officer]])
The org now does a great deal the Owner cannot see: loops run on cadences, releases ship,
the CEO presents a roadmap, agents delegate. [[prd-console-operations]] makes all of it
legible — **Schedules** (cadence, next/last run, the self-tuning history and *why* it
breathed), **Releases** (this arc, newest-first, clicking through to the PRs), **Roadmap**
(this very deck, projected read-only), and **agent activity**. Read-only, honest,
zero Claude calls — the Console *shows*, it never fabricates.

**Traces to:** [[prd-console-operations]], [[work-052]], [[work-054]], [[work-056]],
[[work-037]], [[work-031]], [[work-048]], [[work-039]].

### Theme 3: The self-improving loop system, made visible and honest ([[chief-of-staff]])
The dev-cycle, roadmap, evolve, and staffing-review loops are ratified and (the scheduled
ones) automated with self-tuning cadences. The next step is operational maturity: the
loops manageable and viewable in the app (Theme 2's Schedules surface), the no-spend heal
path so a red gate opens a launcher instead of waiting on a human, and the evolve loop
genuinely re-evaluating our own procedures on its cadence.

**Traces to:** [[adr-021]], [[ledger-046-loops-scheduled]], [[work-004]] (no-spend
reframe), [[evolve]], [[staffing-review]].

### Theme 4: Delight as a standard, not a finishing coat ([[chief-designer]])
The polish pass proved the thesis: most of our "hundreds of consistency issues" were a
*measurement* bug, and the real work was making links live, timelines clickable, and empty
states honest. The design system (status/motion tokens, extracted primitives) is the
substrate; the mandate is that every new surface ships delightful, not retrofitted.

**Traces to:** [[work-041]], [[prd-console-explore]], the Explore polish pass
(console PRs #43–#44).

### Theme 5: Threads as the org's window into Claude ([[chief-product-officer]] · [[chief-knowledge-manager]])
Threads is a ToS-clean projection of local Claude sessions plus an "open in Claude"
launcher. It works; now it should become the *connective tissue* — link-out cards to the
PRs/docs/tickets/ledger a conversation touches, and inline agent-activity projected from
the ledger — so a thread is a real map of what the org did and why.

**Traces to:** [[adr-016]], [[work-046]], [[work-047]], [[work-048]], [[work-031]],
[[prd-cos-threads]].

## Disposition

_Pending the Owner_ ([[roadmap]] step 7 — **accepted** / **revised** / **deferred**).
Recorded here on the Owner's response; until then this round stands as presented.
