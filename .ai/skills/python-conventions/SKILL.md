---
name: python-conventions
description: "Apply the owner's Python conventions when creating, editing or reviewing Python files. Includes new files before the first write."
---

# Python conventions

Use `coding-practices` for the execution environment and implementation workflow.

- Max line length 120.
- Prefer namespace packages. Add `__init__.py` only when an import or packaging contract requires it, and preserve existing package entry points unless the task includes their removal.
- No module docstrings at the top of files.
- Function docstrings very rare: only when they carry real, non-obvious information, and always one line.
- Type hints very rare: only where they genuinely help the reader. Clean code over annotation noise.
- Constants are the config of the file: values worth tweaking (paths, thresholds, settings) and anything hardcoded or repeated go at the top as constants, always `UPPER_CASE`, so the user changes them without digging through code.
- Functions over classes. A class must justify its existence; if in doubt, no class.
- Never write tests or test files. No test frameworks, no `pytest`, no test directories. Throwaway scratch checks to verify your own logic are fine, but nothing test-shaped lands in the repo.
