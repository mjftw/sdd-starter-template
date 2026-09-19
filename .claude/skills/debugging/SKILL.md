---
type: Skill
name: debugging
description: Systematic debugging — reproduce, isolate, find the root cause, fix with a test, verify the original symptom — and the verification-before-completion checklist. Use when a test fails unexpectedly, a bug is reported, behaviour is wrong, or before declaring anything fixed. Adapted from obra/superpowers systematic-debugging and verification-before-completion (MIT).
---

# Debugging

The failure mode this prevents: changing things until the symptom goes away,
then declaring victory over a bug you never understood.

## Phase 1 — Reproduce

- Get a failing test, command, or exact steps that show the bug every time.
  If it is intermittent, find what makes it deterministic (seed, clock,
  ordering, load) before going further.
- Write down the observed behaviour and the expected behaviour, verbatim.
  Include the exact error text.
- **If you cannot reproduce it, you cannot fix it.** Say so; do not guess.

## Phase 2 — Isolate

- Narrow the reproduction: smallest input, fewest components, shortest path.
- Bisect: which commit, which layer, which function. Add a temporary assertion
  or log at the midpoint and halve the search.
- Read the code on the path. Actually read it, from the input to the symptom.
  Most bugs are visible to someone who reads the path start to finish.

## Phase 3 — Root cause

- State the cause as a sentence: "X happens because Y, when Z." If you cannot
  write that sentence, you have not found it.
- Distinguish the *defect* (where the code is wrong) from the *symptom*
  (where it was noticed). Fix the defect.
- Ask why the tests did not catch it. That is usually a second bug — in the
  tests.

## Phase 4 — Fix, test-first

- Write a test that fails because of the defect (the `tdd` skill: watch it
  fail for the right reason).
- Make the minimal fix. Run the test: pass. Run the suite: green.
- **Verify the original symptom**, with the original reproduction, not only
  the new test. A fix that passes its own test and leaves the symptom is
  not a fix.
- Consider defence in depth: should the boundary have rejected this input?
  Should a type have made it impossible? If so, that is a second change,
  with its own test.

## Stop and ask when

- Three attempts have not found the cause. You are now guessing; say so and
  bring the user the reproduction, what you ruled out, and your best theory.
- The fix would touch something outside the plan's structure or change an
  interface.
- The root cause is a wrong requirement. That is a spec finding, not a code
  fix.

## Verification before completion — every time

Before saying *done*, *fixed*, *passes*, or *works*:

- [ ] The test suite ran, just now, in full, and the output is in front of
      you. Not "should pass". Not an earlier run.
- [ ] Lint and typecheck ran and are clean.
- [ ] The original symptom or the task's verify command was re-run and
      shows the expected result.
- [ ] No test was skipped, loosened, or deleted to get here.
- [ ] Every file you touched is one the plan says you may touch.
- [ ] The report you are about to write pastes the actual output.

If any box is unchecked, you are not done.
