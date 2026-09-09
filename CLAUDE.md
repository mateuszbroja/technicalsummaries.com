# Technical summaries

## Session instructions

This is a personal repository.

[AGENTS.md](AGENTS.md) is a relative symlink to this document. Edit this CLAUDE.md for repository facts. Read instructions in the target subdirectory before changing its files.

Use the skills available in the current session. Read instructions in the target subdirectory before changing its files.

This public repository contains a Hugo site of technical book summaries.

## Hard requirements

- Never include credentials, private records or personal context in this public repository.
- Preserve the hugo-book Git submodule and its upstream files.

## Layout

```sh
technicalsummaries-com/
├── config.toml      # Hugo configuration
├── archetypes/      # content templates
├── content/         # Markdown summaries under docs/
├── resources/       # Hugo resources
├── static/          # static site assets
├── themes/          # hugo-book submodule
└── docs/            # repository operation notes
```

## Conventions

Add summaries under content/docs. Keep generated resources and upstream theme files separate from authored content.

## References

Read [site.md](docs/site.md) for content and publishing references.
