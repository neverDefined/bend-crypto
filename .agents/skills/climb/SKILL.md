---
name: climb
description: Improve something that has no test - UI look and feel, product copy, API ergonomics - by looping build, blind multi-vendor jury, keep or discard, until the jury ranks it level with the best references or progress stalls. Use when asked to hill climb, polish, or iterate on quality that is a matter of judgement.
disable-model-invocation: true
---

# Climb

Read `hc --skill` first if you have not this session. Use `ship` for what
a test can decide and `ratchet` for what a script can score; this loop is
costly. Never use it for documentation: one `unslop` pass is the limit.

## Agree before starting

Ask the user only for what you cannot infer:

- **What is judged**: screenshots of named screens, a rendered doc, etc.,
  and the command that captures it.
- **Rubric**: three to five criteria in the user's words, and any kind of
  feedback to ignore (for example "never add explanatory copy").
- **References**: one to three best-in-class examples. The measure is the
  gap between ours and the best reference, as scored by the same judge in
  the same round; absolute scores drift.
- **Limits**: a deadline by the clock, maximum rounds (default 5), and
  paths that must not change.

Keep two branches: the best version that passed, and the candidate. The
repo's gate must pass before a round is judged.

## Each round

1. **Capture** the candidate into a folder outside every worktree. When
   only a real browser can capture it, use `browser-claude --on mini`.
2. **Judge blind.** Build a sheet folder holding only the rubric and the
   unlabelled candidates (ours and the references, in random order); the
   key that says which is ours stays outside it. Start a fresh
   `review-codex` and `review-claude` with that folder as their working
   directory, plus `review-cursor` or a local model if one is at hand. They
   see no repo, no builder notes and no earlier scores. Each writes
   `{scores: {candidate: {criterion: 1-10}}, problems: {candidate: []}}`.
   To save usage, start with one judge and add the second when its gap
   stops closing.
3. **Promote or discard.** If the gap did not widen, the candidate becomes
   the best. Otherwise reset the candidate to the best and reuse the last
   promoted round's problems.
4. **Build** the next candidate from the problems the judges agree on,
   dropping the kinds the user ruled out. One `impl-*` agent per
   independent area, each in its own worktree, merged only through the
   gate.
5. **Stop** when ours is level with the best reference on every criterion,
   after two discards in a row, or at the deadline or round limit.

The builder never judges, and judges never carry over between rounds. If
the loop will run for hours, put the mechanics (sheet, key, score, gate,
deadline) in tested scripts in the repo and let a runbook drive them.

## Report

The best round, before and after captures, the gap per round, and what the
jury still dislikes. The user decides whether to merge.
