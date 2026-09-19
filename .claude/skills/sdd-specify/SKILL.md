---
type: Skill
name: sdd-specify
description: Write a feature specification — the WHAT and WHY, with EARS requirements and acceptance criteria — into specs/NNN-slug/spec.md. Use after a grilling session, or when the user says "write the spec", "spec this", "turn this into a spec", or starts a feature whose requirements are understood but unwritten. Writes no implementation code.
---

# Specify

Produce `specs/NNN-slug/spec.md`: what we are building and why. **No technology.**

## Before writing

1. Read `memory/constitution.md`. If `sdd_phase` is not `ratified` or it has
   placeholders, stop and run `sdd-constitution` first.
2. Read the `ears` skill. Every requirement here uses it.
3. Read `templates/spec-template.md` — that is the structure, in full.
4. Read `docs/product.md`, `docs/roadmap.md`, `docs/glossary.md`,
   `docs/decisions.md`, and this slice's `intent.md`. If `intent.md` is missing
   or its `sdd_phase` is not `resolved`, stop and run `grill`. Do not re-ask
   anything `intent.md` answers.
5. Read the `## Outcome` and requirement headings of every other spec whose
   `sdd_phase` is `approved`. This slice must be consistent with them and must
   use glossary terms exactly.

## The feature directory

It exists already — `grill` created it. If somehow it does not, run
`./scripts/new-feature.sh <slug>`. Slug is kebab-case and describes the change,
not the mechanism: `user-login`, not `add-jwt-middleware`.

## Writing the spec

Fill the template in this order — it matters, because each section constrains
the next:

1. **Problem** — what is wrong today, for whom, at what cost. Not the solution.
2. **Outcome** — what is true afterwards, observable from outside.
3. **Scope, especially "explicitly out of scope"** — the most valuable section in
   the document. An agent fills unstated gaps with guesses; this is where you
   pre-empt them. Be generous here.
4. **Relationship to other slices** — depends on, affects, shares terms.
5. **Requirements** — EARS, one ID each. For each one, immediately write its
   acceptance criteria, including the failure case and the actual values.
6. **Non-functional requirements** — only the ones with a number. Delete the rest
   of the table rather than filling it with "N/A" theatre.
7. **Edge cases** — walk the table: empty, concurrent, dependency down, hostile
   input, partial failure. Each row becomes a requirement or an accepted risk.
8. **Assumptions** — everything you are taking as true without verifying.
9. **Open questions** — with your recommended answer for each.

Set `title`, `description` and `generated.by` / `generated.at` with
`./scripts/fm.py set`.

## The discipline

- **No technology.** No library, framework, database, protocol, schema, file
  path or API shape. If you write "using Postgres", move it to the plan. The
  test: would this requirement still be true if we rewrote the whole thing in a
  different stack? If not, it is a plan item.
- **One vertical slice.** Do not write forty requirements. Spec the slice that
  is demonstrably useful on its own; implementation will teach us what the next
  slice should say. Say explicitly which slice this is and what follows.
- **Do not answer your own open questions.** Recommending an answer is helpful;
  recording it as decided is not. The user decides.
- **Coverage before elegance.** A spec with six blunt requirements and a full
  edge-case table beats one with twenty beautifully worded happy paths.
- Aim for the smallest spec that leaves nothing to guess. Length is not the goal;
  absence of ambiguity is.

## Gate

Write the file, then report in at most five lines:

- The slice this covers, and what is deliberately deferred
- Anything you decided that the user did not specify
- The open questions, numbered
- The riskiest assumption

Then `AskUserQuestion`: *Approve*, *Revise*, *Answer open questions first*.

On approval: run `./scripts/approve.sh specs/NNN-slug/spec.md approved`, set the
slice's `docs/roadmap.md` status to `specified`, run `./scripts/index.sh`, commit
`docs(spec): NNN-slug — <title>`, and hand to `sdd-plan`.

**Do not write code in this turn.** Do not proceed to the plan without approval.
