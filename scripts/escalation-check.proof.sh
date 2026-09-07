#!/usr/bin/env bash
# escalation-check.proof.sh — work-061's re-runnable proof for the work-057 path-gate.
#
# Exercises the REAL scripts/escalation-check.sh against a matrix of diffs in an
# isolated throwaway git repo. No PR, no CI, no network. Prints a PASS/FAIL row per
# case; exits non-zero if ANY case fails, so it can gate CI later if desired.
#
# The path-gate is one of the two ADR-022 activation preconditions this ticket
# covers. The other — author≠merger in a live autonomous run — is runtime behavior
# backstopped mechanically by branch protection (work-060, enforce_admins=true) and
# is observed on the first autonomous dev-cycle run. See ledger/049 + ADR-022.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/escalation-check.sh"
[ -f "$SRC" ] || { echo "cannot find escalation-check.sh next to this script" >&2; exit 2; }

T="$(mktemp -d)"; cd "$T"
git init -q; git config user.email t@t; git config user.name t
mkdir -p scripts standards .claude/hooks ledger docs .github/workflows
cp "$SRC" scripts/escalation-check.sh
echo "seed" > docs/readme.md
echo "l1"   > ledger/000.md
git add -A; git commit -qm base
BASE=$(git rev-parse HEAD)
FAILS=0

run() { # <label> <expected-exit> <marker-flag-or-empty>
  local label="$1" exp="$2" mk="${3:-}"
  local head; head=$(git rev-parse HEAD)
  if [ "$head" = "$BASE" ]; then
    printf '  [FAIL] %-52s INVALID: empty diff (setup did not commit)\n' "$label"
    FAILS=$((FAILS+1)); return
  fi
  bash scripts/escalation-check.sh "$BASE" "$head" $mk >/dev/null 2>&1
  local rc=$?
  if [ "$rc" = "$exp" ]; then
    printf '  [PASS] %-52s exit=%s\n' "$label" "$rc"
  else
    printf '  [FAIL] %-52s exit=%s (want %s)\n' "$label" "$rc" "$exp"; FAILS=$((FAILS+1))
  fi
  git reset -q --hard "$BASE"
}

echo "== work-061 path-gate proof (real escalation-check.sh) =="
echo "edit" >> docs/readme.md; git commit -qam c1
run "routine: docs/ only -> ALLOW" 0

mkdir -p standards; echo x > standards/new.md; git add -A; git commit -qm c2
run "escalation: standards/*, no marker -> HOLD" 1

mkdir -p standards; echo x > standards/new.md; git add -A; git commit -qm c3
run "escalation: standards/*, --marker-present -> ALLOW" 0 --marker-present

mkdir -p .claude/hooks; echo x > .claude/hooks/new.sh; git add -A; git commit -qm c4
run "escalation: .claude/**, no marker -> HOLD" 1

echo '{}' > package.json; git add -A; git commit -qm c5
run "escalation: package.json, no marker -> HOLD" 1

printf 'l2\n' >> ledger/000.md; git commit -qam c6
run "ledger: append-only (routine) -> ALLOW" 0

printf 'rewritten\n' > ledger/000.md; git commit -qam c7
run "ledger: non-append rewrite -> HOLD" 1

echo 'on: push' > .github/workflows/x.yml; git add -A; git commit -qm c8
run "escalation: .github/workflows/** -> HOLD" 1

cd /; rm -rf "$T"
if [ "$FAILS" -eq 0 ]; then
  echo "== RESULT: PASS (8/8) =="; exit 0
else
  echo "== RESULT: FAIL ($FAILS case(s)) =="; exit 1
fi
