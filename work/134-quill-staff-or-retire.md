---
id: work-134
title: Dispose of Quill — stage onto doc-debt work or retire (idle 32+ days past its own flag)
type: debt
status: proposed
priority: medium
owner: chief-knowledge-manager
spec: adr-021
created: 2026-10-26
updated: 2026-10-26
---

Surfaced by the staffing-review loop's first real run ([[staffing-review]],
[[ledger-117-staffing-review-first-run]]). [[quill]] (technical-writer, summoned
2026-09-06) was corrected `active → idle` on 2026-09-24 with a note that it has
**never been staffed to a ticket** and that the CKM should either staff it to
doc-freshness/doc-debt work or retire it — "held for CoS/Owner." That was 32 days
ago. Nothing has changed: Quill is still `idle`, `grep -il quill work/*.md` still
returns zero matches, and the matching work is still sitting unstaffed in the CKM's
own queue: [[work-123]] (console + design doc-debt refresh, `proposed` since
2026-09-24, untouched) and [[work-120]] (doc-freshness maintenance loop, `proposed`,
last touched 2026-10-01 for an unrelated endorsement). CRO-checked (this run):
verified — not speculative; Quill's idleness, the zero-ticket state, and the open,
in-scope, same-executive work are all independently confirmed against the repo.

This is a durably-idle employee per [[staffing]] §2 ("an employee that lingers idle
is drift the staffing-review loop flags") — a retire-or-restaff candidate, not a
new kind of work.

## Acceptance
The CKM disposes of Quill one of two ways, landed as a gated diff:
- **Restaff:** set `assignees: quill` on [[work-123]] (and/or [[work-120]] once its
  loop-vs-fold question is resolved) and flip Quill's `metadata.status` to `active`
  on its employee manifest; or
- **Retire:** flip Quill's `metadata.status` to `retired` with a one-line reason
  (never `rm`, [[invariants]] §III.10) — summon a fresh [[technical-writer]] when
  doc work next needs staffing.

Either way, closes the loop on the 2026-09-24 note rather than leaving it open
another cadence.

## Notes
This loop proposes and tickets only ([[staffing-review]] step 6); it does not
execute either disposition itself. Low urgency/low risk (no user-visible impact,
one idle employee), so `priority: medium` — but it is the kind of staffing drift
this loop exists to catch and close out promptly once flagged.
