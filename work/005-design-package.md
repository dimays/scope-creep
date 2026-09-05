---
id: work-005
title: Stand up @scope-creep/design
type: feature
status: done
priority: medium
owner: chief-designer
spec: golden-path
branch: work-005-design-package
pr: https://github.com/dimays/scope-creep-console/pull/1
created: 2026-09-04
updated: 2026-09-04
---
Replace the Console's inline CSS-variable token seed with the real semver-pinned
shared design package (tokens + headless a11y primitives) that every app consumes
([[golden-path]] amendment #1).

**Acceptance:** `@scope-creep/design` published; the Console consumes it by version;
tokens no longer duplicated per app.

**Done (2026-09-04):** shipped as `scope-creep-design` (public, tagged **v0.1.0**) —
runtime token layer + `token()` + `VisuallyHidden`, own green gate + ruleset. The
Console consumes `@scope-creep/design/tokens.css` pinned `#v0.1.0` via git and
dropped its inline tokens (merged via gated PR #1, Console 0.4.0). **Distribution
decision:** git-tag (no npm publish needed; works with public repos; semver via
tags) — overridable if the Owner later wants npm. Follow-ups: more headless
primitives; a build/prepare step for JS (not CSS) consumers.
