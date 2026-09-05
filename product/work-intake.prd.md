---
name: prd-work-intake
description: Work History (glance-back) and Work Requests (intake-forward) for the Work tab — the Owner's request-intake loop.
metadata:
  type: project
  status: proposed
  version: 0.1.0
  owner_agent: chief-product-officer
  last_verified: 2026-09-04
---

# PRD — Work History & Work Requests

> **Superseded in part (2026-09-05):** the **Work Requests** half (and its v2 "live
> chat" framing) is superseded by [[prd-cos-threads]] — Requests becomes a thread in the
> unified CoS-Threads surface. **Work History** (glance-back) is independent and stands.
> See [[ledger-028-cos-threads-roadmap]]. This takes effect when the Threads direction is
> Owner-accepted.

Owner-proposed 2026-09-04 (mid-flight during work-006 — itself the motivating
example: the request was *captured*, not dropped). Two additions to the **Work**
surface. Structural call: keep them as **sections under the Work tab** (Board /
History / Requests) rather than proliferating top-level tabs — promote to a tab only
if Requests outgrows it.

## 1. Work History `proposed`
**Problem:** the Owner wants a condensed, glanceable "what got built and in what
order" — a curated feature log, distinct from the raw event ledger.
**v1:** a History section listing shipped major/minor features newest-first, derived
from **done work items** + the **ledger**, each linking to its Work ticket and, where
known, its **GitHub PR**. (Add an optional `pr:` field to the work schema.)
**Success:** the Owner can reconstruct the build story in 20 seconds without the repo.
**Size:** small — mostly a view over existing records.

## 2. Work Requests `proposed` — the key one
**Problem:** the Owner wants a place to *submit a request and discuss it* — where the
system may decline / suggest alternatives / modify / route to the right executive /
ticket it / fold it into the roadmap — and to see and continue past request threads.
Its own **request-intake loop**.

**The request-intake loop (feeds [[ticket-cycle]]):**
`submit → triage (CoS routes; CRO sanity-checks the ask; CPO decides) → outcome
(decline with reason · propose alternative/modification · create/modify tickets ·
fold into a PRD) → respond in the thread`. Terminal; every step hits the [[ledger]].
New scope stays **human-gated** — a request implying a new PRD is a proposal, not an
autonomous ticket.

**Capability ladder (this is the chatbot overlap the Owner asked about):**
- **v1 — request inbox (buildable now):** a submit box on the Work tab + a list of
  request threads. A submission is recorded (like feedback); triage happens
  **asynchronously in the operator session** (me), and the outcome — tickets created,
  or a decline/counter-proposal — is written back to the thread. No in-app agent
  runtime required.
- **v2 — live in-app conversation:** the thread becomes a real-time chat with the
  agents. This needs an **agent runtime in the Console backend** (Claude auth), which
  is exactly the machinery the **flagship chatbot extension ([[work-001]])** builds.
  So Work Requests and the chatbot extension share a **conversation primitive**;
  Requests is the *scoped intake* application (produces backlog changes), the chatbot
  is the *powerful* one (produces code changes + live preview). Build the shared
  conversation surface once; both consume it.

**Success:** the Owner offloads a request in seconds and trusts it's triaged, not
lost — and can see what happened to every past request.

## Sequencing note (CPO)
Work History is a quick win (small). Work Requests v1 (inbox) is high-value and
buildable without new infra; v2 (live chat) rides the chatbot-extension workstream.
Recommend: History soon; Requests-v1 as its own workstream; Requests-v2 folds into
work-001.
