---
id: work-012
title: Human-Input Log — v1a (read-model timeline)
type: feature
status: active
priority: high
owner: chief-product-officer
spec: prd-human-input-log
branch: work-012-human-input-log
created: 2026-09-04
updated: 2026-09-05
---
Owner-elevated to top priority and refined into [[prd-human-input-log]] ([[adr-010]]).
**v1a** — the read-model, pure periphery, no gate:

A **Human-Input Log** in the Console (under Work): a spine timeline of the Owner's
inputs from the three **already-captured** sources — `console-chat`
(`conversation_messages` role=owner), `work-request`/`request-reply`
(`request_messages` author=owner), and `feedback` — each an element tagged by
**Source** + **Intent**, interleaved with **interludes** (work between inputs, derived
from git commits + `ledger/`), plus a per-window **leverage** readout (inputs vs.
commits). Terminal (`operator-session`) + gate (`owner-action`) appear as honest
"capture pending" channels (they land in [[work-020]]).

**Acceptance:** a Console timeline over the three captured sources with Source/Intent
tags, deep links to context, git/ledger-derived interludes, and a leverage readout;
reads as narrative, not a dump; owns no data (projection only).
