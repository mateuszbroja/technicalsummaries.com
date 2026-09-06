---
paths:
  - "**/*.md"
---

# Markdown rules

Scope: only markdown documents versioned in git (nothing matched by `.gitignore`). Unversioned docs are touched solely on an exact instruction from the user - then these rules apply to them too. Generic - applies to every repo this file is copied into. These rules apply equally to writing new markdown and to editing existing documents. If the user provided contradictory specific instructions - apply the user's ones and keep the rules from here for everything else.

## Creating and updating docs

- Read every target file in full before changing it. A search result or a diff excerpt is not a substitute for the document.
- Leave generated, vendored, archived and legacy documents alone unless the user explicitly includes them.
- When passages repeat a rule, keep its clearest authoritative statement and link to it elsewhere. Preserve every unique requirement.
- The Lucid prose rules apply to chat replies, files, documentation, commit messages, PR bodies and user-facing strings. Read the distributed [prose_style.md](../prose_style.md) when authoring prose.

- Never create new `.md` documents (summaries, reports, notes) unless explicitly asked.
- Edit, do not rewrite. Changing a large share of a document (even ~30%) is fine when the task needs it, but never rewrite or restructure the whole file unless explicitly asked.
- A document describes the current state, never its history. No changelog narrative, no `previously/now`, no future-proofing, no padding.
- Before adding or keeping any information, double-check it is still valid and worth having. If it is not, drop it - do not write it down.
- Do not append near-duplicates: if similar content already lives elsewhere in the document, merge or restructure instead of adding on top.
- Write ordinary paragraphs of complete sentences. Use a list for parallel items, with a full sentence per item, and a table for repeated fields. Link to the source of truth instead of duplicating values.
- Every fact has exactly one home; other files link to it instead of restating it. A doc never describes what the code beneath it already shows.

## Syntax and formatting

### Character hygiene

Outside code blocks, replace with plain equivalents:

- Em-dash (—) and en-dash (–) -> regular hyphen ( - )
- Curly single quotes (‘ ’) -> straight apostrophe ( ' )
- Curly double quotes (“ ”) -> straight double quotes ( " )
- Ellipsis (…) -> three dots ( ... )
- Non-breaking space -> normal space
- Zero-width space and soft hyphen -> delete
- Non-breaking hyphen (‑) -> regular hyphen ( - )
- When in doubt about a character, prefer the plain ASCII form.

These replacements never apply inside code blocks (`` ``` `` fences), inline code (`backticks`), URLs, or link targets - leave those exactly as written there.

Emojis only when they are the content itself (e.g. a doc about emoji), never as decoration or to make text easier to read. Use plain warnings in chat too, as defined in [chat_output_rules.md](../chat_output_rules.md).

### Headings

- Headers in sentence case (`## Ingestion flow`, not `## Ingestion Flow`).
- Exactly one H1, on the first line of the document. Heading levels never skip (`##` -> `####`).
- Blank line above and below every heading. No trailing punctuation in headings.
- No duplicate headings under the same parent section.

### Lists and tables

- Unordered lists use `-`, nested levels indented by 4 spaces, one space after the marker.
- Ordered lists are rare: only when order genuinely matters (steps, rankings). Otherwise use `-`.
- Ordered lists use sequential numbers (`1.` `2.` `3.`), never `1.` repeated for every item.
- Blank line before and after every list block and table.
- Tables have leading and trailing pipes, the same cell count in every row, and aligned columns.

### Code blocks

- Use fenced code blocks with the correct language. For identifiers, DDL, SQL, or shell use `` ```sql `` / `` ```sh ``, not `` ```text ``. Blank line before and after every fenced block.
- Folder/file trees go inside a `` ```sh `` fenced block, formatted like macOS `tree` output.
- Shell snippets show plain commands without `$` prompts, unless output is shown alongside.
- Backtick every inline token: commands (`git commit`), extensions (`.md`), flags, config keys, and quoted example phrases. Backticks render highlighted, quote marks do not. File paths are the one exception: always links, never backticks.

### Links and paths

- No bare URLs - always `[text](url)`, `[text][ref]` with a matching definition, or `<url>`.
- Never write a file path, folder path, or filename in backticks. Write it as a clickable markdown link with a workspace-relative target, e.g. `[report.py](path/to/report.py)` or `[report.py:44](path/to/report.py#L44)`. Applies everywhere, including gitignored paths. Only exception: inside a fenced code block, where it is literal text to copy-paste.
- Skills are the one place where paths are not links. In `SKILL.md` files and their references under `ai/general/skills/`, write every path as a full absolute path in backticks, such as `/Users/mateuszbroja/git/_shared/meta-repo/APPS.md`. Skills load through `~/.claude/skills`, `~/.agents/skills`, and zipped uploads, where a relative link resolves nowhere. A skill that runs in a cloud container names repository-relative paths in backticks instead, because the Mac path does not exist there.
- The link label is the last path component only (`[report.py](src/utils/report.py)`), never the full path. A short two-part target like `site/_config.yml` may keep both parts when that reads better. When the last component alone is ambiguous, add exactly one parent folder - e.g. a list of skills that all end in `SKILL.md`:

```md
[notedrop/SKILL.md](ai/general/skills/core/notedrop/SKILL.md)
[product-research/SKILL.md](ai/general/skills/core/product-research/SKILL.md)
```

### Reference links

External links use the reference form, in tables and in prose alike. The label stays where it is and the URL moves to a definition at the end of that section. The rendered page shows an ordinary one-click link, and the definitions produce no visible text.

- The key is an internal identifier and renders nowhere. Take it from whatever already names the row or the subject - a product code, a model, a size - in lowercase.
- Use a number only when nothing short and unique exists, and treat that number as meaningless. It does not have to run in order, gaps are fine, and a row added in the middle takes any free number.
- Never renumber a file to restore a sequence. It rewrites every row for nothing the reader can see, and on a phone it eats the whole turn.
- Keys must be unique within the file. CommonMark silently uses the first definition when a key repeats, so every later row points at the wrong URL.

A separate line of links below a table belongs to chat replies, where a link inside a cell opens the in-app browser instead of the app. A markdown document keeps the link in the cell.

```md
| `TZe-111` | 6 x 8 | 37,99 zł | [allegro.pl][tze-111] |
| `TZe-121` | 9 x 8 | 49,99 zł | [allegro.pl][tze-121] |

[tze-111]: https://allegro.pl/produkt/rolka-brother-6-x-8-m-1-8ad4c2a8-f286-44b7-a1e9-82c76304888e?offerId=18699720160
[tze-121]: https://allegro.pl/produkt/tasma-laminowana-brother-tze-121-9mm-8m-d6683575-15ef-45f5-aa1c-8b160fd2d2ec?offerId=12356464036
```

### Layout

- Do not wrap sentences across multiple lines. If you see wrapped sentences, unwrap them.
- No trailing whitespace; end every file with a single newline. No hard tabs outside code blocks. At most two consecutive blank lines.
- Emphasis with `*` and strong with `**`, never underscores. Horizontal rules as `---`.

## Self-check

Apply these rules while writing. Ordinary AI sessions do not run fixers as incidental cleanup. A configured formatter automation or an explicitly requested formatter run may use fixers within its assigned scope. Two checks after editing:

- The audit: reread what you wrote and ask `what would still tip a reader off that this is AI-written?`. Fix what you find, then revise once more.
- Invisible or lookalike characters are the one thing rereading cannot catch - spot-check the files you touched with this read-only command:

```sh
rg -n '[\x{2013}\x{2014}\x{2018}\x{2019}\x{201C}\x{201D}\x{2026}\x{00A0}\x{200B}\x{2011}\x{00AD}]|[ \t]+$' <file.md>
```

No output means clean. Fix hits manually per the character hygiene table; remember the replacements do not apply inside code blocks.
