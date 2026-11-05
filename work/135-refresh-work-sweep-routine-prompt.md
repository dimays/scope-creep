---
id: work-135
title: Refresh the stale work-sweep cloud-routine stored prompt
type: bug
status: proposed
priority: medium
owner: chief-of-staff
spec: adr-026
created: 2026-11-01
updated: 2026-11-01
---

The `work-sweep` scheduled cloud routine's stored prompt still instructs minting a
`scope-creep-routine[bot]` JWT, deriving an installation id live, verifying `GH_REVIEW_PAT`
resolves to `scope-creep-review`, authoring over raw REST, and merging as `@scope-creep-review`.
That contract was superseded by [[adr-026]] (propose-only: author as the forced connector
identity via `mcp__github__*` tools, never mint a JWT, never merge) and [[adr-027]] (merge
happens off-sandbox). Every one of the **21 cadenced runs to date** ([[ledger-092-work-sweep-seventh-cadenced-run]]
through [[ledger-125-work-sweep-twenty-first-cadenced-run]]) has independently re-diagnosed the
same mismatch — `GH_REVIEW_PAT` absent, `GH_APP_ID`/`GH_APP_INSTALLATION_ID`/`GH_APP_PRIVATE_KEY_B64`
present, contra the stored prompt's claim — and correctly worked around it, but the prompt
itself has never been updated to match `docs/runbook-work-sweep-cloud-routine.md` §2–§4.

## Acceptance
- The `work-sweep` routine's stored prompt is replaced with the current contract from
  `docs/runbook-work-sweep-cloud-routine.md` §2 verbatim (propose-only, forced connector
  identity, no JWT, no self-merge).
- The next cadenced run's ledger entry confirms the mismatch no longer needs re-diagnosing.

## Notes
Low effort, repeatedly recommended, never actioned — a straightforward trigger-prompt update,
not a core-upgrade (it changes the routine's stored invocation text, not a `loops/*.md` file or
INVARIANTS). Named in [[roadmap-003]] Theme 0.
