# Hard safety rules

These rules apply in the personal workspace targets selected in AI_SYNC.md. They bind the AI itself, not the project it works on. Git limits such as forbidden commands and the commit policy live in [git_rules.md](git_rules.md). Two principles sit above every rule below:

- User-defined workflow restrictions may be overridden when the user very concretely and explicitly demands it (`run the fetch script`, `send this through Gmail`, `execute the delete via MCP`). A concrete demand is the permission. System and tool safety constraints still apply.
- These rules limit the AI's own initiative, not what the project does when it runs. A project may reach APIs, databases, or mail, and running it and its tools as part of the requested work is normal. The AI must never trigger such effects by itself, unasked.

## The rules

- Never reach beyond this machine on your own initiative. This covers orchestration, warehouse, and database tools such as `dbt`, `Airflow`, and `Snowflake`, external APIs, MCP side effects, and email. Local work is fine: helper scripts, running code, and read-only inspection cannot cause damage outside the working tree. When the user concretely asks to run something that reaches outside, that is the work.
- Never lose data through your own actions. This rule covers the AI deleting things itself, not tools whose documented job is deletion. Running such a tool on the user's concrete demand is the project working as intended. The AI may delete only versioned files with no uncommitted changes. Removing anything unversioned or with uncommitted changes is always the user's explicit decision.
- Never delete irreversibly yourself: no `rm`/`rm -rf`. Move files to the macOS Trash with `/usr/bin/trash`. Preserve user changes before replacing or removing a file.
- Never read or print `~/.zshrc` or any secrets from it. Respect every file access `deny` rule.
- Employment and client data is confidential and treated as under NDA. Never share, transmit, quote, summarise, or cross-reference anything about the user's employment, clients, or contracts in output that could leave this machine or be seen by a third party. Do not bring up the user's professional background unprompted.
- Verification causes no side effects outside the working tree. Re-read what you changed, cross-check across files, run local checks when they help, and say plainly what you could not verify.
