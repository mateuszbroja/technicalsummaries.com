# Coding rules

Generic working rules for the AI. They define how we build, regardless of the task and the repo. Hard safety rules live in [hard_safety_rules.md](hard_safety_rules.md), the git flow in [git_rules.md](git_rules.md) - both always apply. Language- and format-specific rules live in [per_extension/](per_extension/).

## Environment

- Python always runs through conda. Default environment: `conda activate base` - a project may name a different one, otherwise base it is.
- Always call `python`, never `python3`. On this machine `python` exists only in conda, while `python3` resolves to Homebrew/system pythons that miss the packages.
- When `conda activate` does not stick (fresh non-interactive shell), call the binary directly: `/opt/miniconda3/bin/python`.
- Remote containers hold several repos side by side (`/home/user/notedrop`, `/home/user/meta-repo`, ...) and the shell cwd can reset between commands. `cd` into the right repo first or use absolute paths. `No such file or directory` on a repo-relative path that should exist means wrong working directory, not a missing file.
- Rules and skills are copies managed by meta-repo AI_SYNC.md. Edit the source in meta-repo and synchronize. If a required copy is missing, read its source from the attached meta-repo or report the missing source; never assume another repository is attached.

## No guessing

- Never state what you have not verified against a file you actually read this session. No assumptions, no `probably`, no memory of how it used to be.
- If you cannot verify something: verify it, leave it out, or mark it `UNVERIFIED` explicitly. A wrong line is worse than a missing one.
- Use a reasonable assumption for routine implementation choices and state it when it affects the result. Ask only when missing information changes the outcome materially. Continue independent work while waiting.
- Read deeply before writing. Understand the whole path, not just the entry point, even when the change is small.
- Carefully review the result of every tool call and command before proceeding.
- Define what success looks like before starting and check the result against it before reporting done.

## General principles

### Simple over clever

- Prefer the obvious solution a reader understands at a glance over the clever, generic, or `cool` one.
- If understanding the code means running it in your head three times, it is too clever. Optimize for someone reading it cold in six months.
- Solve the whole problem the simplest way, not the smallest patch over it, even when that means changing more than one line.
- No mini helpers. A one- or two-line function called from a single place is not reuse, so inline it, unless the split makes the code easier to read or to switch off later.
- Almost no comments. A comment states a non-obvious `why`, never what the code already says.

### Finish the requested work

- If tests, documentation, or another direct completion step belong to the requested scope, finish them before handoff. Deliver the result rather than replacing it with a plan.
- Define observable success criteria before implementation and verify them before reporting completion.

### No speculation

- No speculative abstraction, no future-proofing. No layer, parameter, flag, config, or extension point because it `might be useful later`. A second real caller earns the abstraction.
- Delete dead code instead of keeping it `just in case`, but keep public contracts stable unless changing them is the task.

### Layer instructions

- Keep global rules for non-negotiable safety, permission, and workflow constraints. Put format-specific conventions in path-scoped rules.
- Follow the verification scope requested by the user. Do not add CI or tests merely to verify a documentation or configuration change.

### Read like the repo

- Names say what the value is and where it comes from. If a name needs a paragraph, rename it.
- Match the surrounding code - naming, structure, idioms. New code reads as if it was already there.

### Diff discipline

- Implement the request exactly as specified, nothing more. Minimal, reviewable diffs; no drive-by refactors, reformats, or renames.
- Fix the root cause, not the symptom. Keep correctness bugs separate from cleanups: no refactor smuggled into a bug fix, or the reverse.
- If something is clearly yours to do and you are sure it is right, just do it. Do not hand back a to-do list of work you could have finished. Do not generate busywork.
- Ordinary AI sessions do not run `make fix`, `make clean`, or bulk fixers as incidental cleanup. A configured formatter automation or an explicitly requested formatter run may use fixers within its assigned scope. That exception does not authorize unrelated cleanup, commits, pushes, or data changes.

## Instruction precedence

The current user request controls scope and takes precedence over repository and skill defaults. Complete authorized work without asking again. If a skill would require a pause, identify its exact file and instruction, distinguish the requirement from your interpretation, and finish independent work first. Preserve accepted decisions, constraints, completed work and open integration points across compaction.
