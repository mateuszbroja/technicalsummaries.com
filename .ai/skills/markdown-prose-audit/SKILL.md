---
name: markdown-prose-audit
description: "Rewrite and audit tracked Markdown documentation sentence by sentence to remove compressed AI-style prose while preserving technical meaning, repository rules, code, tables, and links. Use when the user asks for a Lucid-style cleanup, a full Markdown prose pass, or removal of Claude-like stacked clauses across specified files or directories. Do not use for ordinary content edits that do not request a prose audit."
---

# Markdown prose audit

Rewrite the requested documentation so every statement is clear on its first reading. Preserve every unique rule, technical contract, exact identifier, and user decision.

## Required sources

Before editing, read all repository instructions that govern the requested paths. Then load `document-editing` and use the active Lucid style. In a remote session without native copies, read `.ai/skills/catalog.md` and `.ai/lucid.md` from the target repository. The user's current request and the target repository's local rules take precedence when they are more specific.

## Scope

- Resolve every requested repository root and path before editing. Use `rg --files -g '*.md'` to build the exact file list.
- Limit the audit to tracked Markdown files under the named paths unless the user explicitly includes untracked files.
- Exclude generated, vendored, archived, inactive, and legacy areas by default. Also exclude any file whose own instructions prohibit AI edits. Include one only when the user explicitly overrides that restriction.
- Preserve unrelated and pre-existing worktree changes. Never expand the audit beyond the named repositories or paths.
- Read every target file in full before changing it. A search result or diff excerpt is not a substitute for the document.

## Rewrite

Edit the existing documents instead of replacing their structure without cause.

- Give each sentence one claim. Split stacked findings, dropped connectives, and clauses that make the reader restart the sentence.
- Replace label-colon fragments with ordinary sentences. Name the actor or mechanism instead of using labels such as `the fix`, `the flow`, or `the important part` without an introduced referent.
- Delete framing such as `worth noting`, `this matters`, and `the point is`. State the claim directly.
- Remove code glosses that merely restate the previous clause. Promote a gloss to its own sentence only when it adds a separate fact.
- Use a plain `is` or direct verb instead of `serves as`, `acts as`, and similar inflated phrasing.
- Remove repeated conclusions, mirrored negative contrasts, generic summaries, fake depth, and filler. Shorten by dropping redundant claims, never by compressing several claims into fragments.
- Prefer exact names, numbers, paths, fields, and consequences over abstract adjectives.
- Keep headings as short labels. Use lists and tables only when their structure helps the reader compare or follow items.
- Preserve code fences, inline code, command syntax, URLs, link targets, quoted source text, product names, schemas, keys, filenames, and numeric values unless the user asks to change them.
- Preserve exact routing rules and source-of-truth locations. A smoother sentence must not make an actionable instruction vague.
- Keep each unique requirement. When two passages duplicate one rule, retain its clearest authoritative statement and replace the other with a link when needed.
- Describe the current state. Do not add a narrative about the cleanup or the previous wording.

If a sentence is ambiguous, inspect the linked source or surrounding repository before rewriting it. Do not guess what a technical instruction means.

## Verify

Read every changed file from disk after editing. Review it sentence by sentence again, then inspect the full diff against the original.

- Confirm that all field names, model names, commands, paths, numbers, status values, ordering rules, permissions, and exceptions survived the rewrite.
- Check that every added local link resolves. If a former plain-text reference points to a missing file, inspect repository history or the current tree and correct the stale statement when the evidence is conclusive.
- Check that each file has one H1 on the first line, sequential heading levels, blank lines around structural blocks, one final newline, and no trailing whitespace.
- Run `git diff --check` and the read-only character-hygiene scan from the Markdown rules. Fix findings manually and respect its exclusions for code, URLs, link targets, and verbatim text.
- Do not run repository linters, formatters, or bulk fixers unless the user explicitly asks for them.

Finish only when the second read is clear without context from the editing session. The final report states what changed, what was verified, and any excluded file that the user could reasonably have expected in scope.

## Git boundary

A prose-audit request does not authorize staging, committing, pushing, or opening a pull request. Perform those actions only when the user requests them. When authorized, stage the exact audited files, synchronize the target branch without discarding unrelated work, create one requested commit per repository, and never force-push unless the user explicitly orders it.
