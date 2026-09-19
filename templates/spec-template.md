---
type: Specification
title: <Feature name>
description: <one sentence — what is true once this slice is done>
resource: /specs/NNN-slug/spec.md
status: draft
tags: [sdd, specification, "slice:NNN-slug"]
sources:
  - resource: /specs/NNN-slug/intent.md
  - resource: /docs/product.md
  - resource: /memory/constitution.md
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_id: NNN-slug
sdd_phase: draft          # draft | in-review | approved | implemented | superseded
sdd_constitution: 0.1.0
---

# Spec: <Feature name>

> **WHAT and WHY only.** No library names, no schema, no file paths, no API
> shapes. If it answers "how", it belongs in `plan.md`.

## Problem

<Two or three sentences. What is wrong or missing today, for whom, and what it
costs them. Not the solution.>

## Outcome

<What is true once this is done, stated so that we could tell from the outside
whether it happened. One paragraph.>

## Users and context

| Actor | Needs to be able to | Cares most about |
|---|---|---|
| | | |

## Scope

**In scope**
-

**Explicitly out of scope** <!-- the most valuable section in this document -->
-

## Relationship to other slices

| | Slice | How |
|---|---|---|
| Depends on | | |
| Affects | | |
| Shares terms | | (from `docs/glossary.md`) |

## Requirements

> EARS notation. `SHALL` only. Each has an ID that never changes once approved;
> a withdrawn requirement is struck through, not deleted or renumbered.
> Patterns: ubiquitous · event-driven (`WHEN`) · state-driven (`WHILE`) ·
> unwanted (`IF … THEN`) · optional (`WHERE`). See the `ears` skill.

### REQ-001: <short name>

THE SYSTEM SHALL <observable behaviour>

**Acceptance criteria**
- [ ] <checkable, specific, includes the values>
- [ ] <the failure case, and what the user sees>

**Traces to:** <task IDs, filled in by /sdd-tasks>

### REQ-002: <short name>

WHEN <trigger>
THE SYSTEM SHALL <response>

**Acceptance criteria**
- [ ]

**Traces to:**

## Non-functional requirements

> Only ones with a number in them. "Fast" is not a requirement; "renders in
> under 200 ms at p95 on a cold cache" is. Delete any line you cannot measure.

| Concern | Requirement | How measured |
|---|---|---|
| Performance | | |
| Scale | | |
| Availability | | |
| Security | | |
| Accessibility | | |
| Privacy / data retention | | |

## Edge cases and failure modes

| Situation | Expected behaviour | Requirement |
|---|---|---|
| Empty / zero / first-run state | | |
| Concurrent or duplicate action | | |
| Upstream dependency unavailable | | |
| Malformed or hostile input | | |
| Partial failure mid-operation | | |

## Assumptions

> Things we are taking as true without having verified them. Each one is a risk.
-

## Open questions

> Anything unresolved. **An agent must not answer these on its own** — it raises
> them. An empty section is a claim that nothing is ambiguous; be honest.

| # | Question | Blocks | Recommended answer |
|---|---|---|---|
| 1 | | | |

## Out of band

<Things a reader would otherwise ask: prior art, related specs, why an obvious
alternative was rejected. Link ADRs in `docs/adr/`.>
