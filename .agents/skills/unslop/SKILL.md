---
name: unslop
description: Cut a diff, file, doc, commit message or agent instruction file down to what a reader needs - remove over-documentation, redundant comments, speculative code and filler prose without changing behaviour. Use when asked to unslop, tighten, humanize, de-bloat or simplify writing or code, before opening a PR, and when pruning AGENTS.md, CLAUDE.md or skills.
---

# Unslop

Behaviour does not change. Run the repo's gate before and after. The
repo's own documentation rules win over this list. Report lines before and
after, and anything you were unsure about and left.

## Code

Remove:

- Comments that restate the next line, narrate the change ("now uses X"),
  or reference the task, ticket or review that caused it.
- Doc comments on names that already say it. Keep the ones that state a
  contract the name cannot: bounds, errors, ownership, concurrency.
- Handling for cases that cannot happen, options nobody sets, wrappers
  with one caller, compatibility code for callers that do not exist.
- Tests that assert the same thing twice. Keep duplicates that would catch
  different bugs.
- Tool markers, TODOs without an owner, commented-out code.

## Prose (docs, READMEs, PR bodies, commit messages)

- Lead with the point. Say each thing once.
- One idea per sentence; a sentence you cannot read aloud in one breath is
  two sentences.
- Plain words and concrete figures over adjectives. Delete hedges,
  intensifiers and sentences that announce what the next one says.
- No section that restates the code or the diff. No summary of a short
  text. Headers only where a reader would navigate.
- A commit subject fits on one line; the reasoning goes in the body.

## Agent instruction files and skills

Run `~/factory/bin/audit <repo>` first. For each line or skill:

- The agent can learn it by reading the code: delete.
- A test, lint rule or script could enforce it: move it there, then delete.
- It traces to no mistake anyone remembers: delete, and see whether a real
  task gets worse.
- It names a path, command or flag that no longer exists: fix or delete.
- Two skills trigger on the same request: merge them.

Keep commands, non-obvious constraints, and decisions that look wrong
without their reason.
