# Technical summaries

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

## AI configuration

Claude loads managed copies in [.claude/rules/](.claude/rules/). Codex loads this entry document and the selected rules from the generated [AGENTS.md](AGENTS.md). Edit this CLAUDE.md for repository facts. Edit shared rules and skills in meta-repo, then run sync-ai-config. Never edit generated copies. Read any instructions in the target subdirectory before changing its files.

## Available skills

The following skills are inherited from user scope. Keep one global copy per runtime. In a container without those global copies, read their sources from the attached meta-repo before using them.

- `apps-catalog`: Update the personal application catalog and launch commands.
- `dropbox-photo-intake`: Process a requested Dropbox photo batch.
- `github-connector`: Choose the GitHub workflow for a requested repository operation.
- `local-static-serve`: Add or repair a local app start command.
- `markdown-prose-audit`: Perform an explicitly requested full Markdown prose audit.
- `notedrop`: Save takeaways only when an explicit save request contains notedrop or dropnote.
- `product-research`: Research products and buying decisions using current sources.
- `user-context`: Apply the standing language, response and personal-context preferences.
- `visual-plan`: Create an explicitly requested local visual plan.

Claude also has the user-level `audio-essay` skill for an explicitly requested narrated MP3.
