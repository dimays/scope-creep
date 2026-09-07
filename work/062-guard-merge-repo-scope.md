---
id: work-062
title: guard-gates gh-pr-merge check is repo-ambiguous (cross-repo PR-number collision)
type: bug
status: proposed
priority: medium
owner: cto
spec: adr-022
created: 2026-09-07
updated: 2026-09-07
---
Found live during the overnight eng-loop (2026-09-06→07). The [[work-058]] merge gate in
`.claude/hooks/guard-gates.sh` extracts the PR **number** from `gh pr merge <n>` and runs
`gh pr checks <n>` — but **without `--repo`**, so the check resolves against whatever repo
the hook's CWD maps to (the control plane, `CLAUDE_PROJECT_DIR`), **not** the repo the merge
targets. When a `scope-creep-console` PR shares a number with a *red* `scope-creep` PR, the
gate blocks the wrong PR: merging console **#49** (green) was refused because scope-creep
**#49** (the ADR-022 activation PR) is intentionally red awaiting the Owner.

- **Impact:** a false-positive block (fail-safe, not fail-open) whenever PR numbers collide
  across repos and the control-plane PR of that number is red/pending. It silently "worked"
  all night only because the colliding numbers happened to be green.
- **Workaround used:** merge by full PR **URL** (`gh pr merge https://github.com/dimays/<repo>/pull/N`)
  — the guard's `gh pr checks <url>` then resolves the correct repo.
- **Fix:** make the gate repo-aware — parse `--repo` (and a PR URL) from the command and pass
  it through to `gh pr checks`, or refuse a bare number when the CWD repo ≠ the target repo.
  Touches the gate surface (`.claude/**`) → escalation-class, Owner-gated ([[adr-022]] (d),
  [[work-059]]); propose via `docs/owner-apply-*` or an Owner-applied edit.

**Acceptance:** the merge gate verifies the checks of the PR actually being merged, in the
correct repo, regardless of CWD or PR-number collisions; a green cross-repo PR is not blocked
by a same-numbered red control-plane PR. See [[work-058]], [[ledger-051-overnight-eng-loop]].
