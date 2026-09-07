---
id: work-061
title: QA spike — prove author≠merger + the path-check actually blocks
type: chore
status: proposed
priority: high
owner: qa-tester
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
CRO fix #5 for [[adr-022]] — the verify-before-trust gate. The CRO could not confirm from
docs whether org orchestration ever assigns author and merger to the same agent session;
that is runtime behavior and must be proven, not assumed.

- Empirically confirm **author ≠ merger** holds in a real dev-cycle run.
- Confirm the [[work-057]] path-check actually **blocks** an escalation-class diff (a
  throwaway PR touching e.g. `.claude/` or INVARIANTS must be held).
- Produce the PASS/FAIL artifact.

**Acceptance:** a runnable proof that the independence + path-gate work end to end.
The last precondition before [[adr-022]] flips active. See [[adr-022]].
