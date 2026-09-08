---
id: work-083
title: Owner-action item source model & read-model — where do Owner-action items come from as data?
type: feature
status: proposed
priority: high
owner: cto
spec: prd-owner-action-notifications
created: 2026-09-07
updated: 2026-09-07
---
The hard question behind [[prd-owner-action-notifications]], ticketed as a [[cto]] deep-dive
so it is **decided, not assumed**: *where do Owner-action items come from as data?* The
surface ([[work-063]]) and the row schema (the PRD) are settled; the **source layer** is not.

## Decide (produce a recommendation + the read-model spec)
Weigh the candidate sources and recommend a model:
- **`owner-apply-*.md` convention** — the Console already reads the sibling core repo
  read-only via `SCOPE_CREEP_HOME` (`app/lib/explore.server.ts` `home()`), so scanning
  `docs/owner-apply-*.md` is cheap and ADR-016-clean. **Gap:** no "pending vs applied"
  signal exists — depends on the convention in [[work-084]]. Covers activation steps +
  pending owner-apply docs.
- **GitHub PR state** — escalation PRs missing the `owner-approved` marker; open `ledger-*`
  PRs. **This is a new read surface:** the Console reads *local files* today, not live
  GitHub. A read-only PR read is permitted ([[adr-016]] forbids automated *Claude* calls,
  not git/GitHub *state* reads) but the CTO must decide the mechanism (`gh` CLI vs GitHub
  API vs a generated local projection), the auth posture, and **honest degradation** (a
  GitHub outage must surface, never silently drop the Owner's plate — the `work-065`
  degradation precedent).
- **Owner-gated ticket / STOP states** — derivable from `work/` frontmatter + guard-gates;
  weigh against double-counting items already surfaced as their PR.
- **Activation checklist** — the provision/register steps in the `owner-apply` docs; decide
  the machine-readable shape that turns checklist prose into rows.

## Recommend + spec
- **Recommend a source model** (the CPO's starting position is a hybrid, convention-first
  model — owner-apply docs as primary via [[work-084]], PR-derived items as a read-only
  GitHub read — but the CTO disposes).
- **Spec a single pure `buildOwnerActions` read-model** that unions the chosen sources into
  the PRD's row schema (action / why / link / kind / source-ref / done-state), mirroring
  `buildNotifications` in `app/lib/threads.ts` so ordering, dedup, and **done-detection**
  (when does an item clear?) are unit-testable in one seam.
- **Respect [[adr-016]]:** zero automated Claude calls — item text is projected from
  existing docs/PR state, never summarized by a Claude call from the app.

## Gate class — escalation (decision / proposed ADR)
This ticket produces a **decision**. If it lands a `standards/` convention or an ADR (e.g.
blessing a read-only GitHub read surface for the Console), that is escalation-class and
**holds for the Owner** ([[adr-022]] trigger d — core/standards; and trigger b if the PR
read touches auth/secrets). The read-model *code* that follows is agent-buildable periphery.

## Dependencies
Depends on the shipped surface ([[work-063]]) — must not duplicate it. Frames the convention
[[work-084]] implements (sync expected). Blocks the render ticket [[work-085]], which needs
the read-model shape.

**Acceptance:** a written recommendation naming the source model for each of the four
Owner-action kinds ([[prd-owner-action-notifications]]); an explicit, [[adr-016]]-respecting
decision on the PR-read surface with its degradation behavior; and a spec for the pure
`buildOwnerActions` union builder (inputs, row schema, ordering/dedup, done-detection) ready
for [[work-085]] to build against. Any `standards/`/ADR output is flagged escalation-class,
not self-merged.
