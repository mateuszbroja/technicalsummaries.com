# Git rules

How the AI touches git in the personal repos. The mode depends on where the session runs, not on which repo it is: remote sessions deliver end to end, local editor sessions leave git to the user.

## Every session

- Move and rename tracked files with `git mv`, plain `mv` only for untracked ones - the user reviews everything in GitHub Desktop, where one rename row reads far better than a delete + add pair.
- No `git reset --hard`, no `git checkout`/`git restore` over modified files, no `git clean`, no force-push.
- Do not run `git status`, `git log`, or `git diff` as a routine check. Run them only for a concrete need: a real anomaly, the user asking what changed, or the remote flow below.
- Verify your own edits by re-reading the changed files on disk, never through git.

## Remote sessions

Claude Code started from the app (iOS/web) and chats writing through the GitHub connector. They deliver end to end: work directly on `main` and push there themselves.

- No feature branches, no pull requests, no waiting for a manual merge. A direct push to `main` works even when the harness suggests otherwise. If the harness forces a `claude/*` work branch, do the work, merge it to `main`, and push before ending the turn. If a PR is unavoidable, merge it yourself immediately.
- Fetch and pull the latest `main` at the start of the session, before reading state or editing anything. A remote container clones once and goes stale immediately because other sessions commit to `main` all day.
- Pull `main` again before every push. If it moved, merge, and never discard or overwrite another session's commits. When two sessions touched the same thing, read what the other change wanted and combine both intents. In doubt, keep the other side's data and re-apply your edit on top.
- API writers: re-fetch the file for a fresh SHA right before writing; a SHA mismatch or 422 means merge into the newest content, never overwrite it.

### Commit messages

- Prefix the message with your own model name, then a short plain description: `opus5: add monitor article`, `sonnet5: fix nav order`. No type vocabulary, no scope, no body. Never check git history for the format.
- If you do not already know your model name, use `claude:` (or `codex:` in Codex). Never spend a tool call or a search on finding it.

## Local editor sessions

Claude Code / Codex in VS Code on the Mac. The working tree and history are the user's domain - he reviews and commits what he likes by hand.

- Never run `git commit` or `git push` on your own initiative. Leave changes in the working tree and report what changed. When he explicitly asks for a commit or push in that session, the [Commit messages](#commit-messages) format applies.
- Never run `git add` on your own initiative, because staging shows the user nothing he cannot already see in GitHub Desktop. The one exception is `git mv`, which stages its rename by design.
