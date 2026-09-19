---
type: Skill
name: bdd
description: Behaviour-driven testing discipline — turn a spec scenario (Given/When/Then) into a test that exercises the context through its public interface only, so the implementation can be rewritten without touching the test. Use whenever writing a test, whenever a task's RED step cites a scenario ID, and whenever reviewing whether a test is coupled to implementation.
---

# BDD — tests are the spec's scenarios

The spec states behaviour as scenarios. A test is a scenario made executable.
Nothing else is a test.

## The one rule

**Could the implementation be rewritten from scratch — different data
structures, different modules, different algorithm — and this test still
pass without being edited?** If not, the test is coupled to implementation.
Rewrite it or delete it.

## Shape

One test per scenario. Named after it. Citing its ID.

```python
def test_REQ_004_S2_fifth_failed_login_within_15_minutes_is_rate_limited():
    # Given: four failed attempts from 203.0.113.9 in the last 14 minutes
    clock = FakeClock(start="2026-09-19T10:00:00Z")
    auth = build_auth_context(clock=clock, users=[User("ada", password="right")])
    for _ in range(4):
        auth.login(ip="203.0.113.9", username="ada", password="wrong")
    # When: a fifth attempt arrives
    result = auth.login(ip="203.0.113.9", username="ada", password="wrong")
    # Then: it is rejected as rate-limited, with the retry window from the spec
    assert result == LoginRejected(reason="rate_limited", retry_after_s=60)
```

Notice what the test touches: the context's **public interface**
(`build_auth_context`, `login`) and its **published result types**
(`LoginRejected`). Notice what it does not touch: the counter, the store, the
hashing, the module layout. Those can all change.

## Given / When / Then

- **Given** — build the starting state through the public interface or a
  fake at a port (a `FakeClock`, an in-memory repository). Never by writing
  to internal state directly.
- **When** — exactly one trigger. The thing the requirement's `WHEN` names.
- **Then** — assert on what is observable from outside the context: the
  return value, the emitted event, the state visible through the interface.
  Use the real values from the scenario. One scenario, one behaviour; if you
  need three unrelated assertions you have three scenarios.

## Test doubles — only at ports

Fakes replace things *outside* the context: the database, the clock,
randomness, the network, another context (by feeding it that context's
events). They are simple, real implementations of the port — an in-memory
map, a settable clock — not mocks.

Forbidden:

- A mock that asserts *how* the code called something ("repository.save was
  called once with…"). That is implementation.
- Patching or replacing anything inside the context's own domain or
  application code.
- Reaching into private state to set up Given or to assert Then.
- Sleeping, ordering dependence between tests, shared mutable fixtures.

## Invariants

An invariant from `docs/domain.md` gets a test that tries to break it and
fails to. Where the language has a property-based library, use it: generate
inputs, assert the invariant holds after every operation. Otherwise, a
scenario per way it could be violated.

## Naming and location

- File: `tests/<context>/scenarios/test_<requirement-topic>.py` (or the
  stack's equivalent).
- Test: `test_<REQ>_<S>_<scenario name in snake case>`. The ID must appear
  verbatim so `scripts/check-scenarios.sh` can find it.
- Use glossary terms for the context. Not synonyms.

## When the scenario is wrong

If a scenario cannot be written as a test through the public interface,
the scenario is describing implementation, not behaviour — or the interface
is missing something. Either way it is a **spec finding**: stop, report it,
do not bend the test to fit.

## Gherkin

Optional. If the plan adopts a runner (cucumber, behave, pytest-bdd,
SpecFlow…), the scenarios in `spec.md` are copied verbatim into `.feature`
files under `tests/<context>/features/` and the step definitions obey every
rule above. If no runner, the shape above is enough. Do not add a runner for
its own sake.
