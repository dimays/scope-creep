---
id: work-072
title: Cross-thread dedup and clustering in triage
type: feature
status: proposed
priority: medium
owner: chief-product-officer
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The CPO deep-dive from [[prd-end-user-feedback-at-scale]]. Today [[request-triage]] decides
**per thread** and never re-triages an answered thread — so three rephrasings of one want
become three tickets. At the Owner's feedback volume that is the dominant noise source.

**The ask:** before a thread's decide-step, triage checks the ask against **other open/recent
threads and in-flight `work/` tickets**; related asks **cluster** and converge into **one**
tracked work item (or attach to an existing one), rather than spawning duplicates. Decline/
counter/accept/fold still applies — dedup runs **ahead** of it.

**Acceptance:** a batch of paraphrased/related requests yields one work item (or an explicit,
thread-linked cluster), not N; the dedup outcome is written back to each thread so the Owner
sees "folded into …". Deterministic matching first ([[doc-standards]] §7); no RAG unless
[[work-074]] establishes the catalog defeats lookup.

**Trigger:** **T2** (concurrency/volume breach) or **T3** (a measured duplicate-ticket rate),
read from [[work-071]] telemetry. Stays `proposed` until then.
