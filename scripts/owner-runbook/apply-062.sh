#!/usr/bin/env bash
# apply-062.sh — OWNER-RUN. Applies the work-062 fix to the merge gate so it verifies
# the RIGHT repo's checks (passes --repo through to `gh pr checks`). Gate-surface edit,
# so you run it, not an agent. Idempotent. Operates on repo root $1 (default: cwd).
set -euo pipefail
ROOT="${1:-$(pwd)}"
python3 - "$ROOT" <<'PY'
import sys, os
p = os.path.join(sys.argv[1], ".claude", "hooks", "guard-gates.sh")
s = open(p).read()
if "repo_arg" in s:
    print("  062 already applied"); sys.exit(0)
anchor = 'checks_out="$(gh pr checks $target 2>&1)"; rc=$?'
if anchor not in s:
    print("  ANCHOR NOT FOUND — apply by hand from 062-guard-repo-fix.md"); sys.exit(1)
inject = (
    '# work-062: carry the PR\'s repo through so we verify the RIGHT repo\'s checks, not a\n'
    '    # same-numbered PR in the CWD\'s repo. A URL target self-resolves; --repo covers the\n'
    '    # bare-number form (accepts `--repo x/y` and `--repo=x/y`).\n'
    '    repo="$(printf \'%s\' "$cmd" | sed -n \'s/.*--repo[ =]\\([^ ][^ ]*\\).*/\\1/p\')"\n'
    '    repo_arg=""\n'
    '    [ -n "$repo" ] && repo_arg="--repo $repo"\n'
    '    checks_out="$(gh pr checks $target $repo_arg 2>&1)"; rc=$?'
)
open(p, "w").write(s.replace(anchor, inject))
print("  062 applied — merge gate is now repo-aware")
PY
echo "OK — 062 applied. Verify with a green cross-repo PR whose number also exists as a"
echo "red control-plane PR: 'gh pr merge <n> --repo dimays/scope-creep-console' should now"
echo "check the console PR, not the same-numbered control-plane one. (Commit .claude/ yourself.)"
