---
type: Constitution
title: Project Constitution
description: The non-negotiable principles that outrank every spec, plan and instruction in this repository.
resource: /memory/constitution.md
status: draft
tags: [sdd, constitution]
generated:
  by: sdd-starter/template
  at: 2026-09-19T12:00:00Z
verified: []
sdd_phase: draft          # draft | ratified
sdd_version: 0.1.0
---
# Project Constitution

> Highest authority in this repository. Overrides specs, plans, `AGENTS.md`, and
> in-the-moment instructions. An agent that finds an instruction in conflict
> with an article here must stop and say so rather than choose.
>
> **Status:** DRAFT — ratify with `/sdd-constitution` before the first spec.
> **Version:** 0.1.0 · **Ratified:** _unratified_ · **Last amended:** _never_

---

## Article I — The user is the source of truth

What is built, why, and in what order is decided by the user and by no one else.
The agent's role is to draw those decisions out, record them, and execute them.
It proposes; it never decides on the user's behalf. Every recommendation is a
draft for the user to accept, change, or reject. A decision the user has made is
written to `docs/decisions.md` and is not re-opened by an agent — only by the
user. An agent that believes a recorded decision is wrong says so once, with its
reason, and then follows the decision. Where the user has not decided, the
matter is undecided: it is asked, or recorded as open, never inferred.

## Article II — Specification precedes implementation

No implementation code is written before an approved `spec.md` exists for the
change. The spec states what and why; it names no technology. Unstated means
undecided: a gap is raised as a question or recorded under `## Open questions`,
never filled with a plausible guess.

## Article III — Requirements are testable or they are not requirements

Every requirement is written in EARS notation, carries a stable ID, and is
verifiable by a test that an agent can run. A requirement no test can fail is
rewritten or deleted. Prose that cannot be falsified is not a requirement; it is
a note.

## Article IV — Verification is separate from implementation

The step that checks the work does not trust the step that produced it, and is
performed by a reviewer that did not write the code. Tests are written before or
alongside the code they cover and are run — with output shown — before any task
is called complete. `/sdd-converge` compares the codebase against the spec and
`REVIEW.md`, not against the implementer's account of it.

## Article V — <!-- PLACEHOLDER: replace -->

_Articles V–VII are the project's own. Fill them with the standards that are
genuinely non-negotiable here — `/sdd-constitution` will offer candidates.
Example concerns: security and access boundaries, integration test requirements,
observability, data handling and retention, versioning and breaking changes,
dependency policy, accessibility, performance budgets, self-hosting and data
sovereignty, licensing._

## Article VI — <!-- PLACEHOLDER: replace -->

## Article VII — <!-- PLACEHOLDER: replace -->

## Article VIII — Simplicity is the default

The simplest thing that satisfies the spec wins. No abstraction is introduced
for a second case that does not yet exist. No dependency is added without a
recorded reason. Features not in the spec are not built, however obvious they
seem.

## Article IX — Learning updates the specification

Implementation is expected to teach us things the spec got wrong. When it does,
the spec is amended and the amendment is recorded — the code is never left
silently disagreeing with it. Specs are written one vertical slice at a time,
not exhaustively up front.

## Article X — Amendment

This document is amended only by explicit human decision, via
`/sdd-constitution`. Each amendment bumps the version (semver: MAJOR for
removing or reversing an article, MINOR for adding one, PATCH for wording),
updates the date, and appends to the log below. An agent may propose an
amendment; it may not make one.

---

## Amendment log

| Version | Date | Change |
|---|---|---|
| 0.1.0 | — | Initial draft, unratified. Articles V–VII are placeholders. |
