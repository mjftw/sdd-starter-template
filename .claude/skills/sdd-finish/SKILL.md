---
type: Skill
name: sdd-finish
description: Close out a converged slice — choose merge, pull request, keep the branch, or discard; attach the convergence report; update roadmap status to shipped; clean up worktrees. Use after sdd-converge reports Converged, or when the user says "finish", "ship it", "open the PR", "merge this", "we're done with this slice". Adapted from obra/superpowers finishing-a-development-branch (MIT).
---

# Finish

Runs only after `sdd-converge` has reported **Converged** for the slice. If it
has not, stop and say so.

## Confirm the state

1. `git status` clean; every task `**Status:** done`; `tasks.md`
   `sdd_phase: complete`; `spec.md` `sdd_phase: implemented`; the convergence
   report at `.sdd/reports/<slice>/converge.md`.
2. `check` command green, run now, output shown.
3. `./scripts/check-specs.sh` clean for this slice.

## Ask — one question, four options, recommended first

Per `docs/engineering.md` §13, recommend the one it names. Options:

- **Open a pull request (Recommended when a remote exists)** — push the
  branch; PR title `<slice>: <spec title>`; body = the spec's Outcome, the
  requirement list with ✅, the convergence report, the notes fold-back
  (ADRs proposed, amendments made). `git push` is denied to agents in
  `.claude/settings.json`; ask the user to push, or give the exact commands.
- **Merge locally** — `git checkout main && git merge --squash <branch>` (or
  `--no-ff` per §13), commit with the slice summary, delete the branch.
- **Keep the branch** — nothing merged; say why (waiting on another slice, on
  a decision). Record it in the slice's `docs/roadmap.md` row.
- **Discard** — only if the user says so explicitly, twice. Never recommend.

## After

- `docs/roadmap.md`: slice status `shipped` (or `converged` if kept).
- `./scripts/index.sh`, and commit the roadmap change.
- Worktree, if used: `git worktree remove ../<repo>-<slice>`.
- `.sdd/briefs/<slice>`, `.sdd/reviews/<slice>`: delete.
- Say in three lines: what shipped, what the next slice on the roadmap is,
  and any open item carried forward. Offer `grill` for the next slice.
