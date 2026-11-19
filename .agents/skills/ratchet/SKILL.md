---
name: ratchet
description: Improve something a script can score - speed, memory, size, simplicity, mutation score, fuzz survival, resistance to attack - by looping change, frozen scorer, keep or discard, so the checks only ever get stricter. Use for performance, benchmark, hardening or simplification work, and for any climb on sensitive code. Use climb when only judgement can decide.
---

# Ratchet

Read `hc --skill` first if you have not this session. The builder is never
trusted to grade itself: the scorer and the guards are frozen, and run from
a checkout the builder cannot edit.

## Agree before starting

Ask the user only for what you cannot infer:

- **Score**: one command that prints one number, and which direction is
  better. If none exists, writing it is the first task: do it through
  `ship`, and have the user approve it before any round runs.
- **Guards**: commands that must keep passing (the repo's gate at least),
  and any other number that must not get worse, with its tolerance.
- **Frozen paths**: the scorer, guards, existing tests, vectors and
  fixtures. The builder may add tests; it may not edit or delete these.
- **Noise**: run the scorer five times on the starting commit. A round
  counts only if it beats the best by more than that spread. Skip for a
  deterministic score.
- **Limits**: target value, maximum rounds (default 8), and whether the
  code is sensitive (money, keys, auth, parsing untrusted input).

Work in a worktree. Keep a second, clean checkout of the base branch to run
the scorer and guards from.

## Each round

1. **Build** one change with an `impl-*` agent. Give it the score, the
   current best and the frozen paths. One idea per round.
2. **Check the freeze.** `git diff --name-only <best>..HEAD` must not touch
   a frozen path. If it does, discard the round.
3. **Score from outside.** Run the base checkout's guards, then its scorer,
   against the worktree. Append round, commit, score, guard results and the
   decision to `ratchet/log.tsv`.
4. **Keep or discard.** Keep only if every guard passes and the score beats
   the best by more than the noise. Otherwise reset to the best.
5. **Sensitive code only.** Before keeping, a reviewer from another vendor
   gets the diff and one question: does this change behaviour beyond the
   score, or reach the score by removing a check? A confirmed finding
   discards the round and becomes a new guard test.
6. **Stop** at the target, after three discards in a row, or at the limit.

## Attack rounds

Use when the goal is "nobody can break this" and no number captures it.

1. Start an attacker from a vendor that did not write the code
   (`review-*`; `review-cursor` is a third). Give it the invariants and
   the code, not the author's reasoning. Its only output is a reproducer: a
   test or script that fails.
2. Run the reproducer yourself on the best commit. If it fails there, it is
   confirmed: add it to the frozen guards. If not, drop it.
3. Fix confirmed breaks through normal rounds, where the score is the count
   of failing guards.
4. Stop when attackers from two different vendors in a row confirm nothing
   within the budget.

## Report

The log table, start and best scores with the noise, each discarded round
and why, and every guard added. For attack rounds, say that no break was
found within the budget, never that the code is secure. The user decides
whether to merge.
