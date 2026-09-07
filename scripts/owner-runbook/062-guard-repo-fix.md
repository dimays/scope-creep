# work-062 — fix the merge-gate's repo-ambiguity (Owner applies)

The `gh pr merge` gate in `.claude/hooks/guard-gates.sh` runs `gh pr checks <target>`
**without `--repo`**, so from the control-plane dir it verifies the same-numbered PR in
`scope-creep`, not the repo being merged. Fix: parse `--repo` out of the command and pass
it through (a PR **URL** target already self-resolves, so URL-form merges keep working).

**OWNER-APPLIES** — this edits the gate surface (`.claude/**`), so an agent can't (work-059
+ the classifier both block it). Apply this one edit yourself.

In `.claude/hooks/guard-gates.sh`, find the `*"gh pr merge"*)` case. Replace its first two
lines (the `target=...` line and the `if ! command -v gh ...` block is kept) so it also
captures `--repo`:

```diff
   *"gh pr merge"*)
     target="$(printf '%s' "$cmd" | sed -n 's/.*gh pr merge//p' | awk '{for(i=1;i<=NF;i++){if($i !~ /^-/){print $i; exit}}}')"
+    # work-062: carry the PR's repo through so we verify the RIGHT repo's checks, not a
+    # same-numbered PR in the CWD's repo. A URL target self-resolves; --repo covers the
+    # bare-number form. Accepts `--repo x/y` and `--repo=x/y`.
+    repo="$(printf '%s' "$cmd" | sed -n 's/.*--repo[ =]\([^ ][^ ]*\).*/\1/p')"
+    repo_arg=""
+    [ -n "$repo" ] && repo_arg="--repo $repo"
     if ! command -v gh >/dev/null 2>&1; then
       block "cannot verify PR checks (gh not found) — refusing merge (fail-closed)."
     fi
     # shellcheck disable=SC2086
-    checks_out="$(gh pr checks $target 2>&1)"; rc=$?
+    checks_out="$(gh pr checks $target $repo_arg 2>&1)"; rc=$?
```

Everything else in the case (the `rc -ne 0` block, the messages) is unchanged.

**Verify after applying:** open a green console PR whose number also exists as a red
control-plane PR, then `gh pr merge <number> --repo dimays/scope-creep-console` — it should
now check the console PR (green) and proceed, instead of blocking on the control-plane PR.

After it's applied and verified, flip `work/062-guard-merge-repo-scope.md` to `done`
(or tell me and I'll open that board PR).
