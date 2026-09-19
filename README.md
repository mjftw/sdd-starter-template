<!-- sdd-starter-template -->
# Spec Driven Development project starter 

A GitHub template for building software with AI agents, spec-first, where you
are the source of truth and the agent is the hands.

Create a repo from it, open your coding agent, and say what you want to build.
The agent interviews you, one question at a time, always with a recommended
answer, until it understands the product, the domain, and how you like code
written. Then it works down through the levels of abstraction: product brief,
bounded contexts, vertical slices, intent, specification, plan, tasks, code.
Every artefact stops for your approval. Nothing is inferred, nothing is
re-asked, and no implementation code is written before a spec you have approved
exists.

Model power descends with the abstraction. The strongest model does the
interviewing and specifying, cheaper models do the typing, and the strongest
model comes back to verify.

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

This template closes the gaps before code exists, by making the agent mine you
for every decision and write each one down:

| Level | Artefact | The agent asks you… |
|---|---|---|
| Brainstorm | `docs/intent-product.md` | what you are trying to achieve, in your words, before anything is structured |
| Product | `docs/product.md` | what this is, for whom, what success means, what is out of scope for ever |
| Domain | `docs/domain.md` | how the product divides into bounded contexts, what events pass between them, what must never be false |
| Roadmap | `docs/roadmap.md` | which thin vertical slices to build, in what order, where the cut line is |
| Slice intent | `specs/NNN/intent.md` | everything about one slice, in your words, recorded as you answer |
| Specification | `specs/NNN/spec.md` | what and why, as testable requirements with Given/When/Then scenarios, no technology |
| Preferences | `docs/engineering.md` | how you like code written, asked at the first plan, then reused across every project |
| Plan | `specs/NNN/plan.md` | how: stack, data, interfaces, structure, every choice with its rejected alternative |
| Tasks | `specs/NNN/tasks.md` | self-contained work units, each naming the scenario it proves |

Three rules hold it together.

Article I of the constitution says the user is the source of truth. The agent
proposes; it never decides. A decision you make is written to
`docs/decisions.md` and is never re-asked.

Every artefact is a gate. It is written, its open questions are put to you, and
nothing proceeds until you approve. Approval stamps the file with a
`verified: human:<you>` entry.

Something always checks. Implementation is reviewed per task by an agent that
did not write it, then the whole slice is audited against the spec by a
reviewer that saw none of the work. Tests are the spec's scenarios, written so
the implementation could be thrown away and rewritten without touching them.

## Using the template

On GitHub: *Use this template*, then *Create a new repository*. Then:

```bash
git clone git@github.com:<you>/<new-repo>.git
cd <new-repo>
./scripts/init.sh "Project Name" "One line about what it is"
claude            # or your agent of choice; see Portability below
```

Then, in the agent session:

```
/sdd-init
```

That is the only command you need to remember. It walks you through the opening
interviews, which take about 45 minutes for a real product, ratifies the
constitution, and offers to start the first slice. None of it asks about
technology; that starts at the first plan. After that you just say what
you want, and the `sdd` skill works out which phase you are in and routes you.

`init.sh` seeds `docs/` from `templates/`, swaps this README for the project's
own, copies your engineering preferences from `~/.config/sdd/engineering.md` if
you have them, and makes the first commit.

## The process, end to end

```
                    ┌──────────────────────────────────────────────┐
  once per project  │  /sdd-init            no technology yet      │
                    │    brainstorm (grill), product brief,        │
                    │    domain map, constitution, roadmap,        │
                    │    glossary                                  │
                    └──────────────────┬───────────────────────────┘
                                       │
                    ┌──────────────────▼───────────────────────────┐
  once per slice    │  grill          → intent.md     (you talk)   │
                    │  sdd-specify    → spec.md       [GATE]       │
                    │  sdd-plan       → plan.md       [GATE]       │
                    │       └ first time: engineering prefs, then  │
                    │         the stack is chosen here             │
                    │  sdd-tasks      → tasks.md      [GATE]       │
                    │  sdd-implement  → code, one task at a time   │
                    │       ├ brief   → implementer (cheap model)  │
                    │       ├ verify  → controller re-runs tests   │
                    │       └ review  → task-reviewer, fix loop    │
                    │  sdd-converge   → reviewer audits the slice  │
                    │       └ gaps    → back to implement          │
                    │  sdd-finish     → merge / PR / keep          │
                    └──────────────────────────────────────────────┘
```

### Per phase

`sdd-init` is the door, and it asks nothing about technology. It starts with a
brainstorm: an open interview about what you are trying to achieve, what is
annoying today, what the thing looks like in your head, who it is for, what
would make you abandon it. That becomes `docs/intent-product.md` in your own
words. The product brief is then drafted *from* that intent rather than asked
from scratch, and you are only questioned on what the brainstorm left out.
Domain discovery follows, where nouns become bounded contexts, verbs become
events, and "what must never be true" becomes invariants. Then the
constitution, which is three project-specific articles on top of the fixed
ones. Then the roadmap, the product decomposed into vertical slices, each thin,
end to end, useful on its own, and belonging to exactly one context. Then the
glossary, with every term scoped to a context, in your definition.

Every step of init is technology-free by design. Which language, which
framework, which database, where it is hosted: none of those are answerable
until the product, its constraints and its non-functional requirements exist,
so none of them are asked. If you volunteer one, it is recorded as your stated
preference and not followed up.

`grill` runs for each slice: an interview that walks the decision tree top down
through purpose, context, boundaries, actors, data, states, failure modes, the
boring realities like time zones and money and unicode and concurrency, scale,
lifecycle, and done. It looks things up in the repo before asking. It pushes on
weak answers. It accepts "I don't know" and records it as an open question.
Every answer is written to `intent.md` as it is given, in your words.

`sdd-specify` turns the intent into `spec.md`: what and why, no technology.
Requirements go in EARS notation (`WHEN … THE SYSTEM SHALL …`), each with
Given/When/Then scenarios carrying real values, including the failure paths. A
Domain section names the context, the events, and the invariants. The most
valuable section is the one listing what is explicitly out of scope. Gate.

`sdd-plan` is where technology finally enters. On the first slice it runs the
engineering-preferences interview if you have no master file yet, asking the
principles first (paradigm, types, errors, testing) and the languages and
tooling last, framed as what you reach for rather than a decision for this
project. Then it chooses this project's stack, in order, from: the constraints
the product brief recorded as imposed, the numbers in the spec's
non-functional requirements, what each bounded context actually needs, your
preferences, and whatever the repo already uses. The Approach paragraph has to
say which of those drove the choice.

`sdd-plan` turns the spec into `plan.md`: stack, data model, interfaces with
their error shapes, events with their schemas, file structure mirroring the
context map, test strategy, risks, rollout. Every choice names the alternative
it rejected. The plan is checked against the constitution and your engineering
preferences section by section, and a departure is a question for you rather
than a decision. This phase also fills `AGENTS.md` with the real commands.
Gate.

`sdd-tasks` turns the plan into `tasks.md`: ordered, dependency-aware, and each
task self-contained with exact files, exact interfaces, 3 to 8 steps of 2 to 5
minutes, and an exact verify command. Self-contained matters because the
implementer will see only its own task, never the whole plan. No placeholders:
"handle edge cases" fails the gate. Every RED step names the scenario it
proves. Gate.

`sdd-implement` is the controller loop. For each task it builds a brief, where
`scripts/task-brief.sh` extracts the task, its requirements, the relevant plan
sections, your preferences, the commands and the constitution into one file. It
dispatches an `implementer` subagent that reads only that brief and works TDD.
It re-runs the verification itself. It packages the diff, dispatches a
`task-reviewer` for two verdicts on spec compliance and then quality, and loops
a fixer on failures for at most three rounds before bringing them to you. Then
it marks the task done and commits. An implementer that hits a gap reports
`NEEDS_CONTEXT` and the question comes to you. It never guesses.

`sdd-converge` puts a `reviewer` subagent on the strongest model, one that did
not watch any of the above, to audit the slice against `spec.md`, `plan.md`,
the constitution, your preferences and `REVIEW.md`. It checks that every
scenario has a test, that every test goes through the public interface, that no
context imports another's internals, that no dependency arrived unplanned, and
that no secret is in the tree. Gaps go back into `tasks.md`, and it repeats
until clean.

`sdd-finish` merges, opens a PR, or keeps the branch. Roadmap goes to shipped.
It offers the next slice.

## What you will be asked, and when

The template is built so that your attention is spent at decision gates and
nowhere else.

| You are asked | When | Not asked again because |
|---|---|---|
| What you are trying to achieve, openly | `/sdd-init` step 2, once | recorded in `docs/intent-product.md` |
| The big questions: what, for whom, contexts, invariants | `/sdd-init`, once | recorded in `docs/` and `docs/decisions.md` |
| How you like code written | the first `sdd-plan`, once ever | recorded in `docs/engineering.md` and your master copy |
| Everything about a slice | `grill`, once per slice | recorded in `intent.md` |
| Approve or revise | each gate: spec, plan, tasks, and the init docs | approval is a `verified` stamp on the file |
| A question the brief could not answer | mid-implementation, rarely | answered once, added to `decisions.md` |
| Accept a warning by name | converge, if any | recorded in the report |
| Merge, PR or keep | finish | |

The agent is told to prefer a small number of good questions over silent
assumptions, and to recommend an answer with every question. A typical slice
costs you one `grill` session and three approvals.

## The artefacts

Every markdown file carries [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
frontmatter with a distinct `type`, `sources` for provenance, `generated` for
who drafted it, and `verified` for who approved it. The `index.md` in each
directory is regenerated from that frontmatter, and `log.md` records every gate
passed. Details are in [`docs/okf.md`](docs/okf.md).

```
index.md                bundle root, start here
log.md                  every gate passed, dated
AGENTS.md               agent instructions (cross-tool standard); CLAUDE.md imports it
REVIEW.md               review policy: passes, severities, thresholds. Yours.
memory/constitution.md  highest authority; agents propose amendments, never make them
docs/
  product.md            what this is, for whom, constraints, lifecycle
  domain.md             bounded contexts, code roots, events, invariants
  engineering.md        how you like code written, copied from your master
  roadmap.md            vertical slices in build order, with status
  glossary.md           the vocabulary, scoped per context
  intent-product.md     the opening brainstorm, in your words
  decisions.md          append-only; every decision you have made
  adr/                  architecture decision records
  sdd-guide.md          the long-form guide to all of this
  okf.md                the frontmatter and what each field means
specs/NNN-slug/         one directory per slice
  intent.md             your words, Q&A record
  spec.md               WHAT and WHY: EARS requirements, scenarios, no tech
  plan.md               HOW: stack, data, interfaces, structure, risks
  tasks.md              self-contained task blocks
  notes.md              decisions taken during implementation
templates/              what the skills fill in
scripts/                see below
.claude/skills/         the workflow, 16 skills
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
| `sdd-converge` → `reviewer` | subagent | strongest |
| `sdd-finish` | main session | any |

There is one deliberate bend in the ladder. Verification is never weaker than
what it verifies, so the slice-level reviewer is pinned to the strongest model.
Tiers are set in `.claude/agents/*.md` and are yours to change.

## What the agent is not allowed to do

Each of these is enforced by a mechanism, not by asking nicely.

It cannot write implementation code before an approved spec exists, because the
`sdd` router refuses to route past a gate that has not been passed.

It cannot edit the constitution, your engineering preferences, `REVIEW.md`,
`index.md` or `log.md` directly. A `PreToolUse` hook
(`scripts/hooks/guard-paths.sh`) blocks the edit tools on those paths, and the
owning skill unlocks a file only between your approval and the commit.

It cannot read or write `.env*`, keys, secrets or credentials. Denied in
`settings.json` and by the hook.

It cannot run `git push`, `git reset --hard` or `rm -rf`. Pushing is the one
step that leaves your machine, and it stays yours.

It cannot hand-edit frontmatter. `scripts/fm.py` and `scripts/approve.sh` are
the only way, so `status` and `sdd_phase` can never disagree.

It cannot import another bounded context's internals, because
`scripts/check-contexts.sh` fails it. Only `published/` interfaces and events
cross a boundary.

It cannot write a test that reaches inside the context. `task-reviewer` marks
that as an important finding, and the `bdd` skill's litmus is whether the
implementation could be rewritten with this test still passing unedited.

It cannot mark a task done on the implementer's word. The controller re-runs
the verification itself, and then a separate reviewer checks the diff.

It cannot re-ask a recorded decision, or answer an open question on your
behalf.

## Day to day

| Say | Happens |
|---|---|
| "I want to add X" | `sdd` classifies it (trivial, small or full), reads the roadmap, and routes, usually to `grill` |
| `quick: fix the typo in the footer` | done directly, no ceremony |
| "where were we" or "carry on" | resumes from the last `done` task |
| "grill me on X" | the interview, for anything, not only slices |
| "converge" or "did we build what we specced" | the slice audit |
| "ship it" or "open the PR" | `sdd-finish` |
| "my coding preferences" | `sdd-engineering`: view, refine, sync to master |
| "amend the constitution" | `sdd-constitution`: proposed, gated, versioned |

Right-sizing means a one-line CSS fix and a new auth system do not get the same
ceremony. Trivial changes are just done. A single-file change gets a spec and
skips the plan. Anything touching auth, money, personal data, deletion or
migrations gets the full path with no exceptions.

## Scripts

All stdlib bash and Python 3, no dependencies.

| Script | Does |
|---|---|
| `init.sh "Name" "One line"` | one-time instantiation of a repo made from this template |
| `new-feature.sh <slug> [--branch]` | allocates the next `NNN`, seeds the slice from templates |
| `fm.py get\|set\|check\|verify` | the only way frontmatter is read or written |
| `approve.sh <file> <phase>` | the only way a gate is passed; stamps `verified`, appends to `log.md` |
| `index.sh` | regenerates every `index.md` from frontmatter |
| `check-specs.sh` | lints the artefact tree: phases, contexts, scenarios, placeholders, tech in specs |
| `check-contexts.sh` | fails a cross-context import that bypasses `published/` |
| `check-scenarios.sh` | every spec scenario has a test citing it |
| `task-brief.sh <slice> <TID>` | extracts one task into a self-contained brief for the implementer |
| `review-package.sh <slice> <TID> <base>` | packages a task's diff for the reviewer |
| `hooks/guard-paths.sh` | `PreToolUse`: protected paths |
| `hooks/post-edit.sh` | `PostToolUse`: runs your formatter, filled in by the first plan |

## Customising the template

Things you will want to change, in the order you will want to change them.

Your engineering preferences master lives at `~/.config/sdd/engineering.md`, or
wherever `$SDD_ENGINEERING` points. The first `/sdd-init` interviews you for
it, and every later project copies it in. Refinements discovered during a
project are proposed back with a "sync to master?" question.

`REVIEW.md` holds the review passes, severities and thresholds. Edit it by
hand; agents apply it and never change it.

Constitution Articles V to VII are the project-specific non-negotiables, and
`sdd-constitution` interviews for them with candidates.

Model tiers are the `model:` field in `.claude/agents/*.md`.

`check-contexts.sh` has `PUBLISHED` and `IMPORT_RE` at the top, tuned to your
stack in the first `/sdd-plan`.

`settings.json` has an allowlist that permits `git commit` and denies `push`.
Adjust to taste.

`templates/*.md` are what the skills fill in. Change the shape of a spec there
and every future spec follows.

### Portability

The skills are plain `SKILL.md` folders, the open Agent Skills standard, read
by Claude Code, Codex, Cursor, VS Code and others. `AGENTS.md` is the
cross-tool context file, and `CLAUDE.md` is one line importing it. The scripts
and artefacts are agent-agnostic. Two things do not travel to another agent:
`.claude/settings.json`, which holds permissions and hooks, and
`.claude/agents/`, which holds the subagent definitions. Most agents have
equivalents, but those files are Claude Code's.

## What it is built from

Nothing here is novel. It is a deliberate assembly of current practice, and
each part is credited in [`docs/sdd-guide.md`](docs/sdd-guide.md):

- The gate workflow and constitution come from GitHub Spec Kit.
- The chain of artefacts (`intent.md`, spec, plan, diff, review), hooks as
  boundaries, `REVIEW.md`, subagent verifiers and the "things agents get wrong"
  list come from Anthropic's AI-Native SDLC playbook.
- `grill` comes from Matt Pocock's grill-me.
- The TDD iron law, task anatomy, brief-per-task subagent implementation,
  systematic debugging and branch finishing come from obra/superpowers.
- EARS requirements notation (Mavin et al., Rolls-Royce), as used by AWS Kiro,
  paired with Given/When/Then scenarios from Dan North's BDD.
- Bounded contexts, ubiquitous language, domain events and invariants come from
  Domain-Driven Design (Evans; Vernon). Four ideas, no vocabulary tax.
- Open Knowledge Format v0.2 (Google Cloud) for every artefact.
- AGENTS.md (Agentic AI Foundation, Linux Foundation) and the Agent Skills
  standard, for portability.

The long version of everything above, including the reasoning behind each
choice and what was deliberately left out, is in
[`docs/sdd-guide.md`](docs/sdd-guide.md).
