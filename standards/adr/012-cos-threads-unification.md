---
name: adr-012
description: Reconciles the Chat + Requests surfaces into one CoS-Threads surface on the shared conversation primitive — a top-level Threads nav replacing Chat, a first-class thread lifecycle/turn field, typed inline cards, the requests→conversations migration, and how the Human-Input Log reads the consolidated source. Supersedes ADR-008's Requests-v2 framing and the Requests half of prd-work-intake.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-06
---

# ADR-012: CoS-Threads — unify Chat + Requests on the conversation primitive

- **Status:** accepted
- **Date:** 2026-09-06
- **Deciders:** Owner (directed + accepted the IA and the ADR-first sequencing),
  CPO (drafted [[prd-cos-threads]] + the phase tickets), Chief of Staff (ratified,
  escalated the gating decisions in [[ledger-028-cos-threads-roadmap]])
- **Supersedes (in part):** [[adr-008]] — its core (one persisted `conversation`
  primitive: threads + messages) **stands and is extended here**; only its deferred
  "Requests-v2 rides the same tables later" framing is settled by this ADR. Also
  supersedes the **Work Requests half of [[prd-work-intake]]** (Work History stands).

## Context
The Console splits the Owner's two-way contact with the org across **two windows** — a
top-level **Chat** tab ([[work-014]]) and a **Requests** section under Work
([[work-009]]). The Owner wants **one chat interface with his Chief of Staff**, organized
into discrete **threads** he can open, follow up, branch, and close ([[prd-cos-threads]],
[[ledger-028-cos-threads-roadmap]]). Chat and a Request are the *same shape* — an ordered
Owner↔org conversation — split only by history and by two backing schemas
(`conversations`/`conversation_messages` vs. `requests`/`request_messages`). The roadmap
escalated five decisions to the Owner before the first ticket; this ADR records the ones
that reshape core surfaces, so the reshape has a decision of record rather than living
only in a ticket.

The hard prerequisites are met: [[work-025]] (Drizzle is the single schema source) and
[[work-026]] (tests for the conversation/requests modules) are **done** — we are not
migrating the schema blind.

## Decision
1. **One Threads surface, on the one primitive.** Chat + Requests collapse onto the
   [[adr-008]] conversation primitive. A **thread is a `conversation`**; its timeline is
   `conversation_messages` plus typed cards. The bespoke `requests`/`request_messages`
   tables are **migrated into** `conversations`/`conversation_messages` and retired — the
   ADR-008 migration that was deferred to protect the working Requests feature.
2. **Top-level nav, replacing Chat** (Owner decision, 2026-09-06). `Threads` becomes a
   first-class nav peer (Console / Explore / Work / **Threads**), replacing the `Chat`
   tab; the `Work→Requests` section is retired and folded in. This matches "the primary
   human-input loop." The alternative (nest under `Work→Threads`) was **rejected**:
   Threads is the Owner's primary loop, not a sub-section of the backlog.
3. **Lifecycle/turn is a first-class field.** Every thread carries an explicit state:
   `open → (needs-you | working) → closed`, terminal at `closed`, reopenable by a
   followup. This is the **native fix** for the [[work-011]] Requests "whose-turn" bug —
   turn is a stored field, not derived after the fact. It generalizes the
   [[request-intake]] statuses (`accepted | declined | needs-info | done`) into one
   lifecycle that also fits plain chat.
4. **Typed inline items.** A thread renders more than text: request-intake **outcomes**
   (ticket created/modified, decline-with-reason, counter-proposal, fold-into-PRD) show
   as typed cards deep-linking to their artifact. The schema gains a discriminator on
   `conversation_messages` so a row can be a `message` or a typed `outcome`; the richer
   card types (agent-activity, generated-request) land in later phases
   ([[work-031]], [[work-032]]) on the same discriminator — additive, no reshape.
5. **Every outcome stays a human-gated proposal.** Threads never bypasses INVARIANTS §III
   gates (deploy / spend / delete / publish). An intake outcome is a *proposal*
   surfaced in the thread; the Owner still acts on it. Threads adds no autonomous
   authority — it is a surface, not a new grant.
6. **Human-Input Log reconciliation.** The Log ([[prd-human-input-log]], [[adr-010]],
   [[adr-011]]) stays the **generated projection that owns no data**; Threads is the
   **live read-write front** of the same loop. After the migration the Log unions **one**
   owner-message source (`conversation_messages` where `role = owner`) instead of two,
   deriving the per-input `source`/`refUrl` from the parent conversation's `kind`
   (`chat` vs. `request`). This **shrinks** the drift-prone `human-input.server.ts`
   surface flagged in [[work-026]]. The operator-session NDJSON union is unchanged. A
   **CoS-initiated** thread ([[work-030]]) is an org→Owner event and is **not** a human
   input — it must not pollute the Log (the Log tags Owner inputs only).

## Scope of this ADR vs. the phased rollout
This ADR authorizes **Phase 1 / [[work-029]]** (unify + migrate; async operator triage,
no new runtime). Later phases are pre-reconciled here but ticketed separately:
CoS-initiated threads + needs-you queue ([[work-030]]), inline agent activity projected
from the [[ledger]] ([[work-031]]), branching + generated-request cards ([[work-032]]),
and live in-app replies (Phase 5) which fold into the flagship [[work-017]] runtime.

## Consequences
- **One model, one surface, one nav entry.** The "Chat vs. Requests" split disappears;
  the request-intake loop ([[request-intake]]) is unchanged in substance, only rehomed.
- **A destructive-ish migration** runs once: `requests`→`conversations`,
  `request_messages`→`conversation_messages`, preserving `author→role`, timestamps, and
  status (mapped into the new lifecycle). Drizzle stays the single source ([[work-025]]);
  the data migration is guarded by tests before the tables are dropped.
- **Deep links change:** `/work/requests/:id` → the new thread route. A redirect
  preserves any existing links.
- **Still deferred:** live in-app replies (Phase 5) — until then, triage stays **async
  in the operator session**, exactly today's [[work-009]] mechanism.

## Alternatives considered
- **Keep two surfaces, share a component** — rejected: leaves two schemas and the
  two-window experience the Owner explicitly does not want.
- **Nest Threads under Work** — rejected (decision 2): demotes the Owner's primary loop.
- **Amend [[adr-008]] in place** — rejected: ADRs are immutable once accepted
  ([[engineering-policy]]); this ADR supersedes its Requests-v2 framing instead.
- **A new `threads` table distinct from `conversations`** — rejected: reintroduces the
  very split this removes; the conversation primitive already is the thread.
