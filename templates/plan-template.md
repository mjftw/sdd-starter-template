---
type: Implementation Plan
title: <Feature name> — plan
description: <one sentence — the approach>
resource: /specs/NNN-slug/plan.md
status: draft
tags: [sdd, plan, "slice:NNN-slug"]
sources:
  - resource: /specs/NNN-slug/spec.md
  - resource: /docs/engineering.md
  - resource: /memory/constitution.md
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_id: NNN-slug
sdd_phase: draft          # draft | in-review | approved
---

# Plan: <Feature name>

> **HOW.** Everything the spec deliberately excluded. This document is where
> technology choices live, and every choice names its alternative and its reason.

## Constitution check

| Article | Relevant? | How this plan complies |
|---|---|---|
| I — user is source of truth | | |
| II — spec precedes implementation | | |
| III — testable requirements | | |
| IV — separate verification | | |
| VIII — simplicity | | |

> If any row reads "does not comply", stop. Either change the plan or propose an
> amendment. Do not proceed on a noted exception.

## Engineering preferences check

> `docs/engineering.md`, section by section. "Follows" or the departure and
> its reason. A departure is an open question for the user, not a decision.

| § | Follows? | Departure and reason |
|---|---|---|
| 2 Paradigm | | |
| 3 Types | | |
| 4 Errors | | |
| 6 Architecture | | |
| 7 Testing | | |
| 8 Data and interfaces | | |
| 9 Dependencies | | |
| 14 Tooling | | |

## Approach

<One paragraph: the shape of the solution. A reader should be able to predict
the file list from this paragraph.>

### Alternatives rejected

| Option | Why not |
|---|---|
| | |

## Stack

| Layer | Choice | Version | Why this, not the obvious alternative |
|---|---|---|---|
| Language / runtime | | | |
| Framework | | | |
| Data store | | | |
| Testing | | | |
| Build / tooling | | | |

New dependencies, each with a justification (Article VIII):

| Package | Purpose | Why not stdlib / existing dep |
|---|---|---|

## Data model

<Entities, fields, types, relationships, constraints. Include the migration
strategy if this changes existing data. Say what is indexed and why.>

## Interfaces

<Public surface: endpoints, function signatures, events, CLI commands, message
schemas. Include error shapes — an interface without its failure responses is
half-specified.>

## Structure

```
<the files and directories this feature adds or changes, as a tree>
```

## Requirement → design mapping

> Every requirement in the spec appears here exactly once. A requirement with no
> row is unimplemented; a row with no requirement is scope creep.

| Requirement | Where it is satisfied | How it is verified |
|---|---|---|
| REQ-001 | | |

## Test strategy

- **Unit:** <what, and what is deliberately not unit-tested>
- **Integration:** <the seams that actually break>
- **End-to-end:** <the user journeys from the spec>
- **Not tested, and why:** <be explicit; this is a decision, not an omission>

## Risks

| Risk | Likelihood | If it happens | Mitigation / early signal |
|---|---|---|---|

## Rollout

<Migration, feature flag, backfill, reversibility. How we turn it off if it goes
wrong. If it cannot be turned off, say so — that is a risk above.>

## Open questions

| # | Question | Blocks | Recommended answer |
|---|---|---|---|
