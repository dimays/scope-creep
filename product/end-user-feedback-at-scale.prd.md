---
name: prd-end-user-feedback-at-scale
description: Prepares the org for the Owner's primary input mode at scale — high-volume, concurrent, multi-context, cross-app feedback. Characterizes the end-user, assesses where the Request Loop holds and where it breaks at scale, and phases the staff/work/knowledge scaling with concrete activation triggers so nothing is over-built early.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-07
---

# PRD — End-user feedback at scale

> **Status / one-line summary:** `proposed` — a forward-looking readiness plan, not a
> build order. The Owner's directive (2026-09-07): *"Let's build for this eventuality —
> up to you when and how we scale, but let's not be surprised by it."* **We build almost
> nothing now.** We frame the eventuality, ticket the deep-dives to the right executives,
> and gate each on a measurable **trigger**. **New scope stays Owner-gated** ([[invariants]] §I);
> the STOP gates are untouched. Extends [[prd-request-loop]]; does not supersede it.

## The user problem

**The Owner *is* a high-throughput feedback generator, and feedback is the suite's primary input mode — not an occasional side-channel.** By simply *using* the app suite the Owner produces requests faster than any serial, single-threaded triage can absorb them. Five failure modes emerge as the suite grows, none visible at one-app / low-volume:

1. **Volume** — many asks per active sitting; the hourly sweep's serial per-thread triage becomes a latency bottleneck.
2. **Concurrency** — many threads open at once (already true in `scope-creep-console`); triage decisions made thread-by-thread ignore the other open asks.
3. **Multi-context** — a single sitting interleaves unrelated asks across areas, sessions, and devices; no synthesis binds them.
4. **Cross-app** — once app #2 ships, feedback is *suite-wide*, but each app owns its **own** thread store ([[adr-024]]: one DB per system), so no view spans them.
5. **No self-curation** — the Owner submits-and-forgets ([[prd-request-loop]]); they will **not** dedupe, prioritize, or cross-reference their own asks. **That burden is the org's, by design.**

## The experience

What the Owner should feel as volume climbs — each move maps to a failure mode above:

- **Fire and forget, at any rate.** The Owner rattles off ten asks across three apps in one sitting and trusts every one is caught, sized, and slotted — the sweep keeps up because triage capacity flexes with the queue, not the clock alone.
- **Say it once, even if you say it thrice.** Three rephrasings of the same want — even across two apps — converge into **one** tracked item, not three duplicate tickets.
- **One plate, not N inboxes.** "What's on the Owner's plate" is a single suite-wide view ranked against one roadmap, however many apps are live — never a per-app hunt.
- **The org remembers across threads.** An agent triaging thread N knows about the related thread M and the feedback in app X, so context isn't re-litigated every time.

## Assessment — does the Request Loop cover this?

> **Verdict: the Request Loop's *plumbing* scales; its *triage intelligence* and *capacity* do not.** It was rightly designed for one app at moderate volume. Its trigger + write-back + notify + shared-store mechanics ([[work-063]]–[[work-068]]) are the correct foundation and need **no** rework. The gaps are (a) cross-thread / cross-app **synthesis** and (b) triage **throughput** — exactly the axes that only bite at scale.

| Dimension | Request Loop today ([[request-triage]] / [[request-intake]]) | Where it breaks at scale | Owner |
|---|---|---|---|
| **Trigger / write-back / notify** | Hourly self-tuning sweep, wired write-back, unread badge + digest | **Holds.** Cadence self-tunes ([[work-067]]); no change needed | — |
| **Dedup** | Per-thread triage; "a thread already answered is not re-triaged" | **No cross-thread dedup** — 3 rephrasings → 3 tickets; no clustering of related asks | [[chief-product-officer]] |
| **Cross-app context** | Reads new threads from **one** store ([[adr-024]]) | App #2 has its **own** store; the sweep has no suite-wide view; thread-N agent can't see app-X feedback | [[chief-knowledge-manager]] |
| **Prioritization** | Per-thread decide vs "the live roadmap" | No **cross-suite** ranking of many concurrent asks; effectively FIFO; no batching | [[chief-product-officer]] |
| **Capacity / staffing** | **One** hourly sweep, CoS-run, **serial** | Single triager is the volume ceiling; no parallel/sharded triage; no per-app owner | [[chief-of-staff]] |
| **Knowledge continuity** | Thread = per-app record; session context is ephemeral ([[adr-016]]) | No durable cross-thread/cross-app memory; context lost across sittings | [[chief-knowledge-manager]] |
| **Work management** | Tickets authored per accept ([[ticket-cycle]]) | Feedback not **batched** into coherent work; duplicate tickets; no theme rollup | [[chief-product-officer]] |

## Scope (this cycle) — frame, ticket, and instrument only

The **only** near-term build is telemetry, so the triggers below are measurable rather than guessed. Everything else is a **proposed** deep-dive owned by one executive, dormant until its trigger fires. One row per ticket:

| Ticket | Intent | Owner | Fires when (trigger) |
|---|---|---|---|
| [[work-071]] | Emit triage **scale telemetry** (open-thread concurrency, new-threads-per-sweep, dedup misses, per-app counts) to the [[ledger]] — folds into the [[request-triage]] build, no separate system | [[chief-of-staff]] | **Now** — ships with [[work-066]] so triggers are observable from day one |
| [[work-072]] | **Cross-thread dedup & clustering** in triage — converge rephrasings/related asks into one work item | [[chief-product-officer]] | **T2** or a measured duplicate-ticket rate (see Triggers) |
| [[work-073]] | **Parallel/sharded triage capacity** — a Triage Analyst template + evidence-bounded fan-out of the sweep | [[chief-of-staff]] | **T2** (concurrency/volume breach) |
| [[work-074]] | **Cross-app feedback knowledge index** — deterministic, generated suite-wide index for continuity (RAG only per [[doc-standards]] §7) | [[chief-knowledge-manager]] | **T1** (2nd app ships) |
| [[work-075]] | **Cross-suite prioritization board + per-app routing** — one ranked plate across all apps | [[chief-product-officer]] | **T1** (2nd app ships) |
| [[work-076]] | **Suite-wide aggregation architecture** (proposed ADR) — how triage reads across per-system stores without breaching [[invariants]] §9 | [[cto]] | **T1** (2nd app ships) |

### Activation triggers (the "when")

> **Don't build ahead of the signal.** Each phase turns on only when its trigger trips — read from [[work-071]]'s telemetry, not from a hunch.

- **T1 — the suite goes multi-app.** The **2nd app ships** (a second system with its own thread store). Turns on suite-wide knowledge + routing + the aggregation ADR (Phase 2).
- **T2 — concurrency/volume breach on any single store.** Sustained **> 15 open threads**, **or** an hourly sweep regularly finding **> 8 new threads**, **or** sweep backlog-latency breaching [[work-067]]'s bound. Turns on dedup + parallel triage capacity (Phase 1).
- **T3 — dedup is demonstrably needed.** Telemetry shows a **duplicate-ticket rate** the org is filing, **or** the Owner re-asks for something already in flight. Sharpens/expedites [[work-072]].
- **T4 — context loss observed.** A triage decision demonstrably ignored related work in another thread/app. Expedites [[work-074]] and, only then and only if catalog size defeats deterministic lookup, opens the RAG question ([[doc-standards]] §7, via a triggered ADR).

## The phased plan

> **Phase 0 is this PR.** Phases 1–3 are pre-staged as proposed tickets and switch on at their triggers. **Nothing below is authorized to build until its trigger fires** — that is how "don't be surprised" and "don't over-build" coexist.

- **Phase 0 — Frame & instrument (now).** This PRD + the six deep-dive tickets + [[work-071]] telemetry folded into the sweep. Cost: near-zero; foreclosed options: none.
- **Phase 1 — Absorb concurrency in one app (T2).** [[work-072]] cross-thread dedup/clustering (CPO) + [[work-073]] parallel/sharded triage capacity (CoS, via [[staffing-review]] — a bounded, evidence-triggered fan-out that respects the CoS's low-fan-out discipline).
- **Phase 2 — Go suite-wide (T1).** [[work-074]] cross-app knowledge index (CKM) + [[work-075]] cross-suite prioritization & per-app routing (CPO) + [[work-076]] aggregation architecture (CTO, proposed ADR).
- **Phase 3 — Durable continuity (T4 / sustained volume).** Standing "known-wants" memory so context survives sittings; RAG considered **only** if deterministic discovery actually fails ([[doc-standards]] §7), gated by an ADR that states the trigger.

## Non-goals (this cycle)

- **No build ahead of a trigger.** These tickets are proposed deep-dives, not a work order; each is Owner/trigger-gated.
- **No multi-user, roles, or tenancy** — the singleton posture is absolute ([[invariants]] §II). "Cross-app" means *one Owner's suite*, never many users. Per-app stores stay isolated ([[invariants]] §9 / [[adr-024]]); aggregation is read-only synthesis, never cross-app write reach.
- **No premature RAG** — deterministic discovery first ([[doc-standards]] §7); embeddings only when catalog size defeats lookup, via a triggered ADR.
- **No reopening the Request Loop plumbing** — trigger/write-back/notify/store ([[work-063]]–[[work-068]]) are correct; this extends, not reworks, them.
- **No unbounded triage fan-out** — parallel triage is bounded and evidence-triggered; heavy fan-out is the pattern that has broken sessions ([[staffing-review]] step 1).
- **No new STOP-gate surface** — deploy/spend/delete/publish/core stay hard-stopped to the Owner regardless of volume.

## Success

The Owner offloads feedback at their natural rate across the whole suite and never feels the machine fall behind: asks are caught, de-duplicated, ranked on one plate, and answered in-thread — and the org scaled to meet that volume **step by step on real signal**, having built nothing before its trigger and been surprised by nothing.

---

Follows [[doc-standards]] (esp. §4 registers and §9 presentation). Living, supersede-not-destroy (§5): sections are stamped and evolve in git + the [[ledger]] as triggers fire and phases activate.
