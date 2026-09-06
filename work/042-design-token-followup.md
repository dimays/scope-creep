---
id: work-042
title: Verify + close the --sc-success a11y follow-up deferred by work-027
type: debt
status: proposed
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
