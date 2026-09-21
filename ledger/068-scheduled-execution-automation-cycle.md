---
name: ledger-068-scheduled-execution-automation-cycle
description: Orchestration record (INVARIANTS §III.8) for the scheduled-execution automation cycle the Owner directed on thread scope-creep-thread:9 — "a scheduled routine to execute on planned work," ramping the self-evolution cycle to a milestone. Two decisions landed as PRs that HOLD for the Owner. (1) The cloud write-path unlock — ADR-026 (PR #97) picks PROPOSE-ONLY: grant the shared Claude GitHub App scoped Contents+PR write (it is the sandbox proxy's forced identity, ledger-066), routine opens PRs as that identity, dispose stays off-sandbox because the identity can never present as sole code-owner @scope-creep-review. Reverses owner-apply §1d; moots scope-creep-routine[bot] for the cloud path. CRO verdict CONFIRMED-WITH-CONCERNS → un-pause criterion #3 hardened to a manifest-permission gate. (2) PM maturity — PR #96 adds the `review` lifecycle state (to-do→in-progress→in-review→done) + a propose-only board-hygiene loop as the write-path canary. Also records the ledger-066 leaked-key incident as RESOLVED (Owner rotated 2026-09-21).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-21
---

# Ledger 068 — scheduled-execution automation cycle

**Date:** 2026-09-21 · **Thread:** scope-creep-thread:9 (Owner directive) · **Orchestrator:**
[[chief-of-staff]] · **PRs:** #96 (PM maturity) · #97 (write-path ADR-026) — **both HOLD for the
Owner, nothing merged.**

## The directive
The Owner asked for **a scheduled routine to execute on planned work** and to **ramp the
automation / self-evolution cycle** to a meaningful milestone they can poke at and give real
feedback on — with an explicit welcome for a **mature PM process** (routine backlog pruning;
to-do → in-progress → in-review → done) and an overriding value of an **elegant, uniform
experience**. The execs were trusted to decide what loops/routines to add or modify.

## Delegation (transparent-delegation stress test)
Fewest heads that could make the call, each staffed to a decision — not a survey:

| Track | Head(s) | Charge | Outcome |
|---|---|---|---|
| Write-path unlock ([[work-096]]) | [[cto]] (author) → [[chief-reality-officer]] (independent cross-check) | Pick a cloud write-path architecture that survives the sandbox proxy; correct the runbook; define machine-checkable un-pause criteria | **ADR-026**, corrected runbook, amended owner-apply checklist — PR #97 |
| PM maturity | [[chief-product-officer]] | Add an explicit in-review state + a routine board-hygiene cadence; keep it uniform | `review` state, `board-hygiene` loop, schema + validator — PR #96 |
| Verification | [[qa-tester]] (schema), [[chief-reality-officer]] (decision) | Reproduce "green"; falsify the write-path decision before it is trusted | qa gates green; CRO CONFIRMED-WITH-CONCERNS |

## Decision 1 — the cloud write path: PROPOSE-ONLY ([[adr-026]], PR #97)
Root cause is [[ledger-066-cloud-sandbox-proxy-identity-wall]]: the claude.ai sandbox egress proxy
overrides the outbound `Authorization` header and re-authenticates every `api.github.com` call as
its **own** GitHub App identity (the shared Claude GitHub App; resolves to `dimays`, 15000
installation ceiling). No custom identity survives it, so the author≠merger split cannot exist
**inside** the sandbox.

**Chosen architecture — propose-from-cloud, dispose-off-sandbox.** The Owner grants the shared
Claude GitHub App scoped **Contents + Pull-requests write** on `scope-creep` + `scope-creep-console`;
the routine opens PRs **as that forced identity**; **review + merge stay local/human as
`@scope-creep-review`**, where identities resolve and the code-owner gate holds. The proxy identity
is **not** the sole code owner, so branch protection (`require_code_owner_reviews` + 1 review +
`require_last_push_approval` + `dismiss_stale_reviews`, live per owner-apply Part 0) holds every
routine PR for a genuine code-owner approval it can never present. Propose freely; cannot dispose.

**Consequences stated plainly (no soft-pedaling):**
- **Reverses [[adr-023]]-era owner-apply §1d** ("keep the Claude App read-only") and **moots the
  dedicated `scope-creep-routine[bot]`** for the cloud path (its token is overridden in-sandbox).
- **Blast radius:** granting the shared Claude App write means *every* interactive claude.ai session
  can push branches + open PRs on both repos. Acceptable for a single-user, fully-trusted-Owner
  system **only because** merge stays gated by identity — **and only if** the Claude App manifest
  does **not** carry `Administration`/`Workflows`/`Actions` write (which would let a session edit
  branch protection or workflows and collapse the whole gate). That manifest is Anthropic's, not
  ours to trim, so it is a **checked precondition, not an assumption**.

**Honest testability boundary:** the decisive test (does `POST /pulls` succeed under the proxy
*with* write? is the resulting PR held from merge?) is **not reproducible from a local session** — it
needs the Owner grant first. ADR-026 does **not** claim it proven; it defines it as an un-pause
criterion.

## Decision 2 — PM maturity: the `review` state + board-hygiene canary (PR #96)
- **New lifecycle state `review`** (single-word, uniform with the existing lexicon): to-do =
  `proposed`, in-progress = `active`, in-review = `review`, done = `done`; `blocked` a side-state,
  `superseded`/`dropped` terminal. Entry rule: a ticket enters `review` when code-complete with an
  open PR awaiting review/merge (the [[adr-022]] verify→review→land finish line); exit → `done` on
  merge. Landed in `work/README.md` (v1.1.0) + `scripts/work-check.ts` enum.
- **New `loops/board-hygiene.md`** — a dedicated, **propose-only**, lowest-blast-radius loop (edits
  only `work/*.md` status fields; opens one board-state-correction PR). Positioned as the
  **write-path canary**: the first routine to un-pause once write is granted, proving propose-only
  before [[work-sweep]] drives real builds. [[work-sweep]] "drive" step updated to move tickets
  active→review→done.
- **Tickets:** [[work-097]] (the lifecycle change; **dogfoods `review`** on itself), [[work-098]]
  (register board-hygiene — Owner-gated core-upgrade), [[work-099]] (Console renders the in-review
  column — periphery, `scope-creep-console`).

## Reconciliation calls (CoS, decided not deferred)
- **work-098 ownership → `chief-of-staff`** (+ `loops/board-hygiene.md` `owner_agent`): loop
  registration is a CoS-orchestrated, Owner-gated act, consistent with [[work-086]] / work-sweep.
- **work-097 dogfoods `review`:** it is code-complete with an open PR — exactly the entry condition —
  so the PR that introduces the state demonstrates it on its own ticket.

## Independent verification
- **[[chief-reality-officer]] on ADR-026: CONFIRMED-WITH-CONCERNS.** Architecture sound, honesty
  commendable; but "merge blocked by identity" silently assumed the Claude App manifest lacks
  Administration/Workflows/Actions write. **Fix folded into ADR-026:** (1) that no-write property is
  now a **checked precondition**, not asserted fact; (2) **un-pause criterion #3 upgraded from
  record-only to a hard GATE** — record the full granted permission surface and **hard-block un-pause
  if Administration/Workflows/Actions write is present** (`Issues:write` is an accepted, recorded
  residual — merge still blocked, but flagged for the [[adr-023]] Phase-2 marker concern); (3)
  §residuals records that criterion #5 proves the merge path **works**, not that it is **human-only**
  (the unattended `@scope-creep-review` PAT satisfies it identically) — the ADR-023 Phase-2 residual
  is **relocated off-sandbox, not closed**.
- **[[qa-tester]] on PR #96 (verified at branch tip 7b9115b): BOTH GATES PASS on real runs** —
  `work:check` "99 work items OK" (exit 0); `registry:check` exit 0, `git diff registry/` empty (the
  3 warnings are known pre-existing sibling-repo manifest refs — scope-creep-console, ext-feedback,
  ext-chatbot — non-fatal). Four-column lifecycle **CONSISTENT end-to-end**: validator enum includes
  `review`; README maps the four columns with a **three-door exit** (review→done only on merge,
  review→active on send-back, review→blocked on STOP); `work-sweep` step 3 and `board-hygiene` step 2
  use identical vocabulary; `review` confirmed reachable (active→review) **and** exitable — not a dead
  end. Both reconciliation edits confirmed present (work-097 `status: review`, work-098 `owner:
  chief-of-staff`). No failure mode; backward-compatible (all 99 validate). qa did not merge —
  escalation-class disposition stays with the Owner.

## Security incident — RESOLVED
[[ledger-066-cloud-sandbox-proxy-identity-wall]] recorded a self-caused leak of
`GH_APP_PRIVATE_KEY_B64` (the `scope-creep-routine` App private key) into a claude.ai transcript.
**The Owner rotated the key on 2026-09-21; the incident is CLOSED and the leaked copy is inert.**
Key rotation is therefore **removed** from the Owner needs-you list.

## Gate posture
Both PRs are **escalation-class core** ([[adr-022]] trigger (d) — loops/standards/schema) and
**HOLD for the Owner**; nothing was self-merged. The org proposed; the Owner disposes. Registration
of any routine remains Owner-gated ([[adr-021]]) — specified, never fabricated in
`registry/routines.json`.

## Disposition / open residuals
- **Owner needs-you checklist** is the milestone hand-off (relayed with this cycle's summary): verify
  the Claude App manifest first (Administration/Workflows/Actions write = HARD STOP) → grant
  Contents+PR write per owner-apply **Part 1′** → run the strengthened un-pause criteria in-sandbox →
  un-pause **board-hygiene first (canary)**, then **work-sweep** → merge PR #96 + #97.
- **Open residual (not closed here):** [[adr-023]] Phase-2 — an unattended reviewer identity can still
  clear an escalation hold; propose-only relocates the risk off-sandbox but does not resolve it. Named
  honestly in ADR-026 §residuals and owner-apply.
- **Minor hygiene:** a concurrent track transiently overwrote a shared scratchpad `pr.md`; no effect
  on either PR (both bodies patched from live GitHub). Worth a glance at PR #97's rendered banner
  anchor link.
