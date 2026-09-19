---
type: Product Brief
title: <PROJECT NAME>
description: <ONE LINE>
resource: /docs/product.md
status: draft
tags: [sdd, product-brief]
sources:
  - resource: conversation:YYYY-MM-DD
generated:
  by: claude-code/unknown
  at: YYYY-MM-DDTHH:MM:SSZ
verified: []
sdd_phase: draft          # draft | approved
---

# <PROJECT NAME>

> What this is, for whom, and under what constraints. Written from the user's
> answers, in the user's words. Every later artefact reads this first.

## In one sentence

<ONE LINE — a stranger would understand it>

## Problem

<What is wrong or missing today, for whom, and what it costs them. Not the
solution.>

## Who it is for

| Who | Situation | What they need to be able to do |
|---|---|---|
| | | |

**Explicitly not for:**
-

## What they do today instead

<and what that costs them>

## Success

<What must be true for version one to count as a success. Observable from
outside. If there is a number, put the number.>

## Out of scope — for the whole project

<Not just v1. Things this project will not do, so no slice ever drifts into
them.>

## Constraints that exist before any code

| Constraint | Detail | Source |
|---|---|---|
| Platform / runtime | | |
| Hosting / where it runs | | |
| Data location / sovereignty | | |
| Must integrate with | | |
| Licensing | | |
| Deadline / budget | | |

## Lifecycle

- **Deploy:** <how a change reaches users; who can trigger it; how it is reversed>
- **Operate:** <who is on the hook when it breaks; what "broken" means>
- **Retire:** <what would make you abandon this, and what happens to the data>

## Open questions

| # | Question | Recommended answer |
|---|---|---|
