---
name: ledger-027-level-set-round
description: C-suite level-setting dry run (5 hats) — consolidated debt findings + ranked paydown plan; Owner chose "stabilize first" and project-scoped capture (operate from scope-creep).
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-05
---

# Ledger 027 — Level-setting round (C-suite dry run)

**Date:** 2026-09-05 · **Recorded by:** Chief of Staff

The Owner convened a multi-agent C-suite dry run to level-set after the Human-Input
Log shipped. Five hats (CTO, CPO, Chief Designer, CKM, CRO) each ran a read-only
domain assessment; the CoS synthesized. (Three hats hit the session rate limit
mid-run and were relaunched after it cleared — an operational note: stagger or
mix models on future large dry runs.)

## Verdict
Healthy and disciplined for its age — coherent charter/ADR/ledger/work spine, both
CI gates green, invariants honored in code, clean wiki-link graph. Debt clusters in
three places: **the just-shipped Human-Input Log was half-real**, **records had begun
to drift from reality**, and **enforcement machinery lags the written standards**.

## Convergent findings (multiple hats)
1. **Human-Input capture never fired in the Owner's real sessions.** The hook was
   project-scoped to `scope-creep/`, but the Owner drives from `datamays/` — so all 31
   records were `backfill:true`, zero live (CRO, verified). ADR-010 also described
   `human-input/` as a *tracked* record set while it shipped *gitignored/local-only*,
   and the PRD data model didn't match the shipped NDJSON (CKM). → reconciled in
   [[adr-011]]; capture-location decided below.
2. **Records started lying.** Console version + CHANGELOG frozen at 0.13.0 while
   console PRs #13/#14 merged on top; `/healthz` reports stale; `consistency()` has no
   version-sync check (CRO, CTO). → [[work-023]].
3. **Standards unenforced.** `docs:lint` is a stub; the RR7→RR8 + Vite 8 major bump
   landed with no gated core-upgrade or ledger entry (CTO, CKM). → [[work-024]],
   [[work-028]].
4. **Test coverage stops at pure helpers.** Genuinely untested: `human-input.server.ts`,
   `conversation.server.ts`, `requests.server.ts`, all routes (CRO sharpened CTO's
   broader claim — 5 of 8 `.server.ts` are in fact tested). → [[work-026]].

## Owner decisions (this round)
- **Capture location → project-scoped.** Rejected a user-level `~/.claude` hook (would
  capture every unrelated project — finance, phrasewood — into the Scope Creep log).
  Instead the Owner **operates Scope Creep sessions from `~/code/scope-creep`**, where
  the existing project hook captures cleanly; `scripts/backfill-human-input.py` covers
  anything run elsewhere. Recorded in [[adr-011]]. (No code change — the merged hook
  already does this; verified it writes live, redacted, non-`backfill` records.)
- **Track → "stabilize first."** Pay down the cheap, high-leverage debt (capture wiring,
  version/docs enforcement, ADR reconcile, schema single-source, runtime tests, a11y)
  before resuming feature work (the flagship [[work-017]] and self-heal [[work-004]]).

## Ranked paydown backlog
New tickets from this round: [[work-023]] version-sync · [[work-024]] docs:lint ·
[[work-025]] schema single-source · [[work-026]] runtime test coverage ·
[[work-027]] a11y + design-token cleanup · [[work-028]] ratify RR8/Vite8 core-upgrade.
Pre-existing and still queued: [[work-011]] Requests async-state bug · [[work-010]]
surface feedback · [[work-022]] Consistency self-checks · then the flagship
[[work-017]] and [[work-004]].

## CoS read — pool & standards
- **C-suite pool:** well-differentiated — the hats produced non-overlapping, high-signal
  findings and the CRO caught a peer's overstatement. No new seat needed yet (single-user
  keeps the security/SRE surface small). The agents' own README had drifted (fixed here).
- **Operating standards:** the loop performed well (ticket → branch → gated PR → merge,
  supersede-not-delete, honest work-022 carve-out). The gap is **enforcement** — nothing
  gates version bumps, `docs:lint`, or core-upgrade ratification, which is how RR8 slipped
  in. work-023/024/028 install that missing machinery.
