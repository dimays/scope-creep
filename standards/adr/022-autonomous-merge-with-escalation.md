---
name: adr-022
description: Owner-directed governance change (PROPOSED) moving the routine PR-merge gate from Owner-approval to independent org review, with a hard-line escalation checklist that HOLDS a PR for the Owner on any financial burden, security risk, substantial C-suite tradeoff, or change to the safety rails / core. Reinforces INVARIANTS §7 (spend absolute) and drafts a §10 amendment superseding-in-part ADR-014. Awaiting Owner ratification — only the Owner amends INVARIANTS.
metadata:
  type: reference
  status: proposed
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-06
---

# ADR-022: Autonomous merge with escalation

- **Status:** **proposed — awaiting Owner ratification.** The INVARIANTS §10 / §7
  amendment drafted here is **not** ratified. **Only the Owner amends the
  [[invariants]]** (§I.2); the exact wording below goes to the Owner. Authored by
  the [[chief-of-staff]] on the Owner's explicit 2026-09-06 direction and
  authorization of an INVARIANTS amendment. Needs (a) an independent
  [[chief-reality-officer]] pass and (b) the Owner's explicit sign-off on the
  exact invariant text **before** it lands.
- **Date:** 2026-09-06
- **Deciders:** **Owner** (directed the change; authorized the INVARIANTS
  amendment; only the Owner amends INVARIANTS, §I.2), Chief of Staff (designed +
  drafted + will record). CRO independent review pending.
- **Owner-gated:** **yes** — this is an INVARIANTS amendment **and** a
  [[core-upgrade]] (it edits `standards/`, core agents, and a core loop). Lands via
  **PR under Owner approval** only. Do **not** self-merge — and, pointedly, this
  very PR is a **safety-rail change and so is non-self-mergeable under its own
  rule** (escalation trigger (d) below).
- **Supersedes in part:** the [[adr-014]] §10 clarification (Owner-approval → the
  Owner's keystroke was already delegated; this replaces **Owner-approval itself**
  with **independent org review**, for routine work, keeping the hard lines at the
  Owner via escalation).

## Context
The Owner is stepping back to chairman / board / sole user ([[adr-018]]) whose job
is driving feedback. [[adr-014]] already moved merge **execution** off the Owner's
keystroke (a ratified [[git-manager]] executes), but kept **Owner approval** as the
gate on every merge. The Owner's 2026-09-06 direction (quoted verbatim):

> "I really can't be hands-off as chairman if I'm approving PRs. I need to trust
> even the employees reporting to my CTO to merge code safely, with independent
> reviews. UNLESS it's truly a high-risk PR in terms of financial burden (NO ONE
> should have ability to purchase or drive additional cost without my explicit
> approval, per the invariants), potential security risks, or a change with such a
> substantial tradeoff or concern among the C-suite that it merits my attention. If
> this requires a change to the invariants, I authorize such a change."

The forces:
- **Approval-on-every-merge is the friction the Owner is removing.** The org
  already owns the review discipline ([[dev-cycle]] Stages 4–6: verify → review →
  land); requiring the Owner to *also* approve each merge adds a step without adding
  a check for **routine** code.
- **The hard lines must not move.** Spend is absolute ([[invariants]] §7). Security,
  substantial tradeoffs, and — critically — **the safety rails themselves** must
  still reach the Owner. An org that can autonomously merge a change to its own
  gates has no gates.
- **The distinction that makes this safe:** *merging code ≠ spending / deploying /
  deleting / publishing.* Those actions stay §7-hook-gated **at the moment of
  execution regardless of how the code landed.** Autonomous merge only removes the
  Owner's *approval keystroke on the merge itself*, only for routine periphery work,
  and only behind a real independent review.

## Decision — the autonomous-merge-with-escalation model

### 1. Default: the org self-merges routine work via **independent review**
A **routine PR** merges **without Owner approval** when it passes the [[dev-cycle]]'s
**independent** review. "Independent" is not a formality — it means all of:
- **Author ≠ merger.** The agent that wrote the diff never lands its own diff. Self-
  merge is prohibited; a separate hand always lands it.
- **A real, separate reviewer.** The [[code-reviewer]] orchestrates the review to
  [[cto]]-set standards ([[engineering-policy]], [[tech-sops]], [[app-contract]],
  [[golden-path]]) — it is not the author and does not rubber-stamp; on budget
  exhaustion it escalates rather than lowering the bar.
- **Proof, not assertion.** The [[qa-tester]] proves the change green **and
  working** with a runnable artifact (PASS/FAIL/INCONCLUSIVE). Green CI is necessary
  but not sufficient.
- **Executed and recorded by the [[git-manager]].** The Git Manager (not the author,
  not the reviewer's stand-in) executes the merge and appends a [[ledger]] entry
  naming the PR, the repo, the reviewer verdict, and the QA artifact.

This three-function finish line — **verify → review → land** — *replaces the Owner's
approval* for routine work, where before ([[adr-014]]) it replaced only the Owner's
keystroke. Everything else about the [[dev-cycle]] is unchanged.

### 2. Escalation triggers — these HOLD the PR for the Owner (still Owner-gated)
Before **any** autonomous merge, the [[code-reviewer]] (with the
[[chief-reality-officer]] on a load-bearing diff) applies the **escalation
checklist** below. **If any trigger fires, the PR is HELD** — not merged — and routed
to the Owner for explicit approval. Escalation is one-way ratchet: any reviewer or
executive may raise a hold; only the Owner clears it.

> **The escalation checklist (apply before every autonomous merge):**
>
> - [ ] **(a) Financial burden / cost / spend.** Does the PR purchase, provision
>   paid infra, add a paid dependency or service, raise a quota/plan, or otherwise
>   *enable or require* cost? → **HOLD.** This is [[invariants]] §7 spend:
>   **ABSOLUTE and unchanged — no one drives cost without explicit Owner approval.**
>   (Note the distinction: *merging* code is not itself spending; but a PR that
>   *enables/requires* spend escalates here, **and** the actual deploy/spend action
>   stays §7-hook-gated at the moment of execution regardless of how the code
>   landed.)
> - [ ] **(b) Security risk.** Does the PR touch **auth, secrets, attack surface,
>   data exposure, or permissions** (new external input path, credential handling,
>   a broadened grant, a new network reachability)? → **HOLD.**
> - [ ] **(c) Substantial tradeoff / C-suite concern.** Is this a load-bearing
>   change with **unresolved C-suite disagreement**, or **above the review's
>   altitude** ([[decision-rights]]) — an architecture reversal, a
>   scope/roadmap-level call, a change that would set precedent? → **HOLD** (route
>   to [[decision]] / the Owner).
> - [ ] **(d) A change to the safety rails or the core themselves.** Does the PR
>   edit the **[[invariants]]**, the **`guard-gates` hook**, **`.claude/` gate or
>   permission config**, a **permission grant** (`settings*.json` allow-rules), the
>   **decision-rights / escalation model**, or **the core** ([[invariants]] §I.4 —
>   charter / core agents / loops / standards / registries)? → **HOLD** (a
>   core-touching PR escalates exactly like an INVARIANTS change). **The org may not
>   autonomously weaken its own gates.**
>
> If **every** box is clear → the PR is **routine** and merges on independent review
> (§1). If **any** box is checked → **HOLD for the Owner.** When in doubt, escalate;
> the checklist is a floor, not a ceiling.

### 3. The hard lines are preserved ABSOLUTELY (reinforced, not loosened)
- **[[invariants]] §7 is untouched and reinforced.** `deploy` / spend / `delete` /
  publish require the **actual Owner at the moment of action**; the **`guard-gates`
  hook stays UNCHANGED** and still blocks them mechanically. A **red gate is never
  waivable by an agent** — only the Owner waives red ([[engineering-policy]] §1).
  Autonomous *merge* changes none of this: it removes the Owner's approval on the
  **merge**, not on any §7 action.
- **The [[ceo]] cannot self-authorize a gate or a core-upgrade** ([[adr-018]]) — and
  cannot approve an autonomous merge that has escalated. A delegated role is not the
  Owner; only the Owner clears a hold.
- **Core-upgrades still require explicit Owner approval** ([[invariants]] §I.4).
  Autonomous merge is for **periphery / app code and non-core work only.** A
  core-touching PR escalates under trigger (d) and lands only under Owner approval,
  exactly as an INVARIANTS change does. The **core-vs-periphery line is the escalation
  line**: periphery self-merges; core escalates.

## The exact proposed INVARIANTS amendment (PROPOSED — awaiting Owner ratification)

> **PROPOSED — awaiting Owner ratification; only the Owner amends INVARIANTS
> ([[invariants]] §I.2).** The text below is a **draft for the Owner to apply**, not
> a ratified edit. `charter/INVARIANTS.md` is deliberately **left untouched** in this
> PR — the locked file stays locked; the Owner applies this text on ratification.

### §10 — replace the ADR-014 clarification block with:

```diff
 10. **Every change is reversible.** All work lands via branch + review + gated
     merge. Nothing is destroyed without the owner and a ledger entry.
-    > **Clarification (Owner-approved 2026-09-06, [[adr-014]]):** The gate on a
-    > **PR merge** is (a) a **green CI gate** and (b) **Owner approval** — not the
-    > Owner's keystroke. Once the Owner approves a merge (in conversation, whether
-    > implicitly or explicitly), a **ratified git-manager / developer agent** may
-    > *execute* that merge on any Scope-Creep repo and record it in the [[ledger]].
-    > Approval is the gate; execution may be delegated. This refines §7's "only the
-    > owner disposes" for merges — the owner disposes by **approving**. It does
-    > **not** loosen §7's other gates: `deploy` / spend / `delete` / publish still
-    > require the Owner at the moment of action (the `guard-gates` hook still blocks
-    > them). A **red** gate is never waivable by an agent — only the Owner waives a
-    > red gate. See [[decision-rights]].
+    > **Clarification (Owner-ratified 2026-09-06, [[adr-022]] — supersedes in part
+    > the [[adr-014]] clarification):** A **routine PR merge** is gated on (a) a
+    > **green CI gate** and (b) an **independent org review** — no longer on Owner
+    > approval or the Owner's keystroke. *Independent* review means: the **author is
+    > never the merger**; the [[code-reviewer]] orchestrates the review to
+    > [[cto]]-set standards; the [[qa-tester]] proves it green **and** working with
+    > an artifact; and the [[git-manager]] executes the merge and records it in the
+    > [[ledger]]. This is the [[dev-cycle]] finish line — **verify → review → land**
+    > — and the org may self-merge **routine periphery / app / non-core** work.
+    >
+    > **Escalation — these HOLD the PR for the Owner and are NOT self-mergeable.**
+    > Before any autonomous merge the reviewer applies the escalation checklist; if
+    > **any** trigger fires the PR is **held** and routed to the Owner for explicit
+    > approval: **(a) any financial burden / cost / spend** — a PR that would
+    > purchase, provision paid infra, add a paid dependency, or otherwise drive cost
+    > (this is §7: **no one drives cost without explicit Owner approval — absolute
+    > and unchanged**); **(b) security risk** — auth, secrets, attack surface, data
+    > exposure, or permissions; **(c) substantial tradeoff / C-suite concern** — a
+    > load-bearing change with unresolved C-suite disagreement or above the review's
+    > altitude ([[decision-rights]]); **(d) a change to the safety rails or the core
+    > themselves** — the INVARIANTS, the `guard-gates` hook, `.claude/` gate or
+    > permission config, a permission grant, the decision-rights / escalation model,
+    > or the core (§I.4). The org **may not autonomously weaken its own gates.**
+    >
+    > This does **not** loosen §7's other gates: `deploy` / spend / `delete` /
+    > publish still require the Owner at the moment of action, and the `guard-gates`
+    > hook still blocks them mechanically. A **red** gate is never waivable by an
+    > agent — only the Owner waives red. Core-upgrades still require explicit Owner
+    > approval (§I.4). Execution may be delegated to a ratified [[git-manager]]; the
+    > **review**, not the Owner, now disposes of a routine merge. See
+    > [[decision-rights]], [[dev-cycle]], [[adr-014]].
```

### §7 — reinforcing edit (make the merge-vs-spend distinction explicit):

```diff
 7. **Irreversible or outward-facing actions are human-gated.** Deploying to
    production, spending money, deleting data, and publishing require explicit
    owner confirmation at the moment of action. Agents may *propose*; only the
-   owner *disposes*. These gates are enforced mechanically (hooks + branch/PR
-   flow), not by agent goodwill. See [[app-contract]] and [[tech-sops]].
+   owner *disposes*. These gates are enforced mechanically (hooks + branch/PR
+   flow), not by agent goodwill. **Merging code is not itself one of these
+   actions** — a routine merge lands on independent org review (§10) — **but a PR
+   that *enables or requires* spend, a deploy, a delete, or a publish escalates to
+   the Owner** ([[adr-022]]), and the actual `deploy` / spend / `delete` / publish
+   action stays Owner-gated at the moment of execution **regardless of how its code
+   landed**. **No agent — and no delegated role, the [[ceo]] included — may drive
+   cost without explicit Owner approval.** See [[app-contract]] and [[tech-sops]].
```

### Front-matter — bump the version:

```diff
 metadata:
   type: reference
   status: active
-  version: 1.2.0
+  version: 1.3.0
   owner_agent: human-owner
   last_verified: 2026-09-06
```

## Consequences
- **The Owner stops approving routine PRs.** The org's own verify → review → land
  discipline (author ≠ merger, real reviewer, QA proof, ledger record) is what lands
  routine periphery work. The Owner's attention is spent only where a trigger fires.
- **The hard lines are *more* explicit, not weaker.** §7 spend is reinforced as
  absolute; safety-rail and core changes now **auto-escalate by rule** (trigger (d)),
  closing the "the org could quietly merge a change to its own gates" hole that no
  prior doc named.
- **Blast radius is bounded.** Autonomous merge = *merge only*, *periphery/non-core
  only*, *green + independently reviewed only*, *never a §7 action*. The
  `guard-gates` hook and every §7 gate are untouched.
- **Two enforcement layers stay honest** (as [[adr-014]] noted): this ADR is the
  **org-policy** layer. The **harness-permission** layer is separate — whether the
  [[git-manager]] can run `gh pr merge` without a prompt depends on a
  `settings.local.json` grant the Owner applies. The policy alone does not silence
  the prompt; that is intentional defense-in-depth. **Recommended additional rail:**
  the escalation checklist should become a *mechanical* pre-merge check (a CI/hook
  step that fails the merge if a diff touches INVARIANTS / `guard-gates` /
  `.claude/` / a paid-dependency manifest without an Owner-approval marker), so
  trigger (d) especially is enforced by more than reviewer goodwill. Flagged for the
  CTO as a follow-up; not built in this PR.
- **Reversible.** The Owner collapses this with one line + a [[ledger]] entry
  (supersede this ADR; INVARIANTS §III.10 reverts to the [[adr-014]] clarification).

## Alternatives considered
- **Keep Owner-approval on every merge ([[adr-014]] as-is).** Rejected by the Owner:
  it is the exact friction the chairman is removing; the review discipline already
  provides the check.
- **Fully autonomous merge with no escalation.** Rejected outright — it would let the
  org spend, expose security surface, or weaken its own gates without the Owner. The
  escalation checklist is the whole point.
- **Escalate by reviewer judgment alone, no checklist.** Rejected: a load-bearing
  gate cannot rest on ad-hoc judgment. The checklist makes the triggers mechanical
  and auditable (and should later become a literal CI check — see Consequences).
- **Let the CEO approve escalated merges in the Owner's place.** Rejected outright:
  breaches [[adr-018]] / [[invariants]] §I — a delegated role is never the Owner and
  cannot clear a hold or self-authorize a gate.
- **Edit `INVARIANTS.md` in this PR (flagged as proposed).** Rejected for safety: the
  locked file stays pristine so no proposal text can be mistaken for ratified law or
  slip in on a merge. The exact draft lives here and in the PR body; the Owner
  applies it on ratification.
