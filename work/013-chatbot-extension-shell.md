---
id: work-013
title: Chatbot extension — portable shell (installable)
type: feature
status: done
priority: high
owner: chief-designer
spec: prd-chatbot-extension
branch: work-013-chatbot-shell
pr: https://github.com/dimays/scope-creep-console/pull/5
created: 2026-09-05
updated: 2026-09-05
---
First clause of [[work-001]]'s split: **installable onto any Golden-Path app.** A
portable Shadow-DOM chat panel (`mountChat(target, options)`) themed by host tokens,
modeled on `scope-creep-ext-feedback`. UI only in this ticket — it renders a chat
thread + input and calls a host-supplied `onSend`; the backend is [[work-014]].

**Done (2026-09-05):** shipped `scope-creep-ext-chatbot` (public, v0.1.0) — a
framework-agnostic Shadow-DOM chat graft themed by host tokens, `textContent`-safe.
Grafted onto the Console's new **Chat** tab (0.8.0, gated PR #5) with a labeled stub
`onSend`; verified send → echo end to end. Registered in `extensions.json`.

**Acceptance:** the extension installs (git-tag dep) and grafts a themed chat panel
onto a host app; messages render; no host-style bleed. See [[prd-chatbot-extension]].
