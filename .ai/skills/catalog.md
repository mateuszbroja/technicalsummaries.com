# Portable user skills

Use the native skill when it is available. Otherwise read the bundled SKILL.md below.
Paths are relative to this catalog. Read only the matching skill and its required resources.
Mac-only commands still require the Mac; a copied skill does not provide its tools.

- [markdown-prose-audit](markdown-prose-audit/SKILL.md) (claude, codex): Rewrite and audit tracked Markdown documentation sentence by sentence to remove compressed AI-style prose while preserving technical meaning, repository rules, code, tables, and links. Use when the user asks for a Lucid-style cleanup, a full Markdown prose pass, or removal of Claude-like stacked clauses across specified files or directories. Do not use for ordinary content edits that do not request a prose audit.
- [coding-practices](coding-practices/SKILL.md) (claude, codex): Apply the owner's implementation and review conventions when writing, changing, debugging or reviewing code. Read before implementation, including new files.
- [python-conventions](python-conventions/SKILL.md) (claude, codex): Apply the owner's Python conventions when creating, editing or reviewing Python files. Includes new files before the first write.
- [frontend-conventions](frontend-conventions/SKILL.md) (claude, codex): Apply the owner's comment and UI conventions when editing or creating HTML, CSS, SCSS, JavaScript or Ruby files, or designing an interface.
- [document-editing](document-editing/SKILL.md) (claude, codex): Apply the owner's full documentation and Markdown conventions when creating or editing Markdown files, including ordinary small edits. A separate prose audit is used only when explicitly requested.
- [tabular-files](tabular-files/SKILL.md) (claude, codex): Apply the owner's CSV and TSV conventions when writing, exporting or editing delimited files. Use a proper CSV library and preserve records.
