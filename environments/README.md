---
name: environments
description: Environment definitions and templates. Each app runs inside exactly one isolated environment.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: cto
  last_verified: 2026-09-04
---

# Environments

An **Environment** is the isolation boundary ([[glossary]]): a namespace of
resources, secrets, filesystem, and datastore. Rules ([[invariants]] §III,
[[tech-sops]] §6):

- Environments are **isolated** — no app reaches another's DB, secrets, or files.
- The default datastore is **never production**.
- Secrets live per-environment, never in the repo, never in Artifacts or the
  [[ledger]].

On the [[golden-path]], an app's environment is one SQLite/libSQL file plus a
per-repo Dockerfile; production is a Fly.io app + volume. Templates land here as the
`new-app` loop matures.
