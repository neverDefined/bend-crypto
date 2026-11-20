---
name: ship
description: Take a code change from task to a merge-ready branch with hc agents - implement in a git worktree, pass the repo's check command, and get a review from a different vendor's model. Use when asked to ship, build or delegate a feature or fix through the factory, or to run several changes in parallel across agents or machines.
---

# Ship

Read `hc --skill` first if you have not this session. Templates used here:
`coord-claude`, `impl-claude`, `impl-codex`, `impl-cursor`, `fast-claude`,
`browser-claude`, `review-claude`, `review-codex`, `review-cursor`,
`explain-claude`, `map-claude`.

The repo's own rules win. If it defines how to delegate, review or call
agents (wrapper scripts, a routing table, a runbook), follow that and use
this skill only for what it leaves open.

## Size the task first

Pick the smallest lane that fits. Speed matters: most tasks are not the
full lane.

| Lane | What | Process |
|---|---|---|
| Trivial | docs, comments, renames, config, a diff you can state in one sentence | Do it in this session. Run the focused check or the fast gate. No worktree, no agents, no review. |
| Normal | a feature or fix in ordinary code | Steps below, two review rounds at most. |
| Sensitive | money, keys, auth, protocol bytes, migrations, untrusted input | Steps below, plus the sensitive rules. |

Docs never get a loop or a jury: write them tight, done.

## Who does what

| Work | Runs on |
|---|---|
| Trivial edits | whoever is in session |
| Implementing | `impl-claude` (Opus) or `impl-codex` (`impl-cursor` if asked) |
| Bulk mechanical edits, read-heavy exploration, summaries | `fast-claude`; never for sensitive code |
| Review | the other vendor than the author; Cursor's work goes to `review-claude` or `review-codex` |
| Second review, on diffs that touch keys, signing, auth or amounts | a fresh session of the step 5 reviewer, told to break the invariants |
| Attack round, on code that faces untrusted input | a fresh session of the other vendor's reviewer, with `attack.md` |
| Catch-up for the user on each change | `explain-claude` (Sonnet), from the diff alone |
| Map and start-here page after a change to data flow or assumptions | `map-claude` (Opus) |
| Extra reviewer | `review-cursor`, only when asked; never the only review |
| Coordinating a whole task while you do something else | `coord-claude` (Opus) |
| Intensive planning, a hard design or architecture decision, a bug nobody has cracked | `deep-claude` (Fable, high effort), only through the Fable gate below |
| Browser, screenshots, logged-in web flows, Playwright | `browser-claude --on mini`; see the `herdr` skill |

A repo overrides the Claude implementer, reviewer or coordinator model with
`"env": {"FACTORY_IMPL_MODEL": "..."}` (or `FACTORY_REVIEW_MODEL`,
`FACTORY_COORD_MODEL`) in its `.claude/settings.json`. Do not pin a model
any other way.
Templates set effort and deny rules; do not start agents around them.

**Fable gate.** Fable is for the most demanding work only. Start
`deep-claude` when the user asks for it by name. Otherwise only when all
three hold, and name each in your report:
1. The work is intensive planning, or a design or architecture choice
   that is costly to undo (a schema, a protocol, a module boundary,
   several components at once), or a bug an Opus agent has already
   failed on twice.
2. Opus at high effort would not do: say what it got wrong or why it
   can't hold the problem.
3. It is one bounded question, not implementing, bulk work, review
   rounds, attack rounds or coordinating.
When in doubt, ask the user with `hc send` and carry on with Opus.

Cursor runs in its own sandbox, which blocks `hc send`, and reports no
status to hc. A `*-cursor` launch returns after 60 seconds with
`first_message.sent: false`: `hc send` it the template's body and the task
yourself, naming a report file. `hc wait` on it only times out; check the
report file at each timeout.

Codex on Linux cannot `hc send` either: `hc wait` on it, and its last line
is the path of its report file.

## Steps (normal and sensitive)

1. **Find the gate.** The one command that must pass before anything merges
   (repo agent instructions, Makefile, package scripts, CI config). If the
   repo has none, stop and tell the user; propose one. Nothing ships on an
   agent's word alone. Use the repo's fast gate while iterating and the
   full gate once, at the final commit. Codex and Cursor read `AGENTS.md`,
   Claude reads `CLAUDE.md`. If the repo lacks either, make `AGENTS.md`
   the rules file and `CLAUDE.md` the one line `@AGENTS.md` before
   delegating.
2. **Write what done means.** Two to five acceptance checks a reviewer can
   test, in the task. In the sensitive lane, write them as failing tests
   first.
   If you can do the work yourself in this session, do it, then go to
   step 4. Delegate when the work is large or splits into independent
   pieces, and run those pieces in parallel.
3. **One worktree and one implementer per piece.** Size each piece for
   one implementer in about an hour: a few hundred lines and at most about
   600 outside tests, checkable by the acceptance checks of step 2.
   Estimate before starting; split anything bigger.
   `git worktree add ../<repo>-<slug> -b <slug>`, then
   `hc run --bg --name <slug> --cwd <worktree> impl-<vendor> "<task>"`.
   The task states the goal, the acceptance checks, the scope, what must
   not be touched, the gate command, and `Report with hc send
   $HC_TERMINAL_ID`. Use `--on <machine>` when the repo lives elsewhere or
   the work is heavy (`hc machine ls`). `$HC_TERMINAL_ID` resolves only on
   your own machine: an agent elsewhere needs your full address,
   `$(hc server status | jq -r .core.id)/$HC_TERMINAL_ID`, and you reach it
   by the `<machine>/<t>` address `hc run` returns. UI work gets a
   `browser-claude` check on mini against the running app. When checks share fixed ports or
   one database, name one agent as their owner; the others run only the
   checks that do not collide. If a piece depends on another, start it
   after that one passes the gate. Wait with
   `hc wait --children any --timeout 1800`: agents report with `hc send`,
   so a timeout only means no news, and every wake-up re-reads your whole
   context. Do not poll. `hc read` an agent only when it is blocked, has
   errored, or has been silent for an hour; then nudge it or kill it.
4. **Protect the checks, then run the gate yourself.** The implementer must
   not grade itself. Codex cannot commit from its sandbox: commit its
   work with the message it proposes. List what the branch did to the
   checks and the dependencies: `git diff --stat <base>..HEAD` over the gate script, CI,
   lint and test config, existing tests, and dependency manifests and
   lockfiles. A weakened or deleted check that the task did not ask for
   sends the branch back. A new or bumped dependency needs a reason; in
   the sensitive lane, the user's approval. Then run the gate on the
   final commit with a clean tree. A skipped stage is reported as not run,
   and so is a suite the task depends on that skipped inside a green gate
   (a missing service or binary); rerun it on a machine that has it.
5. **Cross-vendor review**, started while the full gate runs. Claude's work
   goes to `review-codex`; other vendors' work goes to `review-claude`.
   Review in the implementer's worktree once it has stopped; note its
   HEAD first, and afterwards check that HEAD is unchanged and
   `git status` is clean, or discard what the reviewer touched. Give the
   reviewer the original task, the acceptance checks and the commit range,
   not the implementer's summary or vendor. Read its findings once it has
   reported, never while it is still writing them. Run every proof the
   reviewer gives; a finding you cannot reproduce is an opinion. The
   implementer fixes each confirmed finding, adds its proof as a test, or
   disputes it with evidence; if it has already worked for more than about
   an hour, give the findings to a fresh implementer on the same branch
   instead. Rerun the gate and re-review once: two rounds in all. Take what
   is left after that to the user with your recommendation, or split the
   piece; do not run a third round.
   **Attack round**, for code that faces untrusted input: a new listener,
   endpoint, parser or verify function, or paths the repo's rules name as
   public. After the review rounds and before any merge, start a fresh
   session of the other vendor's reviewer with the task, the code and the
   list in `attack.md` beside this skill, plus any the repo's rules add,
   told to break the code rather than review it. Its only output is
   reproducers: run each on the branch. Each confirmed one is fixed and
   kept as a test, and the gate runs again. If Codex's filter stops the
   attacker twice, use `review-claude`.
6. **Catch-up**, for every change outside the trivial lane. Once the
   branch's last commit is final, start `explain-claude` alongside the last
   full gate run, with the task, the commit range, the head commit, the
   repo's GitHub URL and an output path; for UI work, also the page of
   `browser-claude`'s captures. Do not give it the implementer's summary.
   When it reports, run `$HOME/factory/bin/catchup-check <file> <head>` in
   the worktree, then post the file as a PR comment
   (`gh pr comment <n> -F <file>`), or put it in your report when there is
   no PR. It never holds up a merge; one that arrives after the merge is
   posted then.
7. **Map**, on by default; a repo turns it off with
   `"env": {"FACTORY_MAP": "off"}` in its `.claude/settings.json`. Run it
   when the change is in the sensitive lane, changes how data flows (a
   process, service, endpoint, store or connection between parts added,
   removed or rerouted), or changes what the owner can assume (an
   invariant, a trust boundary, who holds a key, when something halts). A
   `## Map` section in the repo's rules replaces this test with its own.
   Start it alongside the Catch-up:
   `git worktree add --detach ../<repo>-map-<slug> <head>`, then
   `hc run --bg --name map-<slug> --cwd <that worktree> map-claude` with
   the repo name, PR number, task, commit range, an output folder and your
   address. Run it on a machine with Floorplan installed
   (`bin/with-floorplan` says how). When it reports, publish
   `<repo>-map.html` with the Artifact tool, put that link in place of
   `MAP_URL` in `<repo>-start-here.html`, and publish that. Publish over
   the artifacts titled `<repo> map` and `<repo> Start Here` when the
   Artifact tool's list shows them, so the owner's links stay the same.
   Without the Artifact tool, report the two paths. Remove the worktree.
   It never holds up a merge.
8. **Report and clean up.** Branch name, gate output, checks not run,
   findings fixed and declined, the Catch-up, the map and start-here
   links, and which model each agent ran (as its CLI shows it). Never
   push or merge unless asked. `hc kill` and `hc rm` the terminals you
   started; leave worktrees that hold unmerged work.

## Questions and steers

Each question to the user states its cost in agent-hours and lines, the
surface it adds (an endpoint, a service, a dependency), the smallest option
and the default you will take. After any steer from the user, check every
queued piece against it and say which you would now drop or shrink; start
none that the steer may cut until the user answers.

## Sensitive rules

- The user approves the invariants before any code: what must always hold
  (amounts conserve, units and decimals, who may touch keys). They become
  failing tests in step 2.
- Prefer checks that do not depend on a reviewer noticing: property tests
  on the invariants, differential tests against an independent
  implementation or official vectors, fuzzing for parsers of untrusted
  input, and a mutation score on the changed files (`ratchet` can drive
  these).
- When the change is hard, run two implementers (one per vendor) on the
  same task and keep the one that passes the gate with the higher mutation
  score; the other vendor reviews it.
- One review per task, as in step 5. A diff that touches keys, signing,
  auth or amounts gets a second review from a fresh session of the same
  reviewer, told to break the invariants rather than review the diff.
  Ask reviewers for suspected problems as well as proven ones.
- Diffs that touch keys, signing, auth or migrations go to the user to
  read before you report the branch ready.

When you correct the same mistake twice, turn the correction into a check
in the repo (a test, lint rule or script the gate runs) and not into more
instructions.
