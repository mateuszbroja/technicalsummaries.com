---
paths:
  - "**/*.{csv,tsv}"
---

# CSV and TSV rules

- Always wrap every field in double quotes, even numbers and empty fields; escape a literal quote by doubling it (`""`), never with a backslash.
- UTF-8, a header row, and the same field count in every row.
- Generate and parse only with a proper CSV library (e.g. Python `csv`), never by manual string splitting.
- The delimiter is fixed by the extension - default to `.csv`, no semicolons, no mixed line endings:
  - `.csv` - comma
  - `.tsv` - tab
