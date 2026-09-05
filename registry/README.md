---
name: registry
description: Generated discovery indexes harvested from manifests. Never hand-edit the JSON.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-04
---

# Registry

The discovery primitive. `agents.json`, `apps.json`, and `extensions.json` are
**generated** by the harvester ([[doc-standards]] §2). **Do not hand-edit the
JSON** — regenerate it:

```bash
bun run registry:build   # scripts/registry-build.ts → registry/*.json
bun run registry:check   # build + `git diff --exit-code` (CI gate)
```

- **agents.json** is generated from the `agents/*.md` manifests.
- **apps.json** / **extensions.json** are reconciled from their registration
  records (written by the `new-app` / extension loops); the harvester validates
  each referenced manifest exists and re-emits deterministically.

Output is deterministic (no timestamps) so `registry:check` is a reliable
"in sync?" gate. RAG/vector search is added only when deterministic lookup over
these indexes actually fails ([[doc-standards]] §7).
