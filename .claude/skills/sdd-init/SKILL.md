---
type: Skill
name: sdd-init
description: Onboard a fresh repository created from the starter — product brief, engineering preferences, constitution, roadmap of vertical slices, glossary — before any slice is specified. Use on a new project, when docs/product.md is missing or still a template, or when the user says "init", "set up the project", "new project", "let's start", or describes an app they want to build and no specs exist yet.
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

If `README.md` still contains `<PROJECT NAME>`, ask for the project name and a
one-line description, then run:

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

## Step 4 — Constitution

Hand to `sdd-constitution`. Return here when it is ratified.

## Step 5 — Roadmap → `docs/roadmap.md`

Decompose the product into **vertical slices**: each thin, end-to-end, and
demonstrably useful alone. Not layers ("database", "API", "UI") — outcomes
("a reading can be recorded and seen").

Propose a first cut of 3–8 slices, ordered, one-line outcome each, with the
dependencies between them. Then interrogate it with the user, one question at a
time:

- Is slice 1 the smallest thing that is still useful to you?
- Which slice would you cut if you had half the time? (That is the cut line.)
- Does any slice depend on a decision we have not made?
- Is anything here really two slices? Really none?

Write the file with every slice `proposed`. **Gate**: *Approve* / *Revise* /
*Re-order*. On approval `./scripts/approve.sh docs/roadmap.md approved`, then
`./scripts/index.sh`; append decisions.

## Step 6 — Glossary → `docs/glossary.md`

List the nouns that appeared in Steps 3–5. For each, ask for the definition the
*user* uses, and what it must not be confused with. Specs and code will use
these terms exactly. Write the file. **Gate**: *Approve* / *Revise*, then
`./scripts/approve.sh docs/glossary.md approved` and `./scripts/index.sh`.

## Step 7 — Hand off

Commit: `docs(init): product brief, engineering, roadmap, glossary`.

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
