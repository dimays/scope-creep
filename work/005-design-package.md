---
id: work-005
title: Stand up @scope-creep/design
type: feature
status: active
priority: medium
owner: chief-designer
spec: golden-path
branch: work-005-design-package
created: 2026-09-04
updated: 2026-09-04
---
Replace the Console's inline CSS-variable token seed with the real semver-pinned
shared design package (tokens + headless a11y primitives) that every app consumes
([[golden-path]] amendment #1).

**Acceptance:** `@scope-creep/design` published; the Console consumes it by version;
tokens no longer duplicated per app.
