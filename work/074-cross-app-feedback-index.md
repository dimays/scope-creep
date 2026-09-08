---
id: work-074
title: Cross-app feedback knowledge index
type: feature
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The CKM deep-dive from [[prd-end-user-feedback-at-scale]]. Under [[adr-024]] each app owns its
**own** thread store, so a triager on thread N in app X has **no way to know** about a related
thread M in app Y. As the suite goes multi-app that lost context is where duplicate and
conflicting decisions come from.

**The ask:** a **generated, deterministic** suite-wide feedback index over all apps' thread
stores — keyed by app + theme — that triage and the Owner's plate can query for "related asks
elsewhere." Discovery-first, in the CKM tradition: **fixed-shape index + grep/registry
before embeddings** ([[doc-standards]] §2, §7). The index is **read-only synthesis across
stores** — never cross-app write reach ([[invariants]] §9); each store stays isolated.

**Acceptance:** given feedback in ≥2 apps, a triager can retrieve related items across apps
deterministically; the index is regenerated, never hand-maintained ([[doc-standards]] §2). A
**RAG escalation** is opened **only** if catalog size demonstrably defeats deterministic
lookup, and then **only** via a `proposed` ADR stating the trigger ([[doc-standards]] §7) —
the CKM's call.

**Trigger:** **T1** (the 2nd app ships), with **T4** (observed context loss) expediting it.
Stays `proposed` until then.
