---
id: work-043
title: Verify + close the --sc-success a11y follow-up deferred by work-027
type: debt
status: superseded
priority: low
owner: chief-designer
spec: prd-console-explore
created: 2026-09-06
updated: 2026-09-06
---
Surfaced by the [[level-set]] dry run ([[ledger-038-level-set-dry-run]]). [[work-027]]
explicitly deferred one item: "`--sc-success` + `.req-submit` contrast deferred pending
the palette decision." [[work-041]] subsequently promoted `--sc-success` into
`@scope-creep/design` (Owner-gated palette change), but nothing has re-checked or closed
the original a11y deferral against the now-shipped token — [[work-041]]'s own record
carries no **Done** note confirming what shipped or that the deferred contrast check was
run.

- Confirm `.req-status--accepted` / `.chip--feedback` actually route through the shipped
  `--sc-success` token (not still hardcoded).
- Run the contrast check work-027 deferred; fix if it fails.
- Append the missing **Done** note to [[work-041]] (or a ledger entry) recording what
  actually shipped, so the record stops implying more verification happened than did.

**Acceptance:** `--sc-success` usages pass contrast; work-027's deferred item is closed
with an honest note, not left silently unresolved. See [[work-027]], [[work-041]].

**Partial (2026-09-06, console #31):** the token adoption shipped — every hardcoded
`#3aa76d`/`#e8833a` now routes through `--sc-success`/`--sc-attention`, and the per-component
reduced-motion blocks were removed (the package owns that contract). Contrast measured
against the shipped token: **dark mode passes AA; light mode does NOT** (`--sc-success` as
text ≈3.03:1, and ≈2.5:1 over the chip tint — below AA 4.5:1; light `--sc-attention` ≈2.71:1
has the same issue). Per charter (tokens are the design-package's contract; taste lives
centrally), the light-mode fix was NOT hardcoded in the console — it belongs in
`@scope-creep/design` (darken the light on-surface text values or add on-surface variants,
then a v0.2.x tag). Filed as a design-repo follow-up.

**Superseded (Owner decision 2026-09-06):** the Owner scrapped light mode entirely ("I'll
never want light mode") — see [[work-045]]. Dropping light mode makes the light-contrast fix
moot (dark mode already passes AA), so this ticket is closed as superseded rather than fixed.
The in-flight design-repo chip that was fixing light-mode contrast is superseded by [[work-045]]
(dark-only) — cancel it or let it finish harmlessly; the dark-only work is the real task.
