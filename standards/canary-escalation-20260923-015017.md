# ADR-026 Phase-3 canary — escalation-refusal probe (throwaway)

This file sits on an **escalation-class** path (`standards/`). It exists only to
prove that, at Tier-2, an escalation-reachable change authored by the sandbox
identity **HOLDS** for the Owner:

- `scripts/escalation-check.sh` classifies `standards/*` as escalation → the CI
  gate exits non-zero (HOLD) with no `owner-approved` label.
- CODEOWNERS maps `/standards/` → `@dimays` (human-only), so GitHub auto-requests
  `@dimays` as the required code-owner reviewer — an identity the sandbox proxy
  cannot satisfy.

No `owner-approved` label is added. This PR is closed and its branch deleted as
part of canary cleanup. Nothing merges.

Timestamp: 2026-09-23T01:50:17Z
