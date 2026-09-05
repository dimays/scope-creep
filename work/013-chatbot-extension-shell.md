---
id: work-013
title: Chatbot extension — portable shell (installable)
type: feature
status: active
priority: high
owner: chief-designer
spec: prd-chatbot-extension
branch: work-013-chatbot-shell
created: 2026-09-05
updated: 2026-09-05
---
First clause of [[work-001]]'s split: **installable onto any Golden-Path app.** A
portable Shadow-DOM chat panel (`mountChat(target, options)`) themed by host tokens,
modeled on `scope-creep-ext-feedback`. UI only in this ticket — it renders a chat
thread + input and calls a host-supplied `onSend`; the backend is [[work-014]].

**Acceptance:** the extension installs (git-tag dep) and grafts a themed chat panel
onto a host app; messages render; no host-style bleed. See [[prd-chatbot-extension]].
