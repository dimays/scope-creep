---
id: work-088
title: GitHub write access for the cloud routine — the hard activation blocker for autonomous execution
type: chore
status: superseded
priority: high
owner: cto
spec: prd-autonomous-execution-loop
created: 2026-09-08
updated: 2026-09-23
---
The cloud routine that will run [[work-sweep]] currently has **read-only** GitHub access: a
push fails `403 Resource not accessible by integration`, so it **cannot open PRs**. A scheduled
execution loop whose entire job is *ticket → PR → merge* is inert without write access. This is
the **single hardest activation blocker** for [[prd-autonomous-execution-loop]] — named here so
it is not buried.

This is an **Owner-only provisioning action** — it touches credentials and account/repo
settings ([[invariants]] §III), outside any agent's authority, exactly like [[work-060]]
(branch protection) and [[adr-023]] (restricted identity). The org can *specify* it; the Owner
*executes* it.

Decide + document (a `docs/owner-apply-*` checklist, the [[work-060]] / [[adr-023]] pattern):
- **The mechanism** — grant the cloud routine's credential push + PR-open scope on
  `github.com/dimays/scope-creep` (and `scope-creep-console`, per [[adr-025]]'s sibling
  checkout). Weigh: widening the existing token vs. a dedicated fine-grained PAT / GitHub App
  installation token.
- **Reconcile with [[adr-023]] / [[adr-022]].** Write access must **not** become a way to
  self-clear an escalation hold. The credential may open PRs and push branches, but branch
  protection + required checks ([[work-060]]) must still prevent it from merging an
  escalation-class PR or applying the `owner-approved` marker. Confirm the two designs compose:
  a routine that can *propose* freely but still *cannot dispose* a gate.
- **Honest degradation** — if the credential lacks scope at run time, the routine must surface
  the failure to `needs-you` (as a blocker), never silently drop ready work.

**Gate class — Owner-only.** Credentials + repo settings; the Owner provisions, an agent only
specifies. Blocks [[work-086]] activation.

**Acceptance:** a written `owner-apply` checklist naming the exact scope grant and mechanism;
an explicit statement that the write credential still cannot merge an escalation-class PR or
forge the escalation marker ([[adr-022]]/[[adr-023]] preserved); a defined honest-degradation
behavior when scope is missing. Once applied, the routine can push a branch and open a PR on
the target repos. See [[prd-autonomous-execution-loop]], [[work-086]], [[adr-025]].

---

> **Update (2026-09-20) — checklist delivered; mechanism decided; awaiting Owner
> provisioning.** The acceptance deliverable is written: `docs/owner-apply-github-write-access.md`
> (PR #79), drafted by the C-suite convened 2026-09-20 (Chief of Staff · CTO · Chief Reality
> Officer). **Owner decision:** activation uses a **separate bot identity** — the substance of
> [[adr-023]] (a restricted principal that cannot forge the `owner-approved` marker or merge an
> escalation-class PR) is **folded into this grant as a precondition**, no longer deferred as a
> "later follow-up." The CRO's live-config pass found that a naïve single-identity token grant
> would make the "org merges a change to its own gates" path reachable end-to-end, so the write
> grant **must ship together with the ADR-023 mechanical backstop**. Status stays `proposed`
> until the Owner executes the provisioning (Owner-only). See [[adr-023]], [[work-060]].

> **[2026-09-23] closed → superseded** by [[adr-026]] + [[work-096]]: the cloud routine's reconciled GitHub write access (propose freely, cannot dispose a gate) was delivered by the ADR-026 write-path redesign + [[adr-023]] Phase-2 identity and proven live in the supervised canary ([dimays/scope-creep#119](https://github.com/dimays/scope-creep/pull/119): branches/PRs open as the routine identity; a direct merge is refused 405; escalation holds). This ticket's activation blocker is resolved. See [[ledger-075-stale-proposed-dispositions]].
