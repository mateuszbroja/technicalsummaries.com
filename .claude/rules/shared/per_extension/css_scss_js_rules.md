---
paths:
  - "**/*.{css,scss,js,rb,html}"
---

# CSS, SCSS and JS rules

## Code comments

- Zero comments is the target. A file earns at most a handful of short English lines, each stating a constraint invisible from the code: a non-obvious reason, a workaround, a business rule, or a safety choice.
- Never narrate code, label sections, repeat names, describe appearance, preserve history, or restate what a doc owns.
- Write for AI.

## UI

- The accent stripe, a colored `border-left` or `border-top` edge on a card, tile, or row used to color-code it, is banned everywhere. Color-code with a subtle background tint instead: `background: color-mix(in srgb, var(--accent) 9%, var(--surface))`.
