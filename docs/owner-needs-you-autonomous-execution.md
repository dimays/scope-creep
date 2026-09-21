# Owner needs-you — unlock unattended autonomous execution

> **The answer up front:** **5 ordered Owner-only actions** stand between today and the roadmap
> building itself unattended. Key rotation is **already done** (you rotated the leaked
> `scope-creep-routine` App key 2026-09-21 — closed). Everything the org could build is built and
> **holds for you** in two PRs. This page is the milestone hand-off.

**What changed since [[work-088]]:** the sandbox proxy makes the old "separate bot author" path
impossible in the cloud ([[ledger-066-cloud-sandbox-proxy-identity-wall]]). [[adr-026]] replaces it
with **propose-only**: grant the **shared Claude GitHub App** scoped write; the routine proposes as
that identity; **merge stays yours/local** because that identity can never present as the sole
code-owner `@scope-creep-review`. The write-provisioning checklist
(`docs/owner-apply-github-write-access.md`) is amended to **Part 1′** for this.

---

## The 5 steps (in order)

### (a) FIRST — verify the Claude App permission manifest. This is a safety gate, not a formality.
**Why:** propose-only is safe **only if** the shared Claude GitHub App cannot edit the gates
themselves. If its manifest carries **Administration**, **Workflows**, or **Actions** write, an
interactive/injected claude.ai session could rewrite branch protection or `.github/workflows/*` and
the entire code-owner merge-block collapses. That manifest is Anthropic's, **not ours to trim** — so
it must be **checked**, never assumed.
**Do:** inspect the Claude GitHub App installation's repository permissions for `dimays/scope-creep`
and `dimays/scope-creep-console`.
- **`Administration` / `Workflows` / `Actions` write present → HARD STOP.** Do not grant write; the
  propose-only guarantee does not hold. Bring it back to the CTO/CRO.
- **`Issues` write present → acceptable, recorded residual.** Merge is still blocked; it is noted only
  for the [[adr-023]] Phase-2 marker-integrity concern.
- **Clean (only Contents/PR/Metadata) → proceed to (b).**

### (b) Grant the Claude App scoped write — `docs/owner-apply-github-write-access.md` **Part 1′**
**Why:** the routine (forced to act as this identity in-sandbox) needs write to open PRs.
**Do:** grant the Claude GitHub App **Contents: Read+write** and **Pull requests: Read+write**,
scoped to **only** `scope-creep` + `scope-creep-console`. Leave everything else at No access. No new
token to store — installation tokens are minted per run.

### (c) Run the strengthened un-pause criteria in-sandbox — [[adr-026]]
**Why:** the decisive test (does `POST /pulls` succeed under the proxy *with* write, and is the
resulting PR held from merge?) **cannot be run without the grant** — so it is the acceptance test,
run once write is live. Do **not** un-pause on assertion.
**Do:** run the **6 machine-checkable un-pause criteria** in ADR-026. Note especially **criterion #3
is now a hard gate**: it records the *full* granted permission surface and **blocks un-pause** if
Administration/Workflows/Actions write is present (this is the mechanical backstop for step (a)).
Un-pause only when all six pass — including an actual throwaway PR opened by the proxy identity and
confirmed **unmergeable** by branch protection.

### (d) Register / un-pause the routines — **board-hygiene FIRST (canary), then work-sweep**
**Why:** `board-hygiene` is the lowest-blast-radius routine (it only edits `work/*.md` status
fields). Un-pausing it first **proves the propose-only path end-to-end** — routine opens a PR →
you/local merge — **before** `work-sweep` is trusted to drive real builds.
**Do:** register/un-pause per the **registration spec** below. Registration is programmatic (the CoS
can drive the schedule tooling); **your approval is the gate** ([[adr-021]]) — it turns on recurring
API spend ([[invariants]] §III).

### (e) Merge the two held PRs — **#96** then **#97**
**Why:** both are escalation-class core changes ([[adr-022]] trigger (d)) and correctly **hold for
you**; nothing self-merged.
**Do:** merge **PR #96** (PM maturity — the `review` state + board-hygiene loop) and **PR #97**
(ADR-026 write-path + corrected runbook + amended owner-apply). Glance at PR #97's rendered top-banner
anchor link while you're there (a cosmetic check).

---

## Registration spec (you execute; the org specifies — never fabricated ahead of a real trigger)

| Field | **board-hygiene** (register first) | **work-sweep** (un-pause after canary proves out) |
|---|---|---|
| Loop | `loops/board-hygiene.md` | `loops/work-sweep.md` (already registered, `paused`) |
| Source | `github.com/dimays/scope-creep` | same |
| Topology | `scope-creep-console` sibling checkout; env `scope-creep-local` ([[adr-025]]) | same |
| Runtime | Node (`npm run …`), **not bun** (proxy drops bun's fetch) | same |
| Cron seed | `0 15 * * *` (daily; offset from work-sweep's `0 16` and the 14:00 planning cluster) | `0 16 * * *` (unchanged) |
| `cadence_bounds_days` | `[0.5, 7]` | `[0.5, 7]` (unchanged) |
| Model | `claude-sonnet-5` | `claude-sonnet-5` |
| Write path | Propose-only per ADR-026 (opens one hygiene PR; you/local merge) | Propose-only per ADR-026 |
| Un-pause gate | ADR-026's 6 criteria (criterion #3 = hard manifest gate) | same, **and** board-hygiene canary proven first |

After each is live, record its real `trigger_id` / `cron` / `cadence_bounds_days` in
`registry/routines.json` (a small follow-up PR — never a fabricated `trigger_id`) and log it in the
[[ledger]].

---

## What you get to poke around at once done

- **A matured board.** Tickets move **to-do → in-progress → in-review → done**, with the new
  **in-review** column surfacing what is code-complete and awaiting merge (Console column is
  ticketed as [[work-099]]). [[work-097]] already dogfoods it.
- **A board that keeps itself honest.** `board-hygiene` wakes daily, reconciles status↔reality,
  flags WIP-cap breaches and stale backlog, and proposes one tidy hygiene PR — routine backlog
  pruning, running on its own.
- **The roadmap building itself.** Once `work-sweep` un-pauses, ready tickets are picked up in
  priority order and driven ticket-by-ticket to `review`/`done` on independent review, pausing to
  `needs-you` **only** at a real blocker or a defined milestone — and you find the whole story
  in-thread.

## Known residual (stated plainly)
Propose-only **relocates** the [[adr-023]] Phase-2 risk off-sandbox; it does **not** close it. An
unattended `@scope-creep-review` reviewer identity can still satisfy the code-owner merge, and (if the
Claude App carries Issues/label write) forge the escalation marker. Closing it is a human-only
code-owner on core/escalation paths — a separate follow-up, named in ADR-026 §residuals.

---

Reference: [[adr-026]] · `docs/owner-apply-github-write-access.md` (Part 1′) ·
`docs/runbook-work-sweep-cloud-routine.md` · [[ledger-068-scheduled-execution-automation-cycle]] ·
PRs #96, #97.
