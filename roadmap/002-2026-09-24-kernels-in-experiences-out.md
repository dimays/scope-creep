---
name: roadmap-002
description: The C-suite's single org position after the Owner's 2026-09-24 re-evaluation mandate. It sets the thesis, the north-star experience and metrics, the diagnosis, six ordered foundation workstreams, the stop list, the new decision rights, and the four calls that are genuinely the Owner's. Supersedes the round-1 "make it true before making it bigger" synthesis.
metadata:
  type: reference
  status: proposed
  version: 0.1.0
  owner_agent: ceo
  last_verified: 2026-09-24
---

# Roadmap Presentation 002 — 2026-09-24

- **Horizon:** ~6 weeks, until unattended kernels ship. **Presented by:** [[ceo]], co-owned with [[chief-of-staff]].
- **Supersedes:** [[roadmap-001]] and the round-1 synthesis.

> **This round in one line:** the org stops working on its own plumbing and builds the loop the Owner asked for. The first proof is **one real Owner kernel shipped end-to-end with nobody watching**. We need **four calls** from the Owner, down from fifteen.

## 1. Thesis

**"Kernels in, delightful experiences out. They compound, the org handles them unattended, and only what grants power goes to the Owner."**

This line fuses four exec proposals, because each one covers only part of the vision:
- **CPO** ("kernels in, experiences out, unattended") gives the loop.
- **CEO** ("intent is the unit") gives the unit.
- **Designer** ("delight is the whole point") gives the bar.
- **CRO** ("hold what grants power") gives the escalation rule.

"Make it true" survives only as the **definition of done**: nothing counts as shipped until the Owner can use it running.

## 2. The north-star experience

| Stage | What the Owner sees | Bar |
|---|---|---|
| **Drop** | A spark in the console, the terminal, or an in-app capture. No form. | Wherever they are |
| **Heard** | "Heard X, reading it as Y, doing Z, by T." They steer by correcting the reading. | < 5 min |
| **Result** | A live preview, screenshots, and "decisions we made for you (reversible)" | < 24 h for small kernels |
| **Keep** | A "since you were here" card with keep / tweak / revert. Silence means keep. | 0 merges by the Owner |
| **Compound** | Reactions become taste rules. Bursts cluster into ideas in flight (WIP-capped). | No repeating themselves |

| North-star metric | Baseline | Target |
|---|---|---|
| Kernel → first *running* result | ∞ (the autonomous path has never completed) | < 24 h |
| Owner touches per shipped kernel | **TBD.** CKM re-derives it from the human-input log (367 raw rows, unclassified). The earlier ≈6 estimate was not reproducible. | ≤ 1 (a reaction) |
| Unattended yield (kernels shipped with 0 approvals) | 0 | Most periphery kernels |

Guardrails: revert, false-green, and canary-catch rates.

## 3. Diagnosis: why we drifted

**We never built the producer.** No Owner kernel has ever gone through the autonomous path. The Owner merged 97% of changes because nothing else produced work, not because we were timid. Five things led here:
- **The substrate was wrong.** We spent ledger 051–079 forcing write access through a sandbox proxy that makes every commit look like it came from the Owner.
- **§I.4 makes the whole repo "core",** so nearly everything escalates.
- **We built the org around its own process.** Six of fourteen loops tend the org itself.
- **We keep no memory of the Owner.** The repo has 335 docs and none about them.
- **Our priorities followed recency.** Each audit spawned more plumbing, while v2 and v3 (the kernel loop itself) stalled for three weeks.

## 4. Foundation, ordered

| # | Workstream | Owner | Summon | Done means |
|---|---|---|---|---|
| 1 | **Producer and substrate:** an `org-run <loop>` host, bot identity everywhere, the reviewer on console + design | [[cto]] | platform-engineer, devops-engineer | No org commit is authored as the Owner. The build loop runs on the host. |
| 2 | **M1:** one real Owner kernel, end-to-end, unattended, on the console | [[chief-product-officer]] | product-designer, frontend-engineer, qa-verifier | It is running in their console with 0 touches and a replayable trail |
| 3 | **Spark spine:** capture (human-input log + console box), the Heard ack, and an ideas-in-flight home | [[chief-product-officer]] / [[chief-designer]] | frontend-engineer, integration-engineer | Heard in < 5 min. The "Your factory" home is replaced. |
| 4 | **Delight gate:** a local live preview (worktree + HMR). This is a **new build**: there has never been a live preview, and the sandbox has always been isolation + diff. a design-review stage, `taste.md` | [[chief-designer]] | product-designer, design-systems-engineer | Every result has something to look at, not a diff |
| 5 | **Owner Model:** sourced taste rules, `owner.json`, one file per kernel, truth-based freshness | [[chief-knowledge-manager]] | knowledge-engineer | Every agent reads it first |
| 6 | **Trust rails and operating model:** evidence bundles, canaries, runaway caps, loops 14 → 7, staff as runtime instances | [[chief-reality-officer]] + [[chief-of-staff]] | security-engineer, program-coordinator | A weekly digest with revert replaces per-PR asks |

**Milestones:**
- **M1** is the single-kernel proof. It is a probe, not a gate.
- **M2** is the spark spine plus the live preview.
- **M3** is the acceptance test: **replay a set of real Owner kernels with 0 Owner touches.** CKM classifies that set from the human-input log, and its size is not yet known.

| Disagreement | Call |
|---|---|
| (a) Reviewer extension | **Extend now.** The CEO withdraws the round-1 hold. |
| (b) Substrate | **Actions + claude-code-action with the Owner's Max `setup-token`.** **The CRO cleared this, with conditions.** It is officially supported (`claude_code_oauth_token`). ADR-016's ban covers self-built apps, which doesn't include the unmodified Claude Code binary running for the Owner. **Risk:** it draws on the same Max usage pool as the Owner's own sessions. So first run a **1-week canary** with `--max-turns`, concurrency 1 and workflow timeouts, and measure the change in the Owner's usage before scaling up. Fallback: local launchd under a separate macOS user. claude.ai routines stay for read-only jobs only. No API key, which would be metered and therefore §7 spend. |
| (c) Chatbot extension | **Split it.** Close v2 as an *in-app Claude caller*, which ToS rules out (the CPO is right). Revive the shell as a **zero-Claude-call capture surface**, which [[adr-016]] permits (the Designer and CTO are right). |
| (d) Silence = consent | **Adopt for reversible periphery work only.** It requires the CRO evidence bundle, one-tap revert, and a digest line. |
| (e) First proof | **M1.** It runs on today's host if Actions isn't ready. It is periphery, so it is self-mergeable now. |

## 5. Stop, pause, cut

| Stop | Instead |
|---|---|
| 14 loops | **7:** kernel-intake, build (with demo and delight stages), heal, new-app, core-upgrade, decision, weekly org-tune. board-hygiene is cut; status comes from GitHub. |
| Factory-watching PRDs | Pause console-operations, org-activity-moments, transparent-delegation, org-and-staffing. Retire work-intake. |
| The sandbox write path | Stop, including the round-1 cron move and healthchecks.io |
| Hand-written merge ledgers | Generate them from PR metadata |
| Date-based freshness | Truth-based checks on load-bearing claims |

## 6. Decision rights going forward

| The Owner holds | The C-suite decides (weekly digest + revert) |
|---|---|
| §7 at the moment of action, **including enabling metered compute** | Periphery and app code |
| Credentials, and permission grants to agent identities | Loops, cadences, prompts |
| **The authority surface:** INVARIANTS, the escalation model, `.claude/`, `.github/workflows`, CODEOWNERS, gate scripts, **dependency/infra manifests** (batched weekly) | ADRs, PRDs, roadmap, docs |
| Red-gate waivers | Staffing from templates |
| An irreversible dispute that CoS + CRO couldn't resolve | Reversible product calls |

The `owner-approved` label no longer counts as Owner evidence; only a GitHub review from `@dimays` does.

## 7. What needs the Owner (4)

| # | Call | Why it's theirs |
|---|---|---|
| 1 | **Rotate the leaked Turso token and remove the App key from the cloud env** | Credential actions and permission config, which agents are barred from. Blocks nothing. Also remove the stale merge/`api` Bash allows in the local, gitignored `.claude/settings.local.json`. The hook comment says they were revoked, but they are still present. |
| 2 | **Approve ONE "autonomy charter" core-upgrade** (contents below) | Only the Owner amends INVARIANTS |
| 3 | **Install the bot App on console + design and set up design branch protection.** Once the CRO clears it, also mint the Max `setup-token` into an Actions Environment scoped to `main`. | These are permission grants and a credential, and using the subscription on CI is ToS-sensitive |
| 4 | **Decide where your verbatim words live** (proposal: a private `scope-creep-owner` repo) | Their data and their privacy boundary |

**The autonomy charter contains:**
- **A1:** §I.4 core narrows to the safety kernel.
- **A2:** under §I.3, the CoS may ratify summon and retire from templates by standing rule.
- **A3:** in §10(c), a "tradeoff" means a dispute still unresolved after CoS ratification.
- **§7 clarification:** rebuilding the *local* console from main is not a deploy.
- **Decision-rights rewrite,** including the label rule.
- **CODEOWNERS narrowed** to match A1.
- **Owner Model** added to the AGENTS.md read order.

**Deferred on purpose: §7 standing spend envelopes.** Nothing in this horizon needs spend, and money deserves its own decision backed by real cost data.

**The org will just do the rest,** including 11 of round 1's 15 asks (prompts, self-tuning, PRD refresh, request-loop, theme target, ADR-026, release-003, work-060).

## 8. Pushback to the Owner

- **Zero approvals is not zero input.** Their taste is the fuel. We want fewer approvals and more reactions.
- **§7 stays hard.** An org that can spend its way out of a problem isn't one they can step away from.
- **More staff won't help until the pipeline flows.**
- **The governance work wasn't waste.** Those rails are what make silence-as-consent safe. The sandbox write path was the waste.

## Disposition
*Pending the Owner.*
