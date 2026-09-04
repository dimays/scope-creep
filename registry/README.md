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
**generated** by harvesting every `MANIFEST` / front-matter block in the ecosystem
([[doc-standards]] §2). **Do not hand-edit the JSON** — regenerate it:

```bash
npm run registry:build   # harvests manifests → registry/*.json
```

The generator does not exist yet (v0 seed). Until it lands, the JSON files are
seeded by hand *as a bootstrap only* and carry `"_generated": false`. The first
build flips them to generated. RAG/vector search is added only when deterministic
lookup over these indexes actually fails ([[doc-standards]] §7).
