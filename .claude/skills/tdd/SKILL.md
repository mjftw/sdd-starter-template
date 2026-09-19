---
type: Skill
name: tdd
description: Test-driven development discipline — the iron law, RED/GREEN/REFACTOR, what to do with code written before its test. Use whenever writing or changing production code, whenever a task says "implement", and whenever tempted to write the test afterwards. Adapted from obra/superpowers test-driven-development (MIT).
---

# TDD

## The iron law

**No production code without a failing test first.**

If you have written implementation before its test: delete it. Not "keep it
as reference", not "adapt it while writing the test" — delete it and start
from the test. Code kept as reference gets adapted, which is testing-after
with extra steps.

## The cycle

**RED** — write the smallest test that demonstrates the behaviour you want
and does not yet exist. Run it. **Watch it fail**, and confirm three things:

1. it fails (it does not pass)
2. it fails *because the behaviour is missing* — not a typo, not an import
   error, not a fixture problem
3. the failure message is the one you expected

A test that passes the moment it is written has tested nothing. A test that
fails for the wrong reason proves nothing. Fix the test until the failure is
the right one.

**GREEN** — write the simplest code that makes that test pass. Not the
general solution; not the next test's solution; this test's. Run the test:
pass. Run the whole suite: still green.

**REFACTOR** — now, with a green suite as your net, clean up: names,
duplication, structure. Run the suite after every change. If it goes red,
undo the last change.

Repeat. One behaviour per cycle.

## What "the smallest test" means

- One assertion of behaviour, at the boundary the requirement describes.
- Real values from the acceptance criteria — the actual `429`, the actual
  `15 minutes`, the actual error string.
- Against the public interface, not the internals. If you have to reach into
  private state to test it, the interface is wrong or the test is.

## Rationalisations to reject

| You will think | Answer |
|---|---|
| "Tests after achieve the same thing" | Tests after prove what the code does. Tests first define what it should do. Only the second catches a wrong requirement. |
| "I already tested it manually" | Not reproducible, not in CI, not run by the next person. Does not count. |
| "Deleting this code is wasteful" | Sunk cost. Untested code is a liability, not an asset. |
| "This is too simple to need a test" | Then the test is trivial to write. Write it. |
| "I'll add the tests at the end" | You will not, and if you do they will pass immediately and prove nothing. |
| "This is different because…" | It is not. This sentence is the signal to stop and delete. |

## Red flags — restart from RED

- Code exists that no test demanded.
- A test passed the first time it ran.
- You are writing the test to match the code rather than the code to match
  the test.
- The suite was red before you started and you carried on.

## What TDD does not cover

Exploratory spikes to learn an API are allowed — in a scratch file, thrown
away, never committed. The moment you know what you want, delete the spike
and start from a test.
