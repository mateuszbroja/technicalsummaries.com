# technicalsummaries.com — AI Instructions

README.md is the main documentation for this project. Keep it up to date with any structural or functional changes.

Technical book summaries site built with Hugo.

## Structure

```
technicalsummaries-com/
├── config.toml
├── archetypes/
│   └── default.md
├── content/
│   ├── _index.md
│   └── docs/
├── resources/
├── static/
│   └── logo2.png
└── themes/
    └── hugo-book/        # git submodule
```

## Rules

- Hugo static site generator. Content is markdown in content/docs/.
- Theme is a git submodule (hugo-book).
- To add a new summary: create markdown file in content/docs/.
