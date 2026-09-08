---
id: work-073
title: Parallel/sharded triage capacity for the sweep
type: feature
status: proposed
priority: medium
owner: chief-of-staff
spec: prd-end-user-feedback-at-scale
created: 2026-09-07
updated: 2026-09-07
---

The staffing deep-dive from [[prd-end-user-feedback-at-scale]]. The [[request-triage]] sweep
is **one serial triager**; at volume it is the throughput ceiling and a single context can't
hold many apps' state. This ticket gives the CoS a way to **flex triage capacity with the
queue**, driven through [[staffing-review]] and the [[staffing]] standard.

**The ask:**
- A **Triage Analyst** employee template (`kind: template`, owned by [[chief-of-staff]],
  balanced-tier preset per [[resource-budget]]) — the reusable role a sweep summons from.
- The sweep **shards** its queue and fans out to N analysts **only when the queue exceeds a
  bound**, collapsing back to serial when it doesn't. Fan-out is **bounded and
  evidence-triggered** — respecting the CoS's low-fan-out discipline ([[staffing-review]]
  step 1); heavy fan-out is the pattern that has broken sessions.
- Employees stay **ephemeral** ([[adr-020]], [[adr-017]]): summoned for the burst, retired
  after — consistency lives in the template.

**Acceptance:** at a demonstrated queue breach the sweep triages in parallel within its
window and latency stays under [[work-067]]'s bound; template + fan-out policy land via the
gated propose→PR path; every spin-up/retire is CoS-ratified and laddered in the [[ledger]].
Template **creation is CoS-ratified** ([[invariants]] §I.3) — this ticket authorizes the
design, not an ungated spawn.

**Trigger:** **T2** (concurrency/volume breach) from [[work-071]] telemetry. Stays `proposed`
until then.
