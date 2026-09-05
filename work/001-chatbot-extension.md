---
id: work-001
title: Build the chatbot extension
type: feature
status: superseded
priority: high
owner: chief-designer
spec: prd-chatbot-extension
created: 2026-09-04
updated: 2026-09-05
---
The flagship portable Extension: chat that edits an app in a live preview and
merges the change. Must honor the Designer's Shadow-DOM style-isolation standard
and state-preserving live preview.

**Acceptance:** installable onto any Golden-Path app; edits render in-place in a
preview; approving merges via the gated flow.

**Superseded (2026-09-05):** split into a four-ticket epic with its own real spec
([[prd-chatbot-extension]]) — [[work-013]] (shell), [[work-014]] (conversation
primitive), [[work-015]] (live preview, gated), [[work-016]] (propose→merge, gated).
See [[adr-008]], [[adr-009]], and [[ledger-016-work-001-split]]. Work happens in the
sub-tickets; this record stays as the pointer.
