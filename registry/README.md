---
name: registry
description: Generated discovery indexes harvested from manifests. Never hand-edit the JSON.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-06
---

# Registry

The discovery primitive. `agents.json`, `loops.json`, `apps.json`, and
`extensions.json` are **generated** by the harvester ([[doc-standards]] §2). **Do
not hand-edit the JSON** — regenerate it:

```bash
bun run registry:build   # scripts/registry-build.ts → registry/*.json
bun run registry:check   # build + `git diff --exit-code` (CI gate)
```

- **agents.json** is generated from the `agents/*.md` manifests.
- **loops.json** is generated from the `loops/*.md` manifests (`{name, kind:"loop",
  status, description, owner_agent, path}`); `docs:lint` checks it stays symmetric
  with `loops/` and that every `owner_agent` resolves to a real agent.
- **apps.json** / **extensions.json** are reconciled from their registration
  records (written by the `new-app` / extension loops); the harvester validates
  each referenced manifest exists and re-emits deterministically.

Output is deterministic (no timestamps) so `registry:check` is a reliable
"in sync?" gate. RAG/vector search is added only when deterministic lookup over
these indexes actually fails ([[doc-standards]] §7).

## The one hand-maintained exception: `routines.json`

**`routines.json` is Owner/CoS-maintained by hand, not generated.** It is a
**projectable memory** of the org's time-scheduled **cloud routines** — the
recurring cron-fired runners created and managed at `claude.ai/code/routines/…`
that clone this repo and open PRs (per routine, on cadence, for a loop). Their
**system of record is claude.ai, not this repo** — there is no in-repo manifest a
harvester could read (a routine is created in claude.ai's UI, not by a PR), so
the usual "never hand-maintained" rule ([[doc-standards]] §2) doesn't apply the
same way: there is nothing to generate *from*. `routines.json` is instead a
deliberate, documented exception, kept honest three ways:
- `_generated: false` on the file itself says so plainly, and `scripts/
  registry-build.ts` never reads or writes `routines.json` — `registry:build` /
  `registry:check` leave it untouched (no clobber risk).
- `docs:lint`'s registry-integrity pass (`scripts/docs-lint.ts`) does not include
  `routines.json` in its `_generated === true` check — that check is scoped to the
  files the harvester owns.
- Update it by hand (Owner or Chief of Staff) whenever a routine is created,
  rescheduled, or retired in claude.ai, and bump the file's `updated` date.

Each entry names the routine's `loop`, `trigger_id`, `cron`, `cadence_bounds_days`,
`model`, `source` repo, and `manage_url` (a link-out only — [[adr-016]]'s
zero-Claude-call rule means the Console can project this but never drive the
routine). The **live** self-tuned cadence and run history are deliberately *not*
duplicated here — they live in the named loop's [[ledger]] `cadence-decision`
blocks, which is what actually changes run to run; `routines.json` only records
the stable identity of each routine. Event-driven loops (`dev-cycle` and friends)
have no routine and so no entry here — see `loops.json` for the full loop set.
