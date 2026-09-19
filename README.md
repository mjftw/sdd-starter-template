<!-- sdd-starter-template -->
# sdd-starter

A GitHub template for building software with AI agents, spec-first, where
**you are the source of truth and the agent is the hands.**

Create a repo from it, open your coding agent, and say what you want to build.
The agent interviews you — relentlessly, one question at a time, always with a
recommended answer — until it understands the product, the domain, and how you
like code written. Then it works down through the levels of abstraction:
product brief → bounded contexts → vertical slices → intent → specification →
plan → tasks → code. Every artefact stops for your approval. Nothing is
inferred, nothing is re-asked, and no implementation code is written before a
spec you have approved exists.

The model power descends with the abstraction: the strongest model does the
interviewing and specifying; cheaper models do the typing; the strongest model
comes back to verify.

---

## Contents

- [The idea in one minute](#the-idea-in-one-minute)
- [Using the template](#using-the-template)
- [The process, end to end](#the-process-end-to-end)
- [What you will be asked, and when](#what-you-will-be-asked-and-when)
- [The artefacts](#the-artefacts)
- [The model ladder](#the-model-ladder)
- [What the agent is not allowed to do](#what-the-agent-is-not-allowed-to-do)
- [Day to day](#day-to-day)
- [Scripts](#scripts)
- [Customising the template](#customising-the-template)
- [What it is built from](#what-it-is-built-from)

---

## The idea in one minute

AI agents are good at writing code and bad at guessing what you meant. Every
gap in a request gets filled with a plausible assumption, and the assumptions
compound into a codebase that does almost what you wanted.

This template closes the gaps *before* code exists, by making the agent mine
you for every decision and write each one down:

| Level | Artefact | The agent asks you… |
|---|---|---|
| Product | `docs/product.md` | what this is, for whom, what success means, what is out of scope for ever |
| Domain | `docs/domain.md` | how the product divides into bounded contexts, what events pass between them, what must never be false |
| Preferences | `docs/engineering.md` | how you like code written — once, then reused across every project |
| Roadmap | `docs/roadmap.md` | which thin vertical slices to build, in what order, where the cut line is |
| Slice intent | `specs/NNN/intent.md` | everything about one slice, in your words, recorded as you answer |
| Specification | `specs/NNN/spec.md` | *what* and *why*, as testable requirements with Given/When/Then scenarios — no technology |
| Plan | `specs/NNN/plan.md` | *how* — stack, data, interfaces, structure — every choice with its rejected alternative |
| Tasks | `specs/NNN/tasks.md` | self-contained work units, each naming the scenario it proves |

Three rules hold it together:

1. **Article I of the constitution: the user is the source of truth.** The
   agent proposes; it never decides. A decision you make is written to
   `docs/decisions.md` and is never re-asked.
2. **Every artefact is a gate.** It is written, its open questions are put to
   you, and nothing proceeds until you approve. Approval stamps the file with
   a `verified: human:<you>` entry.
3. **Something always checks.** Implementation is reviewed per task by an
   agent that did not write it, then the whole slice is audited against the
   spec by a reviewer that saw none of the work. Tests are the spec's
   scenarios, written so the implementation could be thrown away and rewritten
   without touching them.

## Using the template

**On GitHub:** *Use this template → Create a new repository*. Then:

```bash
git clone git@github.com:<you>/<new-repo>.git
cd <new-repo>
./scripts/init.sh "Project Name" "One line about what it is"
claude            # or your agent of choice — see Portability below
```

Then, in the agent session:

```
/sdd-init
```

That is the only command you need to remember. It walks you through the
opening interviews (about 45 minutes for a real product), ratifies the
constitution, and offers to start the first slice. After that you just say
what you want; the `sdd` skill works out which phase you are in and routes you.

`init.sh` seeds `docs/` from `templates/`, swaps this README for the project's
own, copies your engineering preferences from `~/.config/sdd/engineering.md`
if you have them, and makes the first commit.

## The process, end to end

```
                    ┌──────────────────────────────────────────────┐
  once per project  │  /sdd-init                                    │
                    │   engineering prefs → product brief →         │
                    │   domain map → constitution → roadmap →       │
                    │   glossary                                    │
                    └──────────────────┬───────────────────────────┘
                                       │
                    ┌──────────────────▼───────────────────────────┐
  once per slice    │  grill          → intent.md      (you talk)   │
                    │  sdd-specify    → spec.md        [GATE]       │
                    │  sdd-plan       → plan.md        [GATE]       │
                    │  sdd-tasks      → tasks.md       [GATE]       │
                    │  sdd-implement  → code, one task at a time    │
                    │       ├ brief   → implementer (cheap model)   │
                    │       ├ verify  → controller re-runs tests    │
                    │       └ review  → task-reviewer, fix loop     │
                    │  sdd-converge   → reviewer audits the slice   │
                    │       └ gaps    → back to implement           │
                    │  sdd-finish     → merge / PR / keep           │
                    └──────────────────────────────────────────────┘
```

### Per phase

**`sdd-init`** — the door. Six interviews, one question at a time, each with
the agent's recommended answer so you are reviewing a draft rather than
filling in a form. Product brief; engineering preferences (skipped if you
already have a master file); domain discovery — nouns become contexts, verbs
become events, "what must never be true" becomes invariants; constitution —
three project-specific articles on top of the fixed ones; roadmap — the
product decomposed into vertical slices, each thin, end-to-end, useful on its
own, and belonging to exactly one context; glossary — every term scoped to a
context, in your definition.

**`grill`** — for each slice, an interview that walks the decision tree top
down: purpose, context, boundaries, actors, data, states, failure modes, the
boring realities (time zones, money, unicode, concurrency), scale, lifecycle,
done. It looks things up in the repo before asking. It pushes on weak answers.
It accepts "I don't know" and records it as an open question. Every answer is
written to `intent.md` as it is given, in your words.

**`sdd-specify`** — turns the intent into `spec.md`: what and why, no
technology. Requirements in EARS notation (`WHEN … THE SYSTEM SHALL …`), each
with Given/When/Then scenarios carrying real values, including the failure
paths. A Domain section names the context, the events, and the invariants.
The most valuable section is *explicitly out of scope*. Gate.

**`sdd-plan`** — turns the spec into `plan.md`: stack, data model, interfaces
with their error shapes, events with their schemas, file structure mirroring
the context map, test strategy, risks, rollout. Every choice names the
alternative it rejected. Checked against the constitution and your engineering
preferences section by section; a departure is a question for you, not a
decision. Fills `AGENTS.md` with the real commands. Gate.

**`sdd-tasks`** — turns the plan into `tasks.md`: ordered, dependency-aware,
each task self-contained (exact files, exact interfaces, 3–8 steps of 2–5
minutes, exact verify command) because the implementer will see only its
task, never the whole plan. No placeholders — "handle edge cases" fails the
gate. Every RED step names the scenario it proves. Gate.

**`sdd-implement`** — the controller loop. For each task: build a brief
(`scripts/task-brief.sh` extracts the task, its requirements, the relevant plan
sections, your preferences, the commands, the constitution into one file);
dispatch an `implementer` subagent that reads only that brief and works TDD;
re-run the verification yourself; package the diff; dispatch a `task-reviewer`
for two verdicts — spec compliance, then quality; loop a fixer on failures,
at most three rounds; mark done; commit. An implementer that hits a gap
reports `NEEDS_CONTEXT` and the question comes to you — it never guesses.

**`sdd-converge`** — a `reviewer` subagent on the strongest model, which did
not watch any of the above, audits the slice against `spec.md`, `plan.md`,
the constitution, your preferences and `REVIEW.md`: every scenario has a
test, every test goes through the public interface, no context imports
another's internals, no unplanned dependency, no secret in the tree. Gaps go
back into `tasks.md`. Repeats until clean.

**`sdd-finish`** — merge, open a PR, or keep the branch. Roadmap → shipped.
Offers the next slice.

## What you will be asked, and when

The template is built so that your attention is spent at decision gates and
nowhere else.

| You are asked | When | Not asked again because |
|---|---|---|
| The big questions — what, for whom, contexts, invariants, preferences | `/sdd-init`, once | recorded in `docs/` and `docs/decisions.md` |
| Everything about a slice | `grill`, once per slice | recorded in `intent.md` |
| Approve / revise | each gate: spec, plan, tasks (and the init docs) | approval is a `verified` stamp on the file |
| A question the brief could not answer | mid-implementation, rarely | answered once, added to `decisions.md` |
| Accept a warning by name | converge, if any | recorded in the report |
| Merge / PR / keep | finish | — |

The agent is told to prefer a small number of good questions over silent
assumptions, and to recommend an answer with every question. A typical slice
costs you one `grill` session and three approvals.

## The artefacts

Every markdown file carries [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
frontmatter with a distinct `type`, `sources` for provenance, `generated` for
who drafted it, and `verified` for who approved it. `index.md` in each
directory is regenerated from that frontmatter, and `log.md` records every
gate passed. Details: [`docs/okf.md`](docs/okf.md).

```
index.md                bundle root — start here
log.md                  every gate passed, dated
AGENTS.md               agent instructions (cross-tool standard); CLAUDE.md imports it
REVIEW.md               review policy — passes, severities, thresholds. Yours.
memory/constitution.md  highest authority; agents propose amendments, never make them
docs/
  product.md            what this is, for whom, constraints, lifecycle
  domain.md             bounded contexts, code roots, events, invariants
  engineering.md        how you like code written — copied from your master
  roadmap.md            vertical slices in build order, with status
  glossary.md           the vocabulary, scoped per context
  decisions.md          append-only; every decision you have made
  adr/                  architecture decision records
  sdd-guide.md          the long-form guide to all of this
  okf.md                the frontmatter and what each field means
specs/NNN-slug/         one directory per slice
  intent.md             your words, Q&A record
  spec.md               WHAT and WHY — EARS requirements, scenarios, no tech
  plan.md               HOW — stack, data, interfaces, structure, risks
  tasks.md              self-contained task blocks
  notes.md              decisions taken during implementation
templates/              what the skills fill in
scripts/                see below
.claude/skills/         the workflow — 16 skills
.claude/agents/         implementer, task-reviewer, reviewer
.claude/settings.json   permissions and hooks
```

## The model ladder

Judgement at the top, hands at the bottom, model power following:

| Phase | Runs as | Model |
|---|---|---|
| `sdd-init`, `sdd-constitution`, `sdd-engineering`, `grill`, `sdd-specify`, `sdd-plan` | main session | strongest available |
| `sdd-tasks`, `sdd-implement` (controller) | main session | strongest or mid |
| `implementer`, `task-reviewer` (per task) | subagents | mid (Sonnet) |
| `sdd-converge` → `reviewer` | subagent | **strongest** |
| `sdd-finish` | main session | any |

The one deliberate bend: verification is never weaker than what it verifies,
so the slice-level reviewer is pinned to the strongest model. Tiers are set in
`.claude/agents/*.md` and are yours to change.

## What the agent is not allowed to do

Enforced by mechanism, not by asking nicely:

- **Write implementation code before an approved spec exists.** The `sdd`
  router refuses to route past a gate that has not been passed.
- **Edit the constitution, your engineering preferences, `REVIEW.md`,
  `index.md` or `log.md` directly.** A `PreToolUse` hook
  (`scripts/hooks/guard-paths.sh`) blocks the edit tools on these paths;
  the owning skill unlocks a file only between your approval and the commit.
- **Read or write `.env*`, keys, secrets, credentials.** Denied in
  `settings.json` and by the hook.
- **`git push`, `git reset --hard`, `rm -rf`.** Denied. Pushing is the one
  step that leaves your machine, and it stays yours.
- **Hand-edit frontmatter.** `scripts/fm.py` and `scripts/approve.sh` are the
  only way, so `status` and `sdd_phase` can never disagree.
- **Import another bounded context's internals.** `scripts/check-contexts.sh`
  fails it; only `published/` interfaces and events cross a boundary.
- **Write a test that reaches inside the context.** `task-reviewer` marks it
  as an important finding; the `bdd` skill's litmus is *could the
  implementation be rewritten and this test still pass unedited?*
- **Mark a task done on the implementer's word.** The controller re-runs the
  verification itself; then a separate reviewer checks the diff.
- **Re-ask a recorded decision, or answer an open question on your behalf.**

## Day to day

| Say | Happens |
|---|---|
| "I want to add X" | `sdd` classifies it (trivial / small / full), reads the roadmap, and routes — usually to `grill` |
| `quick: fix the typo in the footer` | done directly, no ceremony |
| "where were we" / "carry on" | resumes from the last `done` task |
| "grill me on X" | the interview, for anything — not only slices |
| "converge" / "did we build what we specced" | the slice audit |
| "ship it" / "open the PR" | `sdd-finish` |
| "my coding preferences" | `sdd-engineering` — view, refine, sync to master |
| "amend the constitution" | `sdd-constitution` — proposed, gated, versioned |

Right-sizing means a one-line CSS fix and a new auth system do not get the
same ceremony: trivial changes are just done; a single-file change gets a spec
and skips the plan; anything touching auth, money, personal data, deletion or
migrations gets the full path with no exceptions.

## Scripts

All stdlib bash and Python 3; no dependencies.

| Script | Does |
|---|---|
| `init.sh "Name" "One line"` | one-time instantiation of a repo made from this template |
| `new-feature.sh <slug> [--branch]` | allocates the next `NNN`, seeds the slice from templates |
| `fm.py get\|set\|check\|verify` | the only way frontmatter is read or written |
| `approve.sh <file> <phase>` | the only way a gate is passed — stamps `verified`, appends to `log.md` |
| `index.sh` | regenerates every `index.md` from frontmatter |
| `check-specs.sh` | lints the artefact tree: phases, contexts, scenarios, placeholders, tech in specs |
| `check-contexts.sh` | fails a cross-context import that bypasses `published/` |
| `check-scenarios.sh` | every spec scenario has a test citing it |
| `task-brief.sh <slice> <TID>` | extracts one task into a self-contained brief for the implementer |
| `review-package.sh <slice> <TID> <base>` | packages a task's diff for the reviewer |
| `hooks/guard-paths.sh` | `PreToolUse`: protected paths |
| `hooks/post-edit.sh` | `PostToolUse`: runs your formatter — filled in by the first plan |

## Customising the template

Things you will want to change, in the order you will want to change them:

- **Engineering preferences master** — `~/.config/sdd/engineering.md` (or
  `$SDD_ENGINEERING`). The first `/sdd-init` interviews you for it; every
  later project copies it in. Refinements discovered during a project are
  proposed back with a "sync to master?" question.
- **`REVIEW.md`** — the review passes, severities and thresholds. Edit by hand;
  agents apply it and never change it.
- **Constitution Articles V–VII** — the project-specific non-negotiables.
  `sdd-constitution` interviews for them with candidates.
- **Model tiers** — `model:` in `.claude/agents/*.md`.
- **`check-contexts.sh`** — `PUBLISHED` and `IMPORT_RE` at the top, tuned to
  your stack in the first `/sdd-plan`.
- **`settings.json`** — the allowlist permits `git commit` and denies `push`;
  adjust to taste.
- **Templates** — `templates/*.md` are what the skills fill in. Change the
  shape of a spec here and every future spec follows.

### Portability

The skills are plain `SKILL.md` folders — the open Agent Skills standard, read
by Claude Code, Codex, Cursor, VS Code and others. `AGENTS.md` is the
cross-tool context file. `CLAUDE.md` is one line importing it. The scripts and
artefacts are agent-agnostic. What does not travel to another agent:
`.claude/settings.json` (permissions and hooks) and `.claude/agents/`
(subagent definitions) — those have equivalents in most agents but the files
are Claude Code's.

## What it is built from

Nothing here is novel; it is a deliberate assembly of the current best
practice, each part credited in [`docs/sdd-guide.md`](docs/sdd-guide.md):

- The gate workflow and constitution from **GitHub Spec Kit**.
- The chain of artefacts (`intent.md` → spec → plan → diff → review), hooks as
  boundaries, `REVIEW.md`, subagent verifiers and the "things agents get
  wrong" list from **Anthropic's AI-Native SDLC playbook**.
- `grill` from **Matt Pocock's grill-me**.
- The TDD iron law, task anatomy, brief-per-task subagent implementation,
  systematic debugging and branch finishing from **obra/superpowers**.
- **EARS** requirements notation (Mavin et al., Rolls-Royce), as used by AWS
  Kiro, paired with Given/When/Then scenarios (**North, BDD**).
- Bounded contexts, ubiquitous language, domain events and invariants from
  **Domain-Driven Design** (Evans; Vernon) — four ideas, no vocabulary tax.
- **Open Knowledge Format v0.2** (Google Cloud) for every artefact.
- **AGENTS.md** (Agentic AI Foundation / Linux Foundation) and the **Agent
  Skills** standard for portability.

The long version of everything above, including the reasoning behind each
choice and what was deliberately left out, is
[`docs/sdd-guide.md`](docs/sdd-guide.md).
