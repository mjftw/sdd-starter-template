---
type: Skill
name: sdd-init
description: Onboard a fresh repository created from the starter — product brief, engineering preferences, domain map of bounded contexts, constitution, roadmap of vertical slices, glossary — before any slice is specified. Use on a new project, when docs/product.md is missing or still a template, or when the user says "init", "set up the project", "new project", "let's start", or describes an app they want to build and no specs exist yet.
---

# Init — the opening interview

Runs once, on a new repository. It captures what the project *is* before any
slice is specified. Everything written here is what every later phase reads
first, so these are the highest-leverage questions in the whole workflow.

**Run this on the strongest model available.** If you have reason to think you
are not it, say so once before starting.

You are mining the user. They hold the picture; you hold the questions. Every
answer is recorded in their words. Nothing is inferred. Article I.

## Step 1 — Mechanical setup

If `README.md` is still the template's own (its first line is
`<!-- sdd-starter-template -->`), ask for the project name and a one-line
description, then run:

    ./scripts/init.sh "<name>" "<one line>"

## Step 2 — Engineering preferences

Hand to `sdd-engineering`. It loads the repo copy, copies the master, or
interviews once. Return here when `docs/engineering.md` is `approved`.

## Step 3 — Product brief → `docs/product.md`

Interview, **one question at a time**, with your recommended answer attached to
each. `docs/product.md` already holds the template sections. Work through:

- What is this, in one sentence a stranger would understand?
- Who is it for — specifically, not "users"? Who is it *not* for?
- What do they do today instead, and what does that cost them?
- What must be true for you to call version one a success?
- What is out of scope for the whole project, not just v1?
- What constraints exist before we write anything — platform, hosting, where
  data may live, licensing, must-integrate-with, deadline?
- How does a change reach users, who is on the hook when it breaks, and what
  would make you abandon the project?

Fill `title` and `description` in the frontmatter, and set `generated.by` to
`claude-code/<your model id, or unknown>` and `generated.at` to now
(`./scripts/fm.py set`).

**Gate**: show it in full; `AskUserQuestion` — *Approve* / *Revise*. On
approval run `./scripts/approve.sh docs/product.md approved`, then
`./scripts/index.sh`, and append each decision to `docs/decisions.md` as
`<date> · init · <decision> · <why>`.

## Step 4 — Domain discovery → `docs/domain.md`

Read the `ddd` skill. Then, from the product brief, propose a first cut of
bounded contexts and interrogate it, one question at a time, recommended
answer attached:

1. **Nouns.** List every noun in the brief. Group the ones that change
   together and are described by the same people. Each group is a candidate
   context. Ask: "Does *<noun>* mean the same thing everywhere, or does it
   mean something different to <group A> than to <group B>?" A different
   meaning is a context boundary.
2. **Verbs → events.** For each context, what happens that other parts of the
   product need to know about? Name each as a past-tense fact in that
   context's words. Ask: "When <event>, who needs to know, and what do they
   need from it?"
3. **Rules.** For each context: "What must never be true? What would be a
   bug in the data, not just in the code?" Each answer is an invariant.
4. **Roots.** Propose a code root per context (`src/<name>/`). Confirm.
5. **Shared.** Anything that genuinely must be identical across contexts.
   Push back on each one.

Write the file. Three to seven contexts is normal; one is fine for a small
product. Fill `title`, `description`, `generated.*` with `fm.py set`.

**Gate**: show it in full; *Approve* / *Revise* / *Merge two contexts* /
*Split one*. On approval `./scripts/approve.sh docs/domain.md approved`,
`./scripts/index.sh`, append decisions.

The roadmap (next step) tags every slice with its context, and the glossary
(after that) scopes every term to one.

## Step 5 — Constitution

Hand to `sdd-constitution`. Return here when it is ratified.

## Step 6 — Roadmap → `docs/roadmap.md`

Decompose the product into **vertical slices**: each thin, end-to-end, and
demonstrably useful alone. Not layers ("database", "API", "UI") — outcomes
("a reading can be recorded and seen").

Propose a first cut of 3–8 slices, ordered, one-line outcome each, **the
context each belongs to**, and the dependencies between them. Then interrogate
it with the user, one question at a time:

- Is slice 1 the smallest thing that is still useful to you?
- Which slice would you cut if you had half the time? (That is the cut line.)
- Does any slice depend on a decision we have not made?
- Is anything here really two slices? Really none?
- Does any slice span two contexts? Then it is two slices, or an integration
  slice.

Write the file with every slice `proposed`. **Gate**: *Approve* / *Revise* /
*Re-order*. On approval `./scripts/approve.sh docs/roadmap.md approved`, then
`./scripts/index.sh`; append decisions.

## Step 7 — Glossary → `docs/glossary.md`

List the nouns that appeared in Steps 3–6. For each, ask which context it
belongs to and for the definition the *user* uses in that context, and what it
must not be confused with. Specs and code will use these terms exactly.
Write the file. **Gate**: *Approve* / *Revise*, then
`./scripts/approve.sh docs/glossary.md approved` and `./scripts/index.sh`.

## Step 8 — Hand off

Commit: `docs(init): product brief, engineering, domain, roadmap, glossary`.

Summarise in five lines: the product in one sentence; N slices and which is
first; the riskiest assumption; the open questions. Then offer to start slice 1
with `grill`.

## Rules

- One question at a time. A recommendation on every question.
- Read `docs/decisions.md` before asking anything. Never re-ask a recorded
  decision.
- Do not write a spec, a plan, or code in this phase.
- Do not fill a section with a plausible guess. Empty-and-marked-open beats
  full-and-wrong.
- Accept "I don't know". Record it as open or as an assumption with its risk.
