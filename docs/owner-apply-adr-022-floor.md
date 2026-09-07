# Owner-manual step — revoke the blanket merge grant (work-058)

The floor rails for ADR-022 (work-057 escalation-check + work-058 merge gate) are
built and land in this PR. One piece **cannot** ship in the PR and must be applied
by the Owner: revoking the blanket `Bash(gh pr merge *)` permission grant.

## Why this is a manual step (not in the diff)

`.claude/settings.local.json` is **gitignored** (`.gitignore` line 10) and is
per-checkout, so it is not tracked and cannot appear in a PR diff. This is exactly
the "strongest grants live in a file the review can't see" hole the CRO named in
ledger/048; bringing these grants in-band is work-059's job. Until then, the
revocation is applied by hand.

## What to change

In `/Users/davidmays/code/scope-creep/.claude/settings.local.json`, delete the
`"Bash(gh pr merge *)"` line so the file reads **exactly**:

```json
{
  "permissions": {
    "allow": [
      "Edit(.claude/settings.local.json)",
      "Write(.claude/settings.local.json)",
      "Write(.claude/hooks/**)"
    ]
  }
}
```

## What this does

With the blanket grant gone, a `gh pr merge` is no longer auto-approved: it prompts
the Owner **and** is inspected by the `guard-gates` hook, which now blocks the merge
unless every required check (including the work-057 escalation-check) is green
(fail-closed). That is the "gated path" that replaces the blanket grant.

## When it takes effect

The `guard-gates.sh` hook is loaded at **session start**. The new hook logic (the
`gh pr merge` gate and the added spend/deploy blocklist entries) and this grant
revocation both take effect on the Owner's **next session** after this PR merges
and the grant edit is saved. They do not alter the currently running session.

## Residual gap (be honest)

Under today's shared GitHub identity, the escalation-check's `owner-approved` label
marker is agent-forgeable (an agent with `gh` can add the label itself). These rails
make escalation mechanical, auditable, and fail-closed against accidental/unreviewed
merges, but they are **not** un-spoofable against a deliberate agent. True
un-forgeability requires identity/token separation — a restricted agent token that
cannot self-label or self-approve, distinct from the Owner's token (work-059).
