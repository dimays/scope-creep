---
name: resource-budget
description: How the factory spends its finite token/API/compute budget — model selection by task tier, spawn discipline, graceful behavior at a usage limit, and when a spend increase needs the Owner.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# Resource Budget

Owned by the [[chief-of-staff]] as a **standard**, not a dedicated executive seat
([[decision-rights]] assigns resource/budget decisions to the CoS, CTO consulted, CRO
verifies, CoS ratifies). Written after this operating session hit its **usage limit
twice** in one night — once mid-dry-run, killing three in-flight agents — while fanning
out multiple Opus-tier agents at once. As the factory runs more autonomously (more
agents, longer loops), someone must own the budget and pace work against limits before
limits pace it for us.

## 1. Model selection by task tier

Select a model by what the task actually needs, not by default-to-flagship. The
committed catalog is [[reference]]'s `reference/models.json`; the agent-pickable policy
this section codifies is what [[work-018]] wires into the Console/agent runtime.

| Tier | When | Catalog default |
|---|---|---|
| **Routine / high-volume** | Short, low-risk turns: classification, formatting, simple lookups, high-frequency chat turns | `defaults.routine` (Haiku — cheapest per-token, smallest context) |
| **Balanced / chat** | Normal conversation, in-app chat, most single-shot generation | `defaults.chat` (Sonnet — the in-app default) |
| **Expensive / agentic** | Multi-step reasoning, coding, tool orchestration, anything spawned as an autonomous sub-agent | `defaults.agentic` (Opus — highest quality, highest cost) |

Rules:
- **Read tier from the catalog, never hardcode a model ID.** `reference/models.json`
  is the single source of truth for `{id, tier, input$, output$, context}`; a retired
  ID must fail hard and fall back to the tier default, per [[work-018]]'s acceptance.
- **Default down, escalate up.** Start a task at the cheapest tier that can plausibly
  do the work; escalate to the next tier only when the task demonstrably needs it
  (failed a check, needs deep multi-step reasoning, is coding/agentic work touching
  the core). Don't reach for Opus by habit.
- **Mix models across a fan-out.** When a batch of agents is spawned for one effort,
  not every seat needs the flagship model — route research/verification/formatting
  sub-tasks to a cheaper tier and reserve Opus for the seats doing the hard reasoning
  or code-writing.

## 2. Spawn discipline

The proximate cause of this session's usage-limit hits: fanning out several Opus-tier
agents simultaneously. Going forward:

- **Stagger spawns.** Don't launch a wide fan-out of expensive agents in the same
  instant. Sequence or batch them so the session's burst rate stays under the limit,
  even if the total token spend across the run is the same.
- **Bound concurrency, not just tier.** A handful of concurrent agents is fine; five
  simultaneous Opus agents is the pattern that broke this session — cap how many
  expensive agents run at once, independent of how cheap agents are batched.
- **This is spawn-time budget hygiene, not a merge gate.** It governs *how* the CoS
  (or any lead) staffs an effort, not what ships; it doesn't add a check to the
  [[ticket-cycle]] or the CI gate.
- The recurring level-set loop ([[work-033]]) pulls this section for its own spawn
  discipline when it convenes a batch of domain-review agents — see that loop's
  cadence review of budget incidents.

## 3. Graceful behavior at a usage limit

Hitting the limit should degrade gracefully, never destructively:

- **Checkpoint before you fan out.** Before spawning a batch, make sure in-progress
  work (branch state, a running agent's partial output, a loop's step) is at a point
  it can resume from — don't let a limit hit strand work that only existed in a dying
  agent's context.
- **On a limit hit: stop spawning, don't discard.** A killed agent's already-committed
  work (a branch, a file write, a PR) stays; only its in-flight, uncommitted reasoning
  is lost. Resume by re-running the remaining staffing plan against the checkpoint,
  not by re-running the whole effort from scratch.
- **Record it.** A usage-limit hit that killed in-flight work is a gate-catch worth a
  [[ledger]] note — it's exactly the kind of operational incident the level-set loop
  ([[work-033]]) mines for lessons, and it's why this standard exists.

## 4. When a spend increase is Owner-gated

Publishing or following this standard is not itself a spend decision — no gate needed
to write it down or to route a task to a cheaper/pricier tier **within the existing
catalog and existing budget**. A **spend increase** is Owner-gated per
[[invariants]] §III.7 and the [[decision-rights]] resource/budget row. That means,
concretely, before an agent:

- adds a **new paid model or provider** to the catalog (not just picks among the
  existing `reference/models.json` entries),
- **raises a rate limit, quota, or plan tier** that costs more money,
- or otherwise commits the Owner to **materially higher recurring or one-time spend**

— it proposes the change and gets explicit Owner approval first, same as any other
`spend` action ([[tech-sops]] §5, enforced by the harness, not goodwill). Model *tier
selection* for a given task is not a spend increase and doesn't need per-call
approval; a change to the catalog's defaults or a new model provider is.

## Revisit

If resource management outgrows a standard — a dedicated budget dashboard, automated
throttling, or a role spending real judgment on it every day — propose a dedicated
role via [[decision-rights]] rather than keep bolting onto this document.
