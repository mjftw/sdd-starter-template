---
type: Review Policy
title: Review policy
description: The passes, severities, thresholds and exclusions that sdd-converge and the reviewer subagents apply.
resource: /REVIEW.md
status: stable
tags: [sdd, review]
---

# Review policy

> Owned by the user. The `reviewer` subagent and `/sdd-converge` apply this;
> they do not change it. Adjust thresholds here, not in the skill.

## Passes — run all, in this order

1. **Spec compliance** — every `REQ-` in `spec.md`: implemented, tested, every
   acceptance criterion met including failure cases and exact values.
2. **Constitution compliance** — each article, in turn. A violation is critical
   regardless of test results.
2b. **Engineering preferences** — the diff follows `docs/engineering.md`; each
   departure is either recorded in the plan's preferences-check table as
   approved, or is a finding (important).
3. **Plan conformance** — file structure, stack, dependencies, interfaces
   (including error shapes) match `plan.md`.
4. **Bugs and logic errors** — off-by-one, unhandled state, race, wrong
   default, silent failure.
5. **Security** — input validation at boundaries, authz on every new surface,
   secrets not in tree, no new network egress the plan did not name.
6. **Scope** — code that satisfies no requirement.
7. **Hygiene** — suite/lint/typecheck output, skipped tests, `TODO`/`FIXME`/
   stubs in covered paths, commented-out code.
8. **Notes fold-back** — each line in `notes.md` classified: ADR-worthy,
   spec/plan amendment, or local. Also: any note that reveals an engineering
   preference not recorded in `docs/engineering.md` → propose a refinement
   (never apply).

## Severity

- **critical** — blocks Converged. Unmet criterion, untested requirement,
  constitution violation, unplanned dependency, secret in tree, security
  finding at a boundary.
- **warning** — must be tasked before the slice is `shipped`; does not block
  Converged if the user accepts it explicitly.
- **info** — recorded; no action required.

## Thresholds

- Converged requires: 0 critical, and every warning either tasked or accepted
  by the user by name in the report.
- Nit cap: at most 5 `info` items about style. Beyond that, one line saying
  "style: N further nits omitted".

## Exclusions

- Generated files and lockfiles: pass 7 only.
- Anything CI already enforces (formatting, if a formatter runs in CI): skip.
- `docs/**`, `specs/**`: pass 1 traceability only.

## Reviewer conduct

- Read-only. Never fix while auditing.
- A checked box, a commit message, or a previous report is not evidence.
- Every finding cites `file:line`, what the artefact requires, what the code does.
- A spec/code disagreement is a finding for the user, never resolved by editing
  the spec.
