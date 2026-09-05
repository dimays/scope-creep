---
name: prd-human-input-log
description: The Human-Input Log — one Console timeline of every discrete human input, tagged, interleaved with the work done between inputs. A generated projection that owns no data.
metadata:
  type: project
  status: active
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-05
---

# PRD — The Human-Input Log

Owner-elevated to top priority; refined by the CPO + CTO ([[adr-010]]). **Supersedes
the scope of [[work-012]].**

## The user problem
The Owner wants a one-stop-shop to **review, evaluate, and learn from all real human
input** — a timeline of discrete inputs, each tagged, interleaved with what the system
did *between* inputs. It's the project's signature: seeing how little human involvement
buys how much work.

## Load-bearing principle
**The log owns no data.** It is a *generated projection* over existing systems of
record (the Console DB + the ledger + git + a new `human-input/` set for the terminal).
This keeps the mutator small and follows doc-standards ("discovery is generated, never
hand-maintained"). No bespoke capture pipeline; no ML summaries — reuse what exists.

## Taxonomy (two orthogonal tags per input)
- **Source** (MECE channel): `operator-session` (terminal / first-class Claude) ·
  `console-chat` · `work-request` · `request-reply` · `feedback` · `owner-action`
  (gate decisions: approve/decline/merge).
- **Intent** (facet): `directive` · `request` · `answer` (reply to an agent's ask) ·
  `decision` · `feedback` · `correction`.

## Data model (both are projections, not sources of truth)
- **`human_input`**: `{ id, ts, source, intent, summary, excerpt?, refType, refId, refUrl }`.
- **`interlude`** (between two inputs): derived from git commits + ledger entries in the
  window `[prev.ts, this.ts)`.

## Experience — review / evaluate / *learn*
A **spine** timeline (newest-first) alternating input cards and interlude cards, in the
Console (under Work). Input card: source + intent chips, timestamp, one-line summary,
excerpt, deep link to context. Interlude card: "Between these, the system: …" + commit/
PR/ledger links. **Leverage readout** per window (inputs vs. commits/work shipped) — the
"how little human involvement" story, made visible. Filters by source/intent/date.

## Capture — honest, per source
| Source | v1a? | How |
|---|---|---|
| console-chat | ✅ | `conversation_messages` role=owner |
| work-request / request-reply | ✅ | `request_messages` author=owner |
| feedback | ✅ | `feedback` table |
| owner-action (gates) | ⚠️ later | structured gate events (v1b+) |
| operator-session (terminal) | ❌ v1a → ✅ v1b | `UserPromptSubmit` hook → `human-input/` NDJSON |

## Scope
- **v1a (ship now, no gate, periphery = [[work-012]]):** the read-model union over the
  three captured sources + git/ledger interludes + leverage readout. Terminal/gate shown
  as honest "capture pending" channels.
- **v1b (Owner-gated core change = [[work-020]]):** the `UserPromptSubmit` hook +
  `human-input/` reader + Consistency self-checks. Captures the terminal surface.
- **Deferred:** retroactive transcript harvest, structured gate events, machine intent
  inference, in-place annotate, intent-mix analytics.

## Non-goals
The log never becomes a source of truth; no telemetry pipeline in the core.
