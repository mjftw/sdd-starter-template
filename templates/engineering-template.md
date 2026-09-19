---
type: Engineering Preferences
title: Engineering preferences
description: How code is written in every one of my projects — paradigm, typing, errors, testing, architecture, tooling.
resource: /docs/engineering.md
status: draft
tags: [sdd, engineering-preferences]
sources:
  - resource: conversation:YYYY-MM-DD
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_phase: draft          # draft | approved
sdd_version: 0.1.0
master: ~/.config/sdd/engineering.md
---

# Engineering preferences

> How code is written in every project of mine, whatever the product. Stable
> across projects; refined slowly. The plan, the tasks, the implementer and the
> reviewers read this. The spec never does — specs have no technology.
>
> Every section has a **default** — the recommendation the interview offered —
> and a **mine** line — what was actually chosen. Where they differ, mine wins.

## 1. Languages

> What you reach for, not a decision. Each project's plan chooses its stack
> from the product's imposed constraints and non-functional requirements,
> with this as one input, and may depart with a stated reason. This section is
> asked *last* in the interview, after everything above the line has been
> established.

**Default:** one primary language per project, chosen in the plan; a second
only at a hard boundary (e.g. a native client).
**Mine:**

| Rank | Language | Use for | Not for |
|---|---|---|---|
| 1 | | | |
| 2 | | | |

## 2. Paradigm

**Default:** functional core, imperative shell. Pure functions for domain
logic; side effects pushed to the edges and made explicit. Classes only where
the language makes them the natural unit of a module or an interface.
**Mine:**

## 3. Types

**Default:** the strictest mode the language offers, on. No escape hatches
(`any`, `object`, `dynamic`, unchecked casts) without a comment saying why.
Parse, don't validate: convert untrusted input into a typed value once, at the
boundary, and never re-check it inside. Make illegal states unrepresentable —
prefer a sum type over a flag plus an optional. Distinct types for distinct
ids (newtypes / branded types), not bare strings.
**Mine:**

## 4. Errors

**Default:** expected failures are values — `Result`/`Either`/tagged unions —
and part of the function's signature. Exceptions (or panics) are for bugs and
unrecoverable states only. Nothing is caught and swallowed; every handler
either recovers meaningfully or re-raises with context added.
**Mine:**

## 5. Immutability and state

**Default:** immutable by default. Mutation is local, explicit, and does not
escape the function that does it. Shared mutable state needs a stated reason.
**Mine:**

## 6. Architecture

**Default:** bounded contexts from `docs/domain.md`, each under its own code
root with a `published/` interface; vertical slices inside a context, not
horizontal layers across the product. Ports and adapters at every IO boundary
(database, network, filesystem, clock, randomness, other contexts) so the
domain can be tested with fakes. No framework types in domain code. Contexts
communicate by past-tense, schema-first events, translated at the consumer's
adapter.
**Mine:**

## 7. Testing

**Default:** TDD — no production code without a failing test first (`tdd`
skill). Tests are the spec's scenarios (`bdd` skill): one per
Given/When/Then, named after its ID, exercising the context through its
published interface only, so the implementation can be rewritten without
touching the test. Fakes at ports (in-memory repository, settable clock),
never mocks asserting on internal calls. Property-based tests for invariants.
Coverage is scenario traceability, not a percentage.
**Mine:**

## 8. Data and interfaces

**Default:** schema-first. Interfaces are defined in a schema language
(Protobuf, OpenAPI, GraphQL SDL, JSON Schema — whichever the plan picks) and
code is generated or validated from it, not the reverse. Every interface
documents its error shapes. Breaking changes are versioned, never slipped in.
**Mine:**

## 9. Dependencies

**Default:** standard library first. A dependency is added when it replaces
more than ~200 lines we would otherwise own *and* is maintained *and* has a
compatible licence. Pinned. Recorded in the plan with its reason.
**Mine:**

## 10. Style

**Default:** the formatter is authoritative; nobody hand-formats. Names come
from `docs/glossary.md`. Comments explain *why*, never *what*. No dead code,
no commented-out code, no `TODO` without an issue or a task ID.
**Mine:**

## 11. Observability

**Default:** structured logs (key=value or JSON), a correlation id on every
request/job, errors logged once with full context at the boundary where they
are handled. Metrics for anything with an SLO.
**Mine:**

## 12. Configuration and secrets

**Default:** configuration from environment or a config file, validated into a
typed object at startup, failing fast on a missing value. Secrets never in
code, never in logs, never in the repository.
**Mine:**

## 13. Git and delivery

**Default:** Conventional Commits citing the requirement ID. Small commits,
one task each. One branch per slice. Merge by PR with the convergence report
attached; squash on merge. `main` always green.
**Mine:**

## 14. Tooling per language

> Also asked last, and only for the languages in §1.

**Default:** one of each, the community standard, run by one `check` command.
**Mine:**

| Language | Package manager | Formatter | Linter | Type checker | Test runner |
|---|---|---|---|---|---|
| | | | | | |

## 15. Always / never

> Free text. The things that are not a category above but that I will
> correct every time.

**Always:**
-

**Never:**
-

## Refinement log

| Version | Date | Project | Change |
|---|---|---|---|
| 0.1.0 | | | Initial interview |
