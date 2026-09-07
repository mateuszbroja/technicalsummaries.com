# Technical summaries

## Session instructions

This is a personal repository. Before working, read [.ai/global_instructions.md](.ai/global_instructions.md) in full unless the identical shared instructions are already present in the session. Use the active Lucid prose style; if it is unavailable, read [lucid.md](.ai/lucid.md). These are explicit read instructions for both local and remote sessions.

[AGENTS.md](AGENTS.md) is a relative symlink to this document. Edit this CLAUDE.md for repository facts. Read instructions in the target subdirectory before changing its files.

Use native skills when available. If a user-level skill is missing, read [catalog.md](.ai/skills/catalog.md) and its matching bundled SKILL.md. This repository has no selected native repository skills. Do not assume another checkout or the owner's Mac is accessible. Managed instruction and skill copies come from meta-repo ai_sync.yaml; edit their sources and synchronize.

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
