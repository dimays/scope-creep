---
id: work-038
title: Loops registry (loops.json harvested) + owner_agent lint
type: debt
status: done
priority: medium
owner: chief-knowledge-manager
spec: doc-standards
created: 2026-09-06
updated: 2026-09-06
---
Close the exposure gap's root cause: the harvester generates `agents.json` but **no
`registry/loops.json`**, so Loops are structurally invisible to the Console (Theme 3,
[[prd-transparent-delegation]] sibling / [[prd-console-explore]]).

- Extend `scripts/registry-build.ts` with `buildLoops()` mirroring `buildAgents()`: harvest
  `loops/*.md` → `registry/loops.json` (`{name, kind:"loop", status, description, owner_agent, path}`).
  Loops already carry manifests and `docs:lint` already treats `loops/` as a manifest dir.
- One net-new manifest field: `metadata.mode ∈ autonomous | partially-autonomous | manual`
  (the [[glossary]] already defines it); do **not** structure inputs/outputs/termination.
- `docs-lint.ts`: loop↔registry symmetry check + validate `owner_agent` resolves to a real
  agent (makes every "owned-by" cross-link trustworthy). RAG remains unwarranted.
- **GATED:** the `mode` field + lint rule touch a core standard/record-set → Owner-gated
  ([[adr-013]] §7c, [[decision-rights]]).

**Acceptance:** `registry:check` passes with a generated `loops.json`; `docs:lint` fails on
an unresolvable `owner_agent`. See [[doc-standards]].
