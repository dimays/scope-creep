---
id: work-061
title: QA spike — prove author≠merger + the path-check actually blocks
type: chore
status: done
priority: high
owner: qa-tester
spec: adr-022
created: 2026-09-06
updated: 2026-09-06
---
> **DONE (2026-09-06) — path-gate PROVEN, author≠merger backstopped + deferred.**
> Re-runnable proof `scripts/escalation-check.proof.sh` exercises the real
> `escalation-check.sh` over an 8-case matrix (incl. an empty-diff guard that caught a
> false pass): **8/8 PASS**. author≠merger is runtime behavior with no live autonomous
> run yet — mechanically backstopped by [[work-060]] `enforce_admins`, to be observed +
> ledger-recorded on the first autonomous dev-cycle run. See
> [[ledger-049-rails-060-061-activation-gate]].

CRO fix #5 for [[adr-022]] — the verify-before-trust gate. The CRO could not confirm from
docs whether org orchestration ever assigns author and merger to the same agent session;
that is runtime behavior and must be proven, not assumed.

- Empirically confirm **author ≠ merger** holds in a real dev-cycle run.
- Confirm the [[work-057]] path-check actually **blocks** an escalation-class diff (a
  throwaway PR touching e.g. `.claude/` or INVARIANTS must be held).
- Produce the PASS/FAIL artifact.

**Acceptance:** a runnable proof that the independence + path-gate work end to end.
The last precondition before [[adr-022]] flips active. See [[adr-022]].
