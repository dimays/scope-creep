---
id: work-069
title: Console markdown-rendering uplift for the Docs/Explore surface
type: feature
status: proposed
priority: high
owner: cto
spec: prd-console-explore
created: 2026-09-07
updated: 2026-09-07
---
Uplift how the **Console renders markdown docs** in the Explore/Docs surface —
typography, spacing, and table/callout styling — so every doc reads as polished and
scannable. This is the **highest-leverage move** on the Owner's "make every page
look this polished" mandate ([[doc-standards]] §9): a renderer change lifts **every
existing doc at once**, with **no rewrite**, including the wall-of-text passages in
[[roadmap-001]] that authoring-side edits alone can't fix retroactively.

**Why this ticket, and why CTO-owned.** Implementation lives in the sibling
`scope-creep-console` repo (Explore/Docs markdown pipeline), which is console/app
code — so the [[chief-designer]] specs the *presentation* and the [[cto]] owns the
*implementation* there. It is captured as a ticket here (not implemented in the
control plane) per that repo boundary.

Build:
- **Typography scale + rhythm** — headings, body, code, and list spacing that make
  hierarchy skimmable; a comfortable measure (line length) and vertical rhythm. Wall-of-text
  prose still reads as structured because the *rendering* gives it air.
- **Tables** — real table styling (zebra/rule/spacing), horizontal-scroll containment
  for wide tables (never a body-level horizontal scroll).
- **Callouts** — `>` blockquotes styled as first-class callouts (the load-bearing-point
  treatment doc-standards §9 check 4 relies on), distinct from quoted prose.
- **Code / rules / lists** — code blocks, `---` rules, and bulleted/numbered lists
  styled for scannability.
- **Sourced from `@scope-creep/design`** — use the shared package's runtime
  CSS-variable tokens for type scale, spacing, and color; **do not hand-roll a
  parallel doc theme** (that would fork taste, against [[golden-path]] amendment #1).
  If a doc-typography token set is missing from the package, add it there, semver-pinned,
  and adopt centrally — the Chief Designer owns that token surface.

**Design constraints (Chief Designer):** theme-inheriting (light/dark via host CSS
variables), token-driven, no per-app copy-in. Renderer must degrade gracefully on any
markdown feature it doesn't specially style (never drop content).

**Acceptance:** the Docs/Explore surface renders an existing unmodified doc (e.g.
[[roadmap-001]] and [[adr-024]]) with clear type hierarchy, styled tables, and
first-class callouts, all driven by `@scope-creep/design` tokens (no hard-coded doc
theme), correct in light and dark. See [[prd-console-explore]], [[doc-standards]] §9.
