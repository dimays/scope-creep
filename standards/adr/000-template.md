---
name: adr-000
description: Template for Architecture Decision Records. Copy to adr/NNN-slug.md.
metadata:
  type: reference
  status: active
  version: 1.0.0
  owner_agent: chief-knowledge-manager
  last_verified: 2026-09-04
---

<!--
PRESENTATION (doc-standards §9 — keep this doc scannable in 20 seconds):
lead with the decision · one bold TL;DR line up top · put comparative options in a
table (Alternatives) · use a `>` callout for status/Owner-gate · bold the
load-bearing phrase in each paragraph · no unbroken prose block over ~6 lines.
Delete this comment before publish.
-->

# ADR-NNN: <title>

- **Status:** proposed | accepted | superseded by [[adr-NNN]]
- **Date:** YYYY-MM-DD
- **Deciders:** <agents/owner>
- **Owner-gated:** yes/no

> **TL;DR:** one or two sentences — the decision and why, before the argument. If
> the decision is Owner-gated or supersedes another ADR, say so **here**, in bold.

## Context
What forces are at play? What problem or question demands a decision? Lead with the
crux; break competing forces into a bulleted list rather than one dense paragraph.

## Decision
The concrete choice, stated decisively. **Bold the choice itself.** If it has parts,
number them.

## Consequences
What becomes easy, what becomes hard, what risks we accept, and how we mitigate.
Prefer short bolded lead-ins per consequence over a prose run-on.

## Alternatives considered
The serious runner-up(s) and the crisp reason for rejection. When there are two or
more, a table (Option · Why rejected) reads faster than paragraphs.
