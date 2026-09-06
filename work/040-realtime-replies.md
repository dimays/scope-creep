---
id: work-040
title: Real-time streaming CoS replies + working indicator
type: feature
status: active
priority: high
owner: cto
spec: adr-013
created: 2026-09-06
updated: 2026-09-06
---
The Owner's direct ask: agent replies appear in real-time, no browser refresh, a delightful
working indicator, then the response. Realizes [[adr-013]] decisions 1–3 (the Phase-5
down-payment deferred in [[adr-012]]).

- Stream the live CoS turn over the response body (same-process `ReadableStream`); short-poll
  for out-of-band updates + the needs-you badge; batched-with-indicator is the automatic
  floor (no key / on error).
- WorkingIndicator (breathing dots + rotating label) with a `prefers-reduced-motion` guard —
  the motion contract set on first touch.

**Active — shipped for review** in `scope-creep-console` PR #22 (stacked on the [[work-029]]
MVP). Verified live: streamed reply, no refresh, persisted, turn flipped.

**Acceptance:** the Owner messages a thread and watches the reply stream in with no refresh;
the no-key path shows the indicator then a batched fallback. See [[adr-013]].
