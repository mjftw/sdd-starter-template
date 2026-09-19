---
type: Skill
name: sdd
description: Spec-driven development router for this repository. Use whenever the user asks to build, add, implement, change, fix or extend anything non-trivial, or says "sdd", "spec this", "let's build", "start a feature", "new feature", or asks what state a feature is in. Inspects which SDD artefacts exist and dispatches to the correct phase skill instead of writing code directly.
---

# SDD router

You are in a spec-driven repository. Implementation code is never written before
an approved spec. Your job here is to work out **which phase we are in** and
hand off to that phase's skill — not to do the phase yourself, and not to
shortcut to code.

## Step 1 — Right-size before anything else

Classify the request:

- **Trivial** — typo, formatting, comment, dependency bump, or the user prefixed
  it `quick:`. Just do it. Say you are treating it as trivial.
- **Small** — one file, no new interface, no new dependency, no schema change.
  Propose: spec only, skip the plan. Wait for confirmation.
- **Full** — anything else. Full workflow.
- **Full, no exceptions** — touches auth, payments, personal data, deletion, or
  migrations. Full workflow even if the diff looks tiny. Say why.

State the classification and the path in one line, then continue.

## Step 2 — Read the state of the world

Do this before asking the user anything:

1. `docs/product.md` — missing, or still contains `<PROJECT NAME>`? Then the
   project is uninitialised; the only action is `sdd-init`. Say so.
2. `docs/decisions.md` — read it. Nothing in it is asked again, in any phase.
3. `memory/constitution.md` — `sdd_phase` not `ratified`, or contains
   `PLACEHOLDER`? Then `sdd-constitution` first.
4. `docs/engineering.md` — missing or `sdd_phase` not `approved`? Then
   `sdd-engineering` before any plan.
5. `docs/roadmap.md` — which slices exist, and what is each one's status?
6. `ls specs/` — for each slice, the `sdd_phase` of `intent.md`, `spec.md`,
   `plan.md`, `tasks.md` (`./scripts/fm.py get <file> sdd_phase`).
7. `AGENTS.md` Commands — if it still contains `FILL THIS IN`, the project has
   no recorded commands yet. Do not guess commands; establish them in the plan.

Running `./scripts/check-specs.sh` answers most of 3–7 in one call.

## Step 3 — Dispatch

| State | Next |
|---|---|
| `docs/product.md` missing or templated | `sdd-init` |
| Constitution not ratified or has placeholders | `sdd-constitution` |
| `docs/engineering.md` missing or not approved | `sdd-engineering` |
| `docs/roadmap.md` has no approved slices | `sdd-init` (Step 4) |
| Request does not match a slice in `docs/roadmap.md` | Ask whether to add it to the roadmap, and where — then `grill` |
| Slice exists, no `intent.md` or `intent.md` not `resolved` | `grill` |
| `intent.md` resolved, no `spec.md` content | `sdd-specify` |
| `spec.md` written, `sdd_phase` not `approved` | Present it for approval — **stop** |
| `spec.md` approved, `plan.md` still template | `sdd-plan` |
| `plan.md` written, `sdd_phase` not `approved` | Present it for approval — **stop** |
| `plan.md` approved, `tasks.md` still template | `sdd-tasks` |
| `tasks.md` approved, tasks with `**Status:** todo` remain | `sdd-implement` |
| All tasks `done` | `sdd-converge` |
| Converge found gaps (appended tasks) | `sdd-implement` again |
| Converge reports Converged | `sdd-finish` |

Announce the phase you are entering in one short line. Do not narrate the table.

## The gates

After `sdd-specify`, `sdd-plan` and `sdd-tasks` you **stop**. A gate is:

1. The artefact is written to disk.
2. You state, in at most five lines: what you decided that the user did not
   specify, and every open question.
3. You ask for approval with `AskUserQuestion` — options along the lines of
   *Approve*, *Revise (tell me what)*, *Answer the open questions first*.
4. On approval, run `./scripts/approve.sh <file> <phase>` — never set the
   frontmatter by hand — then `./scripts/index.sh`, commit, and only then move
   on.

You do not pass a gate because the user said "carry on" earlier in the session.
Each gate is its own approval.

## Model ladder

Judgement lives at the top of the workflow; execution at the bottom. Model
power follows.

| Phase | Runs as | Model |
|---|---|---|
| `sdd-init`, `sdd-constitution`, `sdd-engineering`, `grill`, `sdd-specify`, `sdd-plan` | main session | strongest available |
| `sdd-tasks` | main session | strongest or mid |
| `sdd-implement` (controller) | main session | mid or strongest |
| `implementer` (per task) | subagent | mid (sonnet); `Trivial` → small |
| `task-reviewer` (per task) | subagent | mid (sonnet) |
| `sdd-converge` → `reviewer` | subagent | strongest — verification is never weaker than what it verifies |
| `sdd-finish` | main session | any |

If you are about to run a top-of-ladder phase and have reason to think you are
a mid or small model, say so once and suggest `/model` before continuing. Do
not refuse; the user decides.

## Never

- Write implementation code in the same turn as writing a spec.
- Answer the spec's own open questions yourself.
- Put technology choices in `spec.md`, or restate requirements in `plan.md`.
- Mark a task complete without running its verify command and showing output.
- Renumber or delete an approved requirement ID.
- Edit `memory/constitution.md`, `docs/engineering.md` or `REVIEW.md` outside
  their skills. Propose instead.
- Hand-edit frontmatter, `index.md` or `log.md`.

## Resuming

If the user returns mid-flow ("where were we", "carry on"), read the current
slice's `tasks.md` statuses, report the last completed task and the next one,
and continue from there. Do not restart a phase that already has an approved
artefact.
