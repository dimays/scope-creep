---
name: adr-004
description: Establish the Chief Product Officer as a fifth core C-suite agent, owning product vision, requirements, project management, and the feedback loop.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-of-staff
  last_verified: 2026-09-04
---

# ADR-004: Establish the Chief Product Officer

- **Status:** accepted
- **Date:** 2026-09-04
- **Deciders:** Owner (directed), Chief of Staff (ratified)
- **Owner-gated:** yes

## Context
The core org had four executives (CoS, CTO, Chief Designer, CKM) — coverage for
orchestration, architecture, design, and knowledge, but **no one owning *what to
build and why***. For a system whose premise is unbounded scope, the absence of a
dedicated product function means requirements stay implicit and the roadmap rides
on whoever is loudest. The Owner directed creating the role.

## Decision
Add the **Chief Product Officer (CPO)** as a fifth core C-suite agent. The CPO owns:
product vision and rigorous requirements (specs under `product/`); the decision on
project-management tooling/process; the design of when/how the Console asks the
Owner for feedback (a candidate Extension); product metrics; and — with the CKM —
agent-eval design. The Owner remains the sole user and the source of feedback and
roadmap inspiration; the CPO turns that signal into buildable requirements, never
fabricating demand.

## Consequences
- Clear ownership of the product surface; requirements become explicit and testable
  (feeding the honest-tests rule in [[engineering-policy]] §6).
- The core org is now five; org changes remain CoS-ratified ([[adr-002]]).
- First CPO deliverables: a project-management recommendation, and the
  [[prd-console-explore|Explore PRD]].

## Alternatives considered
- **Fold product into the CoS or CTO** — rejected: product judgment is a distinct
  discipline; bundling it dilutes both.
- **No CPO; Owner writes all requirements** — rejected: the Owner supplies signal
  and direction, but rigorous, maintained requirements are ongoing work a dedicated
  agent should own.
