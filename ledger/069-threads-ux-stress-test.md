---
name: ledger-069-threads-ux-stress-test
description: Chief-of-Staff-orchestrated Threads UX stress-test — the Owner reported Threads is buggy (wrong default folder, launcher never links to the existing conversation, reopen untested, design off). Triaged to work-100..104 (+ follow-ups 105-107), empirically reproduced by qa, root-caused to a FABRICATED deep-link scheme, fixed (CTO) + polished (chief-designer) on the console repo, held as an Owner-experienced milestone. ADR-016 zero-Claude-call invariant preserved.
metadata:
  type: project
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-21
---

# Ledger 069 — Threads UX stress-test (Owner feedback → fix, held for Owner)

**Date:** 2026-09-21 · **Thread:** `scope-creep-thread:9` · **Tickets:** [[work-100]] (umbrella),
[[work-101]]/[[work-102]]/[[work-103]]/[[work-104]] + follow-ups [[work-105]]/[[work-106]]/[[work-107]] ·
**Control-plane PR:** #98 (triage record) · **Console PR:** the Threads fix (held for Owner) ·
**Frame:** [[adr-016]], [[prd-cos-threads]]

## What happened
The Owner reported the Threads experience is "pretty buggy" and asked the org to stress-test and
polish it: (1) "open in Claude" lands in **"No folder"** not `scope-creep`; (2) opening a launched
thread **never links to the existing conversation** — it prompts a NEW one; (3) reopen-ongoing
untested; (4) design off (redundant flows, inconsistent spacing). The Owner flagged the feedback
"isn't reflected in the to-do work yet."

## Orchestration (CoS)
- **Triage first** — filed the report as durable tickets ([[work-100]]..[[work-104]]) before any
  fix; PR #98. Renumbered from an initial 097-101 to **100-104** to yield to the parallel
  automation effort (which owns work-097/098/099 with different content); `work:check` green.
- **qa-tester (empirical)** — ran the console; proved the projection/correlation ENGINE sound (a
  planted marker-bearing JSONL correlates + projects + flips the resume control to
  `claude --resume <uuid>`; 37 unit tests). The failure was entirely the launch→folder→marker path.
- **claude-code-guide (docs)** — the launcher scheme is `claude-cli://open?cwd=…&q=…` (param is
  `cwd`, not `folder`); there is **no resume-by-id deep link** (CLI `claude --resume` only).
- **CTO fix** (`cto/threads-launcher-scheme-fix`) — the old link was **fabricated**
  (`claude://code/new?…&folder=…`; neither `code/new` nor `folder` is real → "No folder"). Fixed to
  the official `claude-cli://open?cwd=<abs>&q=<enc>`; hardened folder resolution
  (`resolveControlPlaneHome()` → absolute-real-dir-or-null, honest fallback); removed the
  uncorrelated "resume" control that opened a NEW session. 354/354 green.
- **chief-designer polish** — rebuilt ResumePanel into one state-driven "Your session" panel (one
  primary action per state), fixed the seed double-render, adopted the design-system
  WorkingIndicator, unified the CSS.
- **git-manager** — one console PR, verify→review, **held for the Owner** (not merged).

## Root cause (one line)
The launcher emitted a **fabricated** `claude://code/new?…&folder=…` deep link; the real handler
is `claude-cli://open?cwd=…` — so the seeded session never opened in the right folder, no
marker-bearing JSONL appeared under the scanned root, correlation never fired, and the "resume"
control fell back to opening a NEW session. Fixing the scheme + folder resolution self-heals the
chain; the projection engine was never the culprit.

## Governance / invariants
- **ADR-016 preserved** — zero automated Claude calls; the fix is URL-scheme + local-projection
  only. A proposed **ADR-016 clarification** (launcher seeds a NEW session; Console projects +
  offers CLI resume; no resume-by-id deep link; a resume affordance must never fall back to new)
  is surfaced to the Owner as an **Owner-gated core proposal** — not self-applied ([[invariants]] §I.4).
- **Held for the Owner** — the decisive acceptance (handler registration + click on the Owner's
  Mac) is Owner-machine-only; the console PR is presented, not auto-merged. The Owner experiences
  the milestone.

## Residual risk (headline)
On the Owner's Mac the `claude-cli:` URL handler is currently **unregistered** (no
"Claude Code URL Handler.app"; Claude Code v2.1.275; it installs on the first interactive `claude`
session). Until registered, the Console correctly shows the copyable-command fallback rather than a
broken auto-launch. Step 0 of the acceptance check covers this.
