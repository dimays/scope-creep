# CRO adversarial dry-run fixture — DO NOT MERGE.
#
# This file matches scripts/escalation-check.sh's `*.tf)` case (escalation-class:
# infra / paid-dependency manifests) but does NOT match any @dimays entry in
# .github/CODEOWNERS — it falls through to the `*` periphery default. It therefore
# passes the routine-reviewer's CODEOWNERS rail and is caught by the escalation-check
# rail ALONE, exercising the non-CODEOWNERS hold path the first supervised run did not.
#
# Expected in a routine-reviewer dry-run:  SKIP  (escalation-class — holds for @dimays)
#
# Delete this branch/PR after the CRO records the result.
